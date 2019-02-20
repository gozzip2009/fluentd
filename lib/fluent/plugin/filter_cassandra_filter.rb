require 'cassandra'
require 'fluent/plugin/filter'


#module Fluent
#  class Plugin::CassandraFilter < Plugin::Filter

class Fluent::CassandraFilter < Fluent::Filter
    Fluent::Plugin.register_filter('cassandra_filter', self)

    config_param :host, :string, :default => 'localhost'
    config_param :port, :integer
    config_param :keyspace, :string
    
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
      
      sessionExcute.execute("select service_id, golden_id from journey.mobile_state where service_id = '66910000136';").each do |row|
        record["golden_id"] = "#{row['golden_id']}"
      end
      
      record
    end # filter
end