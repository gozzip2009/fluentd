# Cassandra plugin for Fluentd

Cassandra output plugin for Fluentd.

Implemented using the Datastax Ruby Driver for Apache Cassandra gem and targets [CQL3](https://docs.datastax.com/en/cql/3.3/)
and Cassandra 1.2 - 3.x

# Installation

via RubyGems : https://rubygems.org/gems/fluentd-plugin-cassandra-cqlfunction

    fluent-gem install fluentd-plugin-cassandra-cqlfunction

## Fluentd.conf Configuration
### Filter Plugin:
    <filter **>
      @type cassandra_selector				# fluent filter plugin
      host 127.0.0.1,127.0.0.2			        # defalut => 127.0.0.1
      port 9042						# defalut => 9092
      keyspace ex						# cassandra keyspace
      tablename tb_ex					# cassandra table
      field fieldA,fieldB					# select field normal
      field_json fieldC                 # select field json string on base(ex fieldC='{"a":"1"}')
      where_condition fieldA='xxx' and fieldB=':keyfrominput;'	# keyfrominput (fieldB=':a;' --> fieldB='1')
    </filter>
    
### ex Filter ::
    input -> {'a':'1'}
    output 1 rec -> {'a':'1', 'fieldA':'xxx', 'fieldB':'yyy'}
    output 2+ rec -> {'a':'1', 'data_cassandra': [{fieldA':'xxx', 'fieldB':'yyy'},{fieldA':'aaa', 'fieldB':'bbb'}]}
    
### Output Plugin:    
    <match **>
       @type cassandra_upsert
       host 127.0.0.1,127.0.0.2
       port 9042
       keyspace ex
       tablename tb_ex
       case_insert_value fieldPk='xxx', fieldB=':keyfrominput;'   #For insert case
       case_update_value fieldA='xxx', fieldB=':keyfrominput;'  #For update case
       where_condition_upd fieldPk='xxx' or fieldPk=':keyfrominput;'
    </match>
    
    <match **>
       @type cassandra_insert
       host 127.0.0.1,127.0.0.2
       port 9042
       keyspace ex
       tablename tb_ex
       insert_value fieldPk='xxx', fieldB=':keyfrominput;'
    </match>
    
    <match **>
       @type cassandra_update
       host 127.0.0.1,127.0.0.2
       port 9092
       keyspace ex
       tablename tb_ex
       update_value fieldPk='xxx', fieldB=':keyfrominput;'
       where_condition_upd fieldPk='xxx' or fieldPk=':keyfrominput;'
    </match>
