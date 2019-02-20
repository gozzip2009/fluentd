require 'fluent/test'
require 'fluent/test/driver/filter'
require 'fluent/plugin/filter_cassandra_filter'
require 'test/unit'

class CassandraFilterTest < Test::Unit::TestCase
  # https://rubygems.org/gems/fluentd-plugin-cassandra
  def setup
    Fluent::Test.setup
    @tag = 'test.tag'
  end
  
  CONFIG = %[
              host 10.95.108.234
              port 9042
              keyspace journey
            ]
  
  def create_driver(conf = CONFIG)
    Fluent::Test::FilterTestDriver.new(Fluent::CassandraFilter, @tag).configure(conf)
    #Fluent::Test::Driver::Filter.new(Fluent::Plugin::CassandraFilter).configure(conf)
  end
  
  def test_cassandra
    d = create_driver(CONFIG)
      
    d.run do
      d.filter({"a" => "1"})
    end
  
    resultCorrect = {"a"=>"1", "golden_id"=>"goldenId"}
    print d.filtered_as_array
    
    assert_equal resultCorrect ,  d.filtered_as_array[0][2]
  end
end