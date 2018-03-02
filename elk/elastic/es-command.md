# 查看集群状态
curl -XGET 'localhost:9200/_cat/health?v&pretty'

# 查看集群节点
curl -XGET 'localhost:9200/_cat/nodes?v&pretty'

[root@aniu-saas-1 ~]# curl -XGET 'localhost:9200/_cat/nodes?v&pretty'
ip            heap.percent ram.percent cpu load_1m load_5m load_15m node.role master name
192.168.0.206           29          49   2    0.22    0.13     0.14 mdi       -      es_1
192.168.0.207           19          99   0    0.11    0.10     0.13 mdi       *      es_2
192.168.0.208           28          99   2    0.18    0.51     1.36 mdi       -      es_3

# 查看所有索引
[root@aniu-saas-1 ~]# curl -XGET 'localhost:9200/_cat/indices?v&pretty'
health status index uuid pri rep docs.count docs.deleted store.size pri.store.size

# 创建索引

curl -XPUT 'localhost:9200/customer?pretty&pretty'

curl -XGET 'localhost:9200/_cat/indices?v&pretty'

# 
[root@aniu-saas-1 ~]# curl -XPUT 'localhost:9200/customer/doc/1?pretty&pretty' -H 'Content-Type: application/json' -d'
> {
>   "name": "John Doe"
> }
> '
{
  "_index" : "customer",
  "_type" : "doc",
  "_id" : "1",
  "_version" : 1,
  "result" : "created",
  "_shards" : {
    "total" : 2,
    "successful" : 2,
    "failed" : 0
  },
  "_seq_no" : 0,
  "_primary_term" : 1
}
[root@aniu-saas-1 ~]# curl -XGET 'localhost:9200/customer/doc/1?pretty&pretty'
{
  "_index" : "customer",
  "_type" : "doc",
  "_id" : "1",
  "_version" : 1,
  "found" : true,
  "_source" : {
    "name" : "John Doe"
  }
}

# 删除索引

curl -XDELETE 'localhost:9200/customer?pretty&pretty'
curl -XGET 'localhost:9200/_cat/indices?v&pretty'

# daoru 
curl -u 'elastic' -H 'Content-Type: application/x-ndjson' -XPOST 'localhost:9200/bank/account/_bulk?pretty' --data-binary @accounts.json
curl -u 'elastic' -H 'Content-Type: application/x-ndjson' -XPOST 'localhost:9200/shakespeare/doc/_bulk?pretty' --data-binary @shakespeare_6.0.json
curl -u 'elastic' -H 'Content-Type: application/x-ndjson' -XPOST 'localhost:9200/_bulk?pretty' --data-binary @logs.jsonl
