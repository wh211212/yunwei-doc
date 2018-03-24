# CentOS6 安装couchdb2 集群

> 参考：http://blog.csdn.net/wh211212/article/details/74359497 安装节点

## 安装couchdb2 节点二

> 参考安装节点一，使用一键安装脚本进行节点二的安装

```
#!/bin/bash
#######################################################
# Functions: centos6.x mininal install apache couchdb
# auther: hwang@aniu.tv
# changelog:
# 2017-07-05  wanghui initial
#######################################################
#
/etc/init.d/iptables stop
chkconfig iptables off
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
#
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
yum -y update
yum -y groupinstall "Development Tools" "Development Libraries"
yum -y install autoconf automake curl-devel help2man libicu-devel libtool perl-Test-Harness wget libicu-devel curl-devel ncurses-devel libtool libxslt fop java-1.7.0-openjdk java-1.7.0-openjdk-devel unixODBC unixODBC-devel vim openssl-devel
#
wget http://erlang.org/download/otp_src_19.3.tar.gz  -P /usr/local/src
cd /usr/local/src  && tar xvf otp_src_19.3.tar.gz && cd otp_src_19.3 && ./configure && make && make install

#
cd /usr/local/src
wget http://springdale.math.ias.edu/data/puias/computational/6/i386//autoconf-archive-2015.02.24-1.sdl6.noarch.rpm
yum localinstall -y autoconf-archive-2015.02.24-1.sdl6.noarch.rpm

#
cd /usr/local/src
wget http://ftp.mozilla.org/pub/mozilla.org/js/js185-1.0.0.tar.gz
tar zxvf js185-1.0.0.tar.gz &&  cd js-1.8.5/js/src && ./configure && make && make install
ln -s /usr/local/include/js /usr/include/js

#
cd /usr/local/src
wget http://mirror.bit.edu.cn/apache/couchdb/source/2.0.0/apache-couchdb-2.0.0.tar.gz
tar zxvf apache-couchdb-2.0.0.tar.gz && cd apache-couchdb-2.0.0 && ./configure && make release

#
#adduser --system --no-create-home --shell /bin/bash -c "CouchDB Administrator" couchdb
useradd couchdb
mv /usr/local/src/apache-couchdb-2.0.0/rel/couchdb /usr/local/
chown -R couchdb:couchdb /usr/local/couchdb
# find /usr/local/couchdb -type d -exec chmod 0770 {} \;
# chmod 0644 /usr/local/couchdb/etc/*

# define configure
# hostname n2couchdb.aniu.so
ip=`ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
echo "127.0.0.1   localhost localhost.localdomain n2couchdb.aniu.so" > /etc/hosts
echo "192.168.0.155 n2couchdb.aniu.so " >> /etc/hosts
sed -i 's/localhost.localdomain/n2couchdb.aniu.so/g' /etc/sysconfig/network

# config couchdb
sed -i 's/couchdb@localhost/couchdb@n2couchdb.aniu.so/g' /usr/local/couchdb/etc/vm.args
sed -i 's/127.0.0.1/0.0.0.0/g' /usr/local/couchdb/etc/default.ini
# errors

# 到这里安装完成，登录上去启动。
```

## 登录节点二测试状态

```
[root@n2couchdb ~]# netstat -nlpt
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address               Foreign Address             State       PID/Program name
tcp        0      0 0.0.0.0:5984                0.0.0.0:*                   LISTEN      21495/beam.smp
tcp        0      0 0.0.0.0:5986                0.0.0.0:*                   LISTEN      21495/beam.smp
tcp        0      0 0.0.0.0:4369                0.0.0.0:*                   LISTEN      21371/epmd
tcp        0      0 0.0.0.0:35797               0.0.0.0:*                   LISTEN      21495/beam.smp
```

## 配置集群

> 修改node1 和node2 hosts配置

```
# n1couchdb.aniu.so
127.0.0.1   localhost localhost.localdomain n1couchdb.aniu.so
192.168.0.154 n1couchdb.aniu.so
192.168.0.155 n2couchdb.aniu.so
# n2couchdb.aniu.so
127.0.0.1   localhost localhost.localdomain n2couchdb.aniu.so
192.168.0.154 n1couchdb.aniu.so
192.168.0.155 n2couchdb.aniu.so
```

## 登录web界面配置

- http://n1couchdb.aniu.so:5984/_utils/#setup

![这里写图片描述](http://img.blog.csdn.net/20170705183359762?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

![这里写图片描述](https://cdn-images-1.medium.com/max/800/1*FdYynqJuzIyL6XiWmvdZPQ.png)

- 对两个节点设置监听地址为0.0.0.0，管理员账号密码为 admin password，建议每个节点做同样的设置，避免出问题，然后，在窗体的下半部分，在“添加NODES”下，添加了另外一个节点。在远程主机中，键入n2couchdb.aniu.so，然后单击绿色的“添加节点”按钮。点击绿色的“配置群集”按钮完成。
> 查看集群节点：

```
curl http://admin:password@n1couchdb.aniu.so:5984/_membership

{"all_nodes":["couchdb@n1couchdb.aniu.so","couchdb@n2couchdb.aniu.so"],"cluster_nodes":["couchdb@n1couchdb.aniu.so","couchdb@n2couchdb.aniu.so"]}


curl http://admin:password@n2couchdb.aniu.so:5984/_membership
```

- 节点一

```
erl -sname bus -setcookie 'brumbrum' -kernel inet_dist_listen_min 9100 -kernel inet_dist_listen_max 9200
```
- 节点二
```
erl -sname bus -setcookie 'brumbrum' -kernel inet_dist_listen_min 9100 -kernel inet_dist_listen_max 9200
```

## 查看集群状态

- http://192.168.0.155:5984/_membership


## 配置couchdb daemon脚本

```
待更新
```

## 注意事项

> 建议不要直接修改/etc/couchdb/default.ini，因为default.ini会随着couchdb的更新而被覆盖，建议修改/etc/couchdb/local.ini

- 如果开启防火需要设置：

```
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 5984
```

### 配置使用证书

```
# cd /etc/couchdb
# openssl req -new -x509 -nodes -newkey rsa:4096 -keyout server.key -out server.crt
/etc/couchdb/local.ini
[daemons]
httpsd = {couch_httpd, start_link, [https]}

[ssl]
cert_file = /etc/couchdb/server.crt
key_file = /etc/couchdb/server.key
```


## 参考链接

- https://wiki.archlinux.org/index.php/CouchDB
