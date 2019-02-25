require 'fluent/test'
require 'fluent/test/driver/output'
require 'fluent/plugin/out_cassandra_update'
require 'test/unit'

class CassandraUpsertorTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
    @tag = 'test.tag'
  end

  CONFIG = %[
                host 127.0.0.1
                port 9042

                keyspace ksp
                tablename tb_name

                update_value fieldB=':a;'
                where_condition_upd fieldA=':pk_id;'
            ]
  
  def create_driver(conf = CONFIG)
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::CassandraUpdatetor, @tag).configure(conf)
  end

  def test_cassandra
    d = create_driver(CONFIG)

    d.run do
      d.emit({"pk_id" => "66666666667","a" => "111"})
    end
  end
end