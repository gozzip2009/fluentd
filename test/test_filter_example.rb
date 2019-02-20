require 'fluent/test'
require 'fluent/test/driver/filter'
require 'fluent/plugin/filter_example'
require 'test/unit'

class ExampleFilterTest < Test::Unit::TestCase
  
  def setup
    Fluent::Test.setup
    @tag = 'test.tag'
  end
  
  CONFIG = %[
              host localhost
            ]
  
  def create_driver(conf = CONFIG)
    Fluent::Test::FilterTestDriver.new(Fluent::ExampleFilter, @tag).configure(conf)
  end
  
  def test_cassandra
    d = create_driver
      
    d.run do
      d.filter({"a" => "1"})
    end
  
    resultCorrect = {"a"=>"1", "host"=>"localhost"}
    print d.filtered_as_array
    
    assert_equal resultCorrect ,  d.filtered_as_array[0][2]
  end
end