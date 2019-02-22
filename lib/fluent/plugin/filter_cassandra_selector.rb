require 'cassandra'
require 'fluent/plugin/filter'
require 'json'

#module Fluent
#  class Plugin::CassandraSelector < Plugin::Filter

class Fluent::CassandraSelector < Fluent::Filter
  Fluent::Plugin.register_filter('cassandra_selector', self)

  config_param :host, :string, :default => 'localhost'
  config_param :port, :integer, :default => 9042

  config_param :column, :string
  config_param :keyspace, :string
  config_param :tablename, :string
  config_param :where_condition, :string, :default => nil
  
  def start
    super
    @session ||= get_session(@host, @port, @keyspace)
  end # start

  def shutdown
    super
    @session.close if @session
  end # shutdown

  def get_session(host, port, keyspace)
    cluster = ::Cassandra.cluster(hosts: host, port: port)
    cluster.connect(keyspace)
  end # get_session

  def configure(conf)
    super

  end # configure

  def filter(tag, time, record)
    sessionExcute = @session
    
    dataList = sessionExcute.execute(getCql(record))

    if dataList.length == 1
      dataList.each do |row|
        self.column.split(",").each do |col|
          record[col] = "#{row[col]}"
        end
      end
    elsif dataList.length > 1
      record["data_cassandra"] = dataList.rows.to_a
    end

    record
  end # filter

  private

  def getCql(record)
    cql = "select " + self.column + " from "
    cql += self.keyspace+"."+self.tablename
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
    
    tmpCondVal.each do |k,v|
      self.where_condition = self.where_condition.gsub(k,v)
    end
    
    self.where_condition = self.where_condition.gsub(':','')
    self.where_condition = self.where_condition.gsub(';','')
    
    self.where_condition
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