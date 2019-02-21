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
  config_param :where_json, :string, :default => nil
  config_param :custom_where, :string, :default => nil
  
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

    if self.where_json
      @jsonCond = JSON.parse(self.where_json)
    end
  end # configure

  def filter(tag, time, record)
    sessionExcute = @session

    cqlStr = getCql
    dataList = sessionExcute.execute(cqlStr)
  
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

  def getCql
    cql = "select " + self.column + " from "
    cql += self.keyspace+"."+self.tablename

    if @jsonCond
      cql += " where " + prepareJsonCondition
    elsif self.custom_where
      cql += " where " + self.custom_where
    end
    cql += ";"

    cql
  end

  def prepareJsonCondition
    strCondition = ""

    @jsonCond.each do |k, v|
      if v.class == String
        strCondition += k+" = '"+v+"' and"
      else
        strCondition += k+" = "+v+" and"
      end
    end
    strCondition = strCondition.gsub(/ and$/, '')

    strCondition
  end # prepareJsonCondition

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