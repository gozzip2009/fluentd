require 'fluent/test'
require 'fluent/test/driver/filter'
require 'fluent/plugin/filter_example'
require 'test/unit'
require 'json'

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
    
    print "\n******************* END ************************\n"
    
    jsonStr = '{"a":"1","b":2}'
    jsonData = JSON.parse(jsonStr)
    
    jsonData.each do |k, v|
      if v.class == Integer
        print v
      end 
    end
    
    print "\n******************* END ************************\n"
    record = {'serviceId' => '1', 'other' => '2', 'got' => '3', 'gottt'=>'4'}
    
    tmpCondVal = {}
    tmpStr = nil
    cond = "where a=':serviceId;' and b=':other;' and c=':got;'"
    count = 0
    cond.split(":").each do |str|
      if count > 0
        tmpStr = str.gsub(/(;.*)/, '')
        tmpCondVal[tmpStr] = record[tmpStr]
      end
      count += 1
    end
    
    tmpCondVal.each do |k,v|
      cond = cond.gsub(k,v)
    end
    
    cond = cond.gsub(':','')
    cond = cond.gsub(';','')
    print cond
#    cond = cond.gsub(/.+:(\w+);.+/, '\1')
#    print cond
    
  end
end