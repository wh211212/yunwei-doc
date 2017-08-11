# Redis Sentinel模式简介

> Redis-Sentinel是官方推荐的高可用解决方案，当redis在做master-slave的高可用方案时，假如master宕机了，redis本身（以及其很多客户端）都没有实现自动进行主备切换，而redis-sentinel本身也是独立运行的进程，可以部署在其他与redis集群可通讯的机器中监控redis集群

- 主要功能有一下几点

> 1、不时地监控redis是否按照预期良好地运行;
2、如果发现某个redis节点运行出现状况，能够通知另外一个进程(例如它的客户端);
3、能够进行自动切换。当一个master节点不可用时，能够选举出master的多个slave(如果有超过一个slave的话)中的一个来作为新的master,其它的slave节点会将它所追随的master的地址改为被提升为master的slave的新地址。
4、哨兵为客户端提供服务发现，客户端链接哨兵，哨兵提供当前master的地址然后提供服务，如果出现切换，也就是master挂了，哨兵会提供客户端一个新地址。

# Redis Sentinel 安装

- 环境准备：

> 192.168.0.106 CentOS6.9

# 安装Redis

> 参考：http://blog.csdn.net/wh211212/article/details/52817923

## CentOS6 单节点安装Redis Sentinel


- 下载redis

> virsh attach-disk kvm-6 /dev/vg_shkvm3/kvm-6-data vdb --driver qemu --mode shareable

```
wget http://download.redis.io/releases/redis-3.2.8.tar.gz -P /usr/local/src
```

- 解压、指定目录

```
tar xvf redis-3.2.8.tar.gz -C /usr/local/
cd /usr/local/
ln -sv redis-3.2.8 redis
```

- 设置系统内核参数

```
echo 512 > /proc/sys/net/core/somaxconn
sysctl vm.overcommit_memory=1
```

- 编译

```
yum groupinstall -y "Development Tools"
yum -y install tcl # 安装tcl依赖防止make test报错
```

> #解决办法：
1，只用单核运行 make test：
taskset -c 1 sudo make test
2，更改 tests/integration/replication-psync.tcl 文件：
vi tests/integration/replication-psync.tcl
把对应报错的那段代码中的 after后面的数字，从100改成 500。我个人觉得，这个参数貌似是等待的毫秒数。

```
cd redis && make && make test
```


- 为多实例redis配置启动环境

```
mkdir -pv /data/redis-sentinel/{9000,9001,9002}
cp src/{redis-server,redis-sentinel} /data/redis-sentinel/9000/
cp src/{redis-server,redis-sentinel} /data/redis-sentinel/9001/
cp src/{redis-server,redis-sentinel} /data/redis-sentinel/9002/
cp redis.conf sentinel.conf /data/redis-sentinel/9000/
cp redis.conf sentinel.conf /data/redis-sentinel/9001/
cp redis.conf sentinel.conf /data/redis-sentinel/9002/
```

- 修改配置文件

```
# vim /data/redis-sentinel/9000/redis.conf
bind 192.168.0.106
protected-mode no
port 9000
daemonize yes
appendonly yes
# \cp /data/redis-sentinel/9000/redis.conf /data/redis-sentinel/9001/redis.conf
# \cp /data/redis-sentinel/9000/redis.conf /data/redis-sentinel/9002/redis.conf

sed -i 's/9000/9001/g' /data/redis-sentinel/9001/redis.conf
# vim /data/redis-sentinel/9001/redis.conf
port 9001
slaveof 192.168.0.106 9000

# vim /data/redis-sentinel/9002/redis.conf
sed -i 's/9000/9002/g' /data/redis-sentinel/9002/redis.conf
port 9002
slaveof 192.168.0.106 9000
```

- 啟動三個redis實例

```
# cd /data/redis-sentinel/9000/
# ./redis-server redis.conf

# cd ../9001/
# ./redis-server redis.conf

# cd ../9002/
# ./redis-server redis.conf

# ps -ef | grep redis
root      4218     1  0 17:03 ?        00:00:00 ./redis-server 192.168.0.106:9000
root      4238     1  0 17:03 ?        00:00:00 ./redis-server 192.168.0.106:9001
root      4252     1  0 17:03 ?        00:00:00 ./redis-server 192.168.0.106:9002
```

- 查看主从状态

```
# /usr/local/redis/src/redis-cli -h 192.168.0.106 -p 9000
192.168.0.106:9000> set name aniu
OK
192.168.0.106:9000> get name
"aniu"
192.168.0.106:9000> info replication
# Replication
192.168.0.106:9000> info replication
# Replication
role:master
connected_slaves:2
slave0:ip=192.168.0.106,port=9001,state=online,offset=1121,lag=0
slave1:ip=192.168.0.106,port=9002,state=online,offset=1121,lag=1
master_repl_offset:1121
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:2
repl_backlog_histlen:1120
```

