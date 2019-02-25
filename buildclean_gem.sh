bundle clean --force
gem clean
gem build fluentd-plugin-cassandra-cqlfunction.gemspec
gem install fluentd-plugin-cassandra-cqlfunction-$1.gem
