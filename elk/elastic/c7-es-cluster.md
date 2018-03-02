# c7 install elasticsearch cluster

https://www.elastic.co/guide/en/elasticsearch/reference/6.1/rpm.html

# install jdk 1.8.0_131

# config hosts
192.168.0.206   es_1
192.168.0.207   es_2
192.168.0.208   es_3

# elasticsearch node config

## es_1
cluster.name: aniu-es
node.name: es_1
#path.data: /var/lib/elasticsearch
#path.logs: /var/log/elasticsearch
bootstrap.memory_lock: false
network.host: 0.0.0.0
#http.port: 9200
#transport.tcp.port: 9300
discovery.zen.ping.unicast.hosts: ["es_1", "es_2", "es_3"]
discovery.zen.minimum_master_nodes: 2 
gateway.recover_after_nodes: 2
gateway.recover_after_time: 5m
bootstrap.system_call_filter: false

## es_2
cluster.name: aniu-es
node.name: es_2
#path.data: /var/lib/elasticsearch
#path.logs: /var/log/elasticsearch
bootstrap.memory_lock: false
network.host: 0.0.0.0
#http.port: 9200
#transport.tcp.port: 9300
discovery.zen.ping.unicast.hosts: ["es_1", "es_2", "es_3"]
discovery.zen.minimum_master_nodes: 2 
gateway.recover_after_nodes: 2
gateway.recover_after_time: 5m
bootstrap.system_call_filter: false

## es_3
cluster.name: aniu-es
node.name: es_3
#path.data: /var/lib/elasticsearch
#path.logs: /var/log/elasticsearch
bootstrap.memory_lock: false
network.host: 0.0.0.0
#http.port: 9200
#transport.tcp.port: 9300
discovery.zen.ping.unicast.hosts: ["es_1", "es_2", "es_3"]
discovery.zen.minimum_master_nodes: 2 
gateway.recover_after_nodes: 2
gateway.recover_after_time: 5m
bootstrap.system_call_filter: false

# start es
systemctl start elasticsearch
systemctl enable elasticsearch