## 部署sentinel

- 部署sentinel 1

```
# cd /data/redis-sentinel/9000
# vim sentinel.conf
protected-mode no
port 29000
daemonize yes
dir /data/redis-sentinel/9000/logs
sentinel monitor mymaster 192.168.0.106 9000 2
# mkdir logs
# ./redis-sentinel sentinel.conf

# \cp sentinel.conf ../9001/
# \cp sentinel.conf ../9002/
```

- 部署sentinel 2

```
# cd ../9001/
port 29001
dir "/data/redis-sentinel/9001/logs"
# mkdir logs
# ./redis-sentinel sentinel.conf

- 部署sentinel 3

# cd ../9002/
# vim sentinel.conf
port 29002
dir "/data/redis-sentinel/9002/logs"
# mkdir logs
# ./redis-sentinel sentinel.conf
```

- 验证

```
# /usr/local/redis/src/redis-cli -h 192.168.0.106 -p 29000
[root@sh-kvm-3-6 9002]# /usr/local/redis/src/redis-cli -h 192.168.0.106 -p 29000
192.168.0.106:29000> sentinel masters
1)  1) "name"
    2) "mymaster"
    3) "ip"
    4) "192.168.0.106"
    5) "port"
    6) "9000"
    7) "runid"
    8) "03427a4cd4f22401f55d07952424ba4b31144b57"
    9) "flags"
   10) "master"
   11) "link-pending-commands"
   12) "0"
   13) "link-refcount"
   14) "1"
   15) "last-ping-sent"
   16) "0"
   17) "last-ok-ping-reply"
   18) "542"
   19) "last-ping-reply"
   20) "542"
   21) "down-after-milliseconds"
   22) "30000"
   23) "info-refresh"
   24) "3335"
   25) "role-reported"
   26) "master"
   27) "role-reported-time"
   28) "515500"
   29) "config-epoch"
   30) "0"
   31) "num-slaves"
   32) "2"
   33) "num-other-sentinels"
   34) "0"
   35) "quorum"
   36) "2"
   37) "failover-timeout"
   38) "180000"
   39) "parallel-syncs"
   40) "1"
192.168.0.106:29000> sentinel slaves mymaster
1)  1) "name"
    2) "192.168.0.106:9002"
    3) "ip"
    4) "192.168.0.106"
    5) "port"
    6) "9002"
    7) "runid"
    8) "42ec153d250bf9aff05765346e0fdc2ee33d1257"
    9) "flags"
   10) "slave"
   11) "link-pending-commands"
   12) "0"
   13) "link-refcount"
   14) "1"
   15) "last-ping-sent"
   16) "0"
   17) "last-ok-ping-reply"
   18) "510"
   19) "last-ping-reply"
   20) "510"
   21) "down-after-milliseconds"
   22) "30000"
   23) "info-refresh"
   24) "6271"
   25) "role-reported"
   26) "slave"
   27) "role-reported-time"
   28) "548469"
   29) "master-link-down-time"
   30) "0"
   31) "master-link-status"
   32) "ok"
   33) "master-host"
   34) "192.168.0.106"
   35) "master-port"
   36) "9000"
   37) "slave-priority"
   38) "100"
   39) "slave-repl-offset"
   40) "57920"
2)  1) "name"
    2) "192.168.0.106:9001"
    3) "ip"
    4) "192.168.0.106"
    5) "port"
    6) "9001"
    7) "runid"
    8) "afdc283bae3f48fb0ceb6f8dd9af8248928406ec"
    9) "flags"
   10) "slave"
   11) "link-pending-commands"
   12) "0"
   13) "link-refcount"
   14) "1"
   15) "last-ping-sent"
   16) "0"
   17) "last-ok-ping-reply"
   18) "510"
   19) "last-ping-reply"
   20) "510"
   21) "down-after-milliseconds"
   22) "30000"
   23) "info-refresh"
   24) "6271"
   25) "role-reported"
   26) "slave"
   27) "role-reported-time"
   28) "548486"
   29) "master-link-down-time"
   30) "0"
   31) "master-link-status"
   32) "ok"
   33) "master-host"
   34) "192.168.0.106"
   35) "master-port"
   36) "9000"
   37) "slave-priority"
   38) "100"
   39) "slave-repl-offset"
   40) "57920"
```

  
## jedis中使用哨兵


## Redis常用安全设置

- 设置密码

```
requirepass yourpassword
```

- 禁用高危命令

```
rename-command FLUSHALL ""
rename-command FLUSHDB ""
rename-command KEYS ""
```
