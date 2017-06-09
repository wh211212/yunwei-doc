# Netdata 介绍

> Netdata是一个高度优化的Linux守护进程，它为Linux系统，应用程序，SNMP服务等提供实时的性能监测。

> Github: https://github.com/firehol/netdata/wiki/Installation  (安装教程)
> 开源中国：http://www.oschina.net/p/netdata/similar_projects  （Netdata简介）


# Netdata 安装

```
# 下载依赖包
yum install autoconf automake curl gcc git libmnl-devel libuuid-devel lm_sensors make MySQL-python nc pkgconfig python python-psycopg2 PyYAML zlib-devel

# Github上提供的git clone笔者本地实在太慢，故事用wget下载源码包()
wget https://github.com/firehol/netdata/releases/download/v1.6.0/netdata-1.6.0.tar.gz -P /usr/loca/src

cd /usr/local/src/ && tar zxvf netdata-1.6.0.tar.gz && cd netdata-1.6.0
./netdata-installer.sh --install /opt

# 笔者这里指定安装到/opt,读者可以自定义安装路径

```

#　Netdata 使用

- 启动
```
/opt/netdata/usr/sbin/netdata
```
- 停止
```
 killall netdata
```
 - 加入开机启动

```
echo '/opt/netdata/usr/sbin/netdata' >> /etc/rc.d/rc.local
```
