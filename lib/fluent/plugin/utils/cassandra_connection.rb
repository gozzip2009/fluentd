require 'cassandra'

module CassandraConnection
  
  def get_session(host, port, keyspace, connect_timeout, username, password)
    hostNode = host.split(",")
    if self.username
      cluster = ::Cassandra.cluster(hosts: hostNode, port: port, connect_timeout: connect_timeout, username: username, password: password)
    else
      cluster = ::Cassandra.cluster(hosts: hostNode, port: port, connect_timeout: connect_timeout)
    end
    cluster.connect(keyspace)
  end # get_session
  
end
