# http://paas.ops.aniu.so/ 常见故障处理

- 磁盘目录不足

- 清除日志检索es的数据

# chakan 
 curl -XGET http://192.168.0.208:10004/_cat/indices 
 
# 删除 
curl -XDELETE 'http://192.168.0.208:10004/7_bk_log_search_log_search_app*'


# 