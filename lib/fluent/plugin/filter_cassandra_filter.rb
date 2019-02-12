require 'fluent/plugin/filter'

module Fluent
  class Plugin::CassandraFilter < Plugin::Filter
    Fluent::Plugin.register_filter('cassandra_filter', self)
    
    config_param :host, :string
    
    def configure(conf)
      super
          
    end # configure
    
    def filter(tag, time, record)
      if @host
        record["host"] = @host
      end
      
      record
    end # filter
  end
end