# Redis Sentinel模式简介

> Redis-Sentinel是官方推荐的高可用解决方案，当redis在做master-slave的高可用方案时，假如master宕机了，redis本身（以及其很多客户端）都没有实现自动进行主备切换，而redis-sentinel本身也是独立运行的进程，可以部署在其他与redis集群可通讯的机器中监控redis集群

- 主要功能有一下几点

> 1、不时地监控redis是否按照预期良好地运行;
2、如果发现某个redis节点运行出现状况，能够通知另外一个进程(例如它的客户端);
3、能够进行自动切换。当一个master节点不可用时，能够选举出master的多个slave(如果有超过一个slave的话)中的一个来作为新的master,其它的slave节点会将它所追随的master的地址改为被提升为master的slave的新地址。
4、哨兵为客户端提供服务发现，客户端链接哨兵，哨兵提供当前master的地址然后提供服务，如果出现切换，也就是master挂了，哨兵会提供客户端一个新地址。

# Redis Sentinel 安装

- 环境准备：

> CentOS6.x 3台
> redis-1(192.168.1.136) redis-2redis-1(192.168.1.137) redis-3redis-1(192.168.1.138)

# 安装Redis

> 参考：http://blog.csdn.net/wh211212/article/details/52817923
