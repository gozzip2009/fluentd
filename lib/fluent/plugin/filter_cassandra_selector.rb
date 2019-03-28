require 'cassandra'
require 'fluent/plugin/filter'

#module Fluent
#  class Plugin::CassandraSelector < Plugin::Filter

class Fluent::CassandraSelector < Fluent::Filter
  Fluent::Plugin.register_filter('cassandra_selector', self)

  config_param :host, :string, :default => '127.0.0.1'
  config_param :port, :integer, :default => 9042
  
  config_param :username, :string, :default => nil
  config_param :password, :string, :default => nil
  
  config_param :connect_timeout, :integer, :default => 5
  
  config_param :field, :string, :default => nil
  config_param :keyspace, :string
  config_param :tablename, :string
  config_param :where_condition, :string, :default => nil

  config_param :field_json, :string, :default => nil
  def start
    super
    @session ||= get_session(@host, @port, @keyspace)
  end # start

  def shutdown
    super
    @session.close if @session
  end # shutdown

  def get_session(host, port, keyspace)
    hostNode = host.split(",")
    if self.username
      cluster = ::Cassandra.cluster(hosts: hostNode, port: port, connect_timeout: self.connect_timeout, username: self.username, password: self.password)
    else
      cluster = ::Cassandra.cluster(hosts: hostNode, port: port, connect_timeout: self.connect_timeout)
    end
    cluster.connect(keyspace)
  end # get_session

  def configure(conf)
    super

    raise ConfigError, "params 'field' or 'field_json' is require least once"  if self.field_json.nil? && self.field.nil?

  end # configure

  def filter(tag, time, record)

    dataList = nil
    cql = getCql(record)
    
    begin
      dataList = @session.execute(cql)
    rescue Exception => e
      $log.error "Cannot select Cassandra: #{e.message}\nTrace: #{e.backtrace.to_s}"
      raise e
    end

    if dataList.length == 1
      dataList.each do |row|
        record = prepareRowToHash(row, record)
      end
    elsif dataList.length > 1
      if self.field_json.nil? || self.field_json.empty?
        record["data_cassandra"] = dataList.rows.to_a
      else
        tmpListRec = []
        tmpRec = nil
        dataList.each do |row|
          tmpRec = prepareRowToHash(row,{})
          tmpListRec.push(tmpRec)
        end

        record["data_cassandra"] = tmpListRec
      end
    end
    record
  end # filter

  private

  def prepareRowToHash(row, record)
    if self.field
      self.field.split(",").each do |col|
        record[col] = "#{row[col]}"
      end
    end

    if self.field_json
      self.field_json.split(",").each do |col|
        record = getDataStrJson("#{row[col]}", record)
      end
    end
    record
  end

  def getDataStrJson(jsonData, record)
    if jsonData && !jsonData.empty?
      jsonData = eval(jsonData)

      jsonData.each do |k,v|
        record[k.to_s] = v
      end
    end

    record
  end # getDataStrJson

  def getCql(record)
    cql = "select "
    if self.field
      cql += self.field + ","
    end

    if self.field_json
      cql += self.field_json + ","
    end

    cql = cql.gsub(/,$/, '')

    cql += " from #{self.keyspace}.#{self.tablename}"

    if self.where_condition
      cql += " where "+prepareCondition(record)
    end

    cql += ";"

    cql
  end # getCql

  def prepareCondition(record)
    tmpCondVal = {}
    tmpStr = nil
    count = 0

    self.where_condition.split(":").each do |str|
      if count > 0
        tmpStr = str.gsub(/(;.*)/, '')
        tmpCondVal[tmpStr] = record[tmpStr]
      end
      count += 1
    end

    tmpStr = self.where_condition
    tmpCondVal.each do |k,v|
      tmpStr = tmpStr.gsub(k,v)
    end

    tmpStr = tmpStr.gsub(':','')
    tmpStr = tmpStr.gsub(';','')

    tmpStr
  end # prepareCondition

  #    def filterExample(tag, time, record)
  #      sessionExcute = @session
  #
  #      sessionExcute.execute("select service_id, golden_id from journey.mobile_state where service_id = '66910000136';").each do |row|
  #        record["golden_id"] = "#{row['golden_id']}"
  #      end
  #
  #      record
  #    end filterExample
end