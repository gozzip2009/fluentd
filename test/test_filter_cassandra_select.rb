require 'fluent/test'
require 'fluent/test/driver/filter'
require 'fluent/plugin/filter_cassandra_selector'
require 'test/unit'

class CassandraFilterTest < Test::Unit::TestCase
  # https://rubygems.org/gems/fluentd-plugin-cassandra-cqlfunction
  def setup
    Fluent::Test.setup
    @tag = 'test.tag'
  end
#  where_json {"fieldA":"xxx"}
#  custom_where fieldA  in ('xxx', 'yyy')
  CONFIG = %[
              host 127.0.0.1
              port 9042
              
              column col1,col2
              keyspace ksp
              tablename tb_name
              where_condition fieldA='66666666666' and fieldB=':pk_id;'
            ]
  
  def create_driver(conf = CONFIG)
    Fluent::Test::FilterTestDriver.new(Fluent::CassandraSelector, @tag).configure(conf)
    #Fluent::Test::Driver::Filter.new(Fluent::Plugin::CassandraFilter).configure(conf)
  end
  
  def test_cassandra
    d = create_driver(CONFIG)
      
    d.run do
      d.filter({"pk_id" => "66999999999","a" => "111"})
    end
  
    print d.filtered_as_array
    
#    resultCorrect = {"a"=>"1", "golden_id"=>"goldenId"}
#    assert_equal resultCorrect ,  d.filtered_as_array[0][2]
  end
end