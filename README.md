# Cassandra plugin for Fluentd

Cassandra output plugin for Fluentd.

Implemented using the Datastax Ruby Driver for Apache Cassandra gem and targets [CQL3](https://docs.datastax.com/en/cql/3.3/)
and Cassandra 1.2 - 3.x

# Warning

This project is in an alpha state, so configuration params could be changed without changing of major version.

Be careful before updating.

# Installation

via RubyGems

    fluent-gem install fluent-plugin-cassandra-driver-selector

# Quick Start

## Cassandra Configuration
    # Create keyspace (via CQL)
      CREATE KEYSPACE metrics WITH strategy_class='org.apache.cassandra.locator.SimpleStrategy' AND strategy_options:replication_factor=1;

    # Create table (column family)
      CREATE TABLE logs (id varchar, timestamp timestamp, json text, PRIMARY KEY (id, timestamp)) WITH CLUSTERING ORDER BY (timestamp DESC);

## Fluentd.conf Configuration
    <filter cassandra.**>
      type cassandra_selector    					# fluent filter plugin
      host 127.0.0.1             					# defalut => localhost
      port 9092					 					# defalut => 9092
      keyspace ex             	 					# cassandra keyspace
      tablename tb_ex			 					# cassandra table
      column fieldA,fieldB		 					# select by field
	  where_json {"fieldA":"xxx","fieldB":"yyy"}	# where by "and" condition(fieldA='xxx' and fieldB='yyy')
	  custom_where fieldA='xxx' and fieldB='yyy'	# custom condition
    </filter>
    
### ex ::
    input -> {'a':'1'}
    output 1 rec -> {'a':'1', 'fieldA':'xxx', 'fieldB':'yyy'}
    output 2+ rec -> {'a':'1', 'data_cassandra': [{fieldA':'xxx', 'fieldB':'yyy'},{fieldA':'aaa', 'fieldB':'bbb'}]}
    
All nil types will be recognized as string.
    
# Tests

TODO
