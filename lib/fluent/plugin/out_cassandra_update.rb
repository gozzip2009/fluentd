require 'cassandra'
require 'msgpack'
require 'fluent/output'

module Fluent
  class CassandraUpdatetor < BufferedOutput

    Fluent::Plugin.register_output('cassandra_update', self)

    config_param :host, :string, :default => '127.0.0.1'
    config_param :port, :integer, :default => 9042

    config_param :keyspace, :string
    config_param :tablename, :string

    config_param :update_value, :string
    config_param :where_condition_upd, :string
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
      cluster = ::Cassandra.cluster(hosts: hostNode, port: port)
      cluster.connect(keyspace)
    end # get_session

    def configure(conf)
      super

      @updateValue = self.update_value
      @whereCondUpd = self.where_condition_upd
    end # configure

    def format(tag, time, record)
      record.to_msgpack
    end

    def write(chunk)
      chunk.msgpack_each { |record|

        whereCondition = prepareParameter(@whereCondUpd, record)

        @updateValue = prepareParameter(@updateValue, record)
        updateCassandra(@updateValue, whereCondition)

      }
    end # write

    private

    def updateCassandra(updateVal, whereCondition)

      cql = "update #{self.keyspace}.#{self.tablename} set "
      cql += updateVal + " where " + whereCondition + ";"

      print cql
      begin
        @session.execute(cql)
      rescue Exception => e
        $log.error "Cannot update record Cassandra: #{e.message}\nTrace: #{e.backtrace.to_s}"

        raise e
      end
    end # updateCassandra

    def prepareParameter(strOri,record)
      tmpCondVal = {}
      tmpStr = nil
      count = 0

      strOri.split(":").each do |str|
        if count > 0
          tmpStr = str.gsub(/(;.*)/, '')
          tmpCondVal[tmpStr] = record[tmpStr]
        end
        count += 1
      end

      tmpCondVal.each do |k,v|
        strOri= strOri.gsub(k,v)
      end

      strOri = strOri.gsub(':','')
      strOri = strOri.gsub(';','')

      strOri
    end # prepareParameter

  end
end