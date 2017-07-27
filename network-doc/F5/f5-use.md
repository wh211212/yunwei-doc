# 新建负载池



# 新增端口映射https

jira用https

object network obj-192.168.0.96
host 192.168.0.96
access-list From-dianxin extended permit tcp any host 192.168.0.96 eq https
nat (inside,dianxin) source static obj-192.168.0.96 obj-175.102.133.86 service tcp-443 tcp-443
