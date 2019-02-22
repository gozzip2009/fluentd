require 'fluent/plugin/filter'

class Fluent::ExampleFilter < Fluent::Filter
  Fluent::Plugin.register_filter('example_filter', self)
  
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
