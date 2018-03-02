# elastic 插件升级

- 需要先删除，再更新

/usr/share/elasticsearch/bin/elasticsearch-plugin list #

# elasticsearch插件更新
/usr/share/elasticsearch/bin/elasticsearch-plugin install ingest-geoip

/usr/share/elasticsearch/bin/elasticsearch-plugin install ingest-user-agent

/usr/share/elasticsearch/bin/elasticsearch-plugin install x-pack

# kibana插件更新

 /usr/share/kibana/bin/kibana-plugin install x-pack

 # logstash插件更新

/usr/share/logstash/bin/logstash-plugin install x-pack 

# 更新x-pack，需要重新更改用户名密码

/usr/share/elasticsearch/bin/x-pack/setup-passwords interactive