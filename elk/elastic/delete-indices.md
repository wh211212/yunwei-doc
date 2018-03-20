
# 查看当前索引文件

curl -u elastic:elastic -XGET 'localhost:9200/_cat/indices?v&pretty'

# 按名称删除索引
curl -u elastic:elastic -XDELETE 'http://localhost:9200/packetbeat-*'

# 根据时间删除索引

