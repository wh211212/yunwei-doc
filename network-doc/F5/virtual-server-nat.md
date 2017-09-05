# wengu-news

vip: 172.16.3.22 
vir-name: wengu-news
pool-name: wengu-news

## nat

- 参考172.16.3.21
BeiaiQ4-ASA-01(config)# show running-config | include 172.16.3.21
object network obj-172.16.3.21
 host 172.16.3.21
access-list From-dianxin extended permit tcp any host 172.16.3.21 eq 8080 
nat (inside,dianxin) source static obj-172.16.3.21 obj-175.102.133.88 service tcp-8080 tcp-8084

- 确定下外网ip 175.102.133.88的那些端口还未被使用

得到 tcp-8085 还未被使用

- 对172.16.3.22 进行nat

object network obj-172.16.3.22
 host 172.16.3.22
access-list From-dianxin extended permit tcp any host 172.16.3.22 eq 8080 
nat (inside,dianxin) source static obj-172.16.3.22 obj-175.102.133.88 service tcp-8080 tcp-8085
