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
yum -y install autoconf automake curl-devel help2man libicu-devel libtool perl-Test-Harness wget libicu-devel curl-devel ncurses-devel libtool libxslt fop java-1.7.0-openjdk java-1.7.0-openjdk-devel unixODBC unixODBC-devel vim
openssl-devel

#
wget http://erlang.org/download/otp_src_19.3.tar.gz  -P /usr/local/src
cd /usr/local/src  && tar xvf otp_src_19.3.tar.gz && cd otp_src_19.3 && ./configure && make && make install

#
cd /usr/local/src
wget http://springdale.math.ias.edu/data/puias/computational/6/i386//autoconf-archive-2015.02.24-1.sdl6.noarch.rpm
yum localinstall -y autoconf-archive-2015.02.24-1.sdl6.noarch.rpm

#
cd /usr/local/src
wget http://ftp.mozilla.org/pub/mozilla.org/js/js185-1.0.0.tar.gz && cd js-1.8.5/js/src && ./configure && make && make install
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
echo " ${ip} n2couchdb.aniu.so " >> /etc/hosts

# config couchdb
sed -i 's/couchdb@localhost/couchdb@n2couchdb.aniu.so/g' /usr/local/couchdb/etc/vm.args
sed -i 's/127.0.0.1/0.0.0.0/g' /usr/local/couchdb/etc/default.ini
# errors

# 到这里安装完成，登录上去启动。
