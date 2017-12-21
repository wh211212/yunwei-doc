# Tomcat7/8基于Redis(Sentinel)的Session共享实战

> 笔者线上环境的多个tomcat需要共享session

## 基于epel源安装、启动redis

```bash
yum install redis -y && /etc/init.d/redis start 
```

> redis具体使用配置参考：http://blog.csdn.net/wh211212/article/details/52817923，贴出笔者的redis.conf

```
bind 0.0.0.0
protected-mode no
port 6379
tcp-backlog 511
timeout 60
tcp-keepalive 300
daemonize yes
supervised no
pidfile /var/run/redis/redis_6379.pid
loglevel notice
logfile /var/log/redis/redis_6379.log
databases 16
save 60 100000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump_6379.rdb
dir /var/lib/redis
slave-serve-stale-data yes
slave-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
repl-disable-tcp-nodelay no
slave-priority 100
requirepass Aniuredis123
rename-command CONFIG ""
rename-command FLUSHALL ""
maxclients 10000
maxmemory 32gb
maxmemory-policy volatile-lru
maxmemory-samples 5
appendonly yes
appendfilename "appendonly_6379.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
lua-time-limit 5000
slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
notify-keyspace-events ""
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit slave 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
aof-rewrite-incremental-fsync yes
```

## 安装并配置Tomcat

> 在服务器上安装并配置两个tomcat7，命令为tomcat7-7081、tomcat7-7082

```bash
wget http://mirrors.shuosc.org/apache/tomcat/tomcat-7/v7.0.82/bin/apache-tomcat-7.0.82.tar.gz -P /usr/local/src
mkdir /opt/tomcats &&  cd /usr/local/src && tar zxf apache-tomcat-7.0.82.tar.gz -C /opt/tomcats
cd /opt/tomcats && mv apache-tomcat-7.0.82 tomcat7-7082 && cp -r tomcat7-7082 tomcat7-7081
```
> 更改两个tomcat的server.xml,修改端口


- 编制两个index.jsp页面，分别放入tomcat7-7081\webapps\ROOT、tomcat7-7082\webapps\ROOT目录下，index.jsp页面内容如下：

```bash
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>获取session id</title>
</head>
<body>
    Session Id : <%= request.getSession().getId() %>
</body>
</html>
```
> Tomcat部分配置完成继续下面操作

## 下载必须jar文件

- 下载最新版本的JEDIS（Redis Java客户端），https://github.com/xetorthio/jedis/releases
- Tomcat Redis会话管理器（Apache Tomcat的Redis支持的非粘性会话存储）https://github.com/jcoleman/tomcat-redis-session-manager/downloads
- Apache Commons Pool http://commons.apache.org/proper/commons-pool/download_pool.cgi

> 将下载的jar拷贝到${TOMCAT_HOME}/lib下
```bash
[root@yunwei src]# cp commons-pool2-2.2.jar jedis-2.9.0.jar tomcat-redis-session-manage-tomcat7.jar /opt/tomcats/tomcat7-7081/lib/
[root@yunwei src]# cp commons-pool2-2.2.jar jedis-2.9.0.jar tomcat-redis-session-manage-tomcat7.jar /opt/tomcats/tomcat7-7082/lib/
```

## 配置Tomcat

> 编辑${TOMCAT_HOME}/conf/context.xml，在context中加入
```bash
    <Valve className="com.orangefunction.tomcat.redissessions.RedisSessionHandlerValve" />
    <Manager className="com.orangefunction.tomcat.redissessions.RedisSessionManager"
       host="localhost"
       port="6379"
       password='Aniuredis123'
       database="0"
       maxInactiveInterval="60" />
```

[root@yunwei src]# redis-cli -a Aniuredis123 -h 127.0.0.1 -p 6379
127.0.0.1:6379> keys 71D850EDC7C97D9F8*
1) "71D850EDC7C97D9F87035C6A5777E263"




## 参考链接

- https://dzone.com/articles/setup-redis-session-store
- http://www.cnblogs.com/linjiqin/p/5761281.html

