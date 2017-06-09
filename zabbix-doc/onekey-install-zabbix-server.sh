#!/bin/bash
#############################################
# Author:  shaon
# function: install zabbix server one key
# set -xv
# conntact
#    -- wh211212@qq.com
#############################################
# changelog:
#  2016-05-01    vv        initial creation
#  2017-02-20    wanghui   change_version.sh
#############################################
# define version
# http://www.zabbix.com/download
# https://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/3.0.7/zabbix-3.0.7.tar.gz/download
#
function variable-define {
  server="192.168.0.33"       #
  version="zabbix-3.0.7"
  package=/usr/local/src
  zblog=/var/log/zabbix
  zbpid=/opt/zabbix/pid
}


#install gcc
yum -y install gcc gcc-c++ openssh-clients net-snmp* mysql-devel libdbi-dbd-mysql unixODBC-devel OpenIPMI-devel java-devel php-pecl-ssh2.x86_64 libssh2-devel.x86_64 openldap openldap-devel
if [ $? -eq 0 ];then
    echo "yum install successed!"
  else
    echo "yum install failed!"
    exit 2
 fi
#create zabbix group if not exists
egrep "^zabbix" /etc/group >& /dev/null
 if [ $? -ne 0 ]
 then
    groupadd zabbix
 fi
#create user if not exists
egrep "^zabbix" /etc/passwd >& /dev/null
 if [ $? -ne 0 ]
 then
    useradd -g zabbix zabbix -s /bin/nologin
 fi
#wget zabbix.tar.gz
#scp -P 22 root@192.168.1.154:$package/$version.tar.gz $package
wget -P ${package} -c http://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/3.0.1/zabbix-3.0.1.tar.gz
 if [ -e "$package/$version.tar.gz" ]; then
   echo "wget is successed"
 else
   echo "wget is failed"
   exit 2
 fi
#compile zabbix
cd $package
tar -zxvf $version.tar.gz
cd $package/$version
./configure --prefix=/opt/zabbix --enable-server --enable-agent --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2 --enable-java --with-ssh2 --with-openssl --with-openipmi --with-mysql=/usr/local/mysql/bin/mysql_conf
#find / -name mysql_config
make && make install
if [ $? -eq 0 ];
  then
  echo "Installation completed !"
  else
  echo "Installation failed"
  exit 2
fi
#############################################################
cat > ~/.my.cnf << EOF
[client]
password="211212"
user=root
EOF
#password = "MySQL密码"
#user = MySQL 用户名
#其中user 行可以省略, 默认使用当前的用户名填充mysql的登录用户
##############################################################
/etc/init.d/mysql restart

##create database zabbix

mysql -e "create database zabbix character set utf8 collate utf8_bin;"
mysql -e "grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';"
mysql -e "flush privileges;"
cd $package/$version/database/mysql
mysql -uzabbix -pzabbix zabbix< schema.sql
# stop here if you are creating database for Zabbix proxy
mysql -uzabbix -pzabbix zabbix < images.sql
mysql -uzabbix -pzabbix zabbix < data.sql
#define log path
mkdir -p $zblog
mkdir -p $zbpid
chown zabbix:zabbix $zblog
chown zabbix:zabbix $zbpid
#cp $uncompression/zabbix-2.2.2/misc/init.d/fedore/core/zabbix_agentd /etc/rc.d/init.d/
cp -r $package/$version/misc/init.d/fedora/core/zabbix_* /etc/rc.d/init.d/
chmod 744 /etc/init.d/zabbix_*
sed -i "s#BASEDIR=/usr/local#BASEDIR=/opt/zabbix#g" /etc/init.d/zabbix_*
#web php
cp -rf $package/$version/frontends/php /home/wwwroot/default/zabbix
chown -R zabbix:zabbix /home/wwwroot/default/zabbix
#softlink
ln -s /opt/zabbix/bin/zabbix_get /usr/bin/
ln -s /opt/zabbix/bin/zabbix_sender /usr/bin/
ln -s /opt/zabbix/sbin/zabbix_agent /usr/sbin/
ln -s /opt/zabbix/sbin/zabbix_agentd /usr/sbin/
#service port add
cat >>/etc/services <<EOF
zabbix-agent 10050/tcp         #Zabbix Agent
zabbix-agent 10050/udp         #Zabbix Agent
zabbix-trapper 10051/tcp       #Zabbix Trapper
zabbix-trapper 10051/udp       #Zabbix Trapper
EOF
#edit zabbix_server.conf file
sed -i "s/#\ DBPassword=/DBPassword=zabbix/g" /opt/zabbix/etc/zabbix_server.conf
sed -i "s/#\ DBHost=localhost/DBHost=localhost/g" /opt/zabbix/etc/zabbix_server.conf
sed -i "s/#\ DBSocket=\/tmp\/mysql.sock/DBSocket=/tmp/mysql.sock/g" /opt/zabbix/etc/zabbix_server.conf
sed -i "s#tmp/zabbix_server.log#var/log/zabbix/zabbix_server.log#g" /opt/zabbix/etc/zabbix_server.conf
sed -i "s#tmp/zabbix_server.pid#opt/zabbix/pid/zabbix_server.pid#g" /opt/zabbix/etc/zabbix_server.conf
sed -i "s/#\ Timeout=3/Timeout=5/g" /opt/zabbix/etc/zabbix_server.conf
#修改php.ini 支持zabbix
sed -i "s/;always_populate_raw_post_data = -1/always_populate_raw_post_data = -1/g" /usr/local/php/etc/php.ini
sed -i "s/max_input_time = 60/max_input_time = 300/g" /usr/local/php/etc/php.ini
##
/etc/init.d/php-fpm restart
#edit zabbix_agentd.conf file
sed -i "s/Server\=127.0.0.1/Server=127.0.0.1,$server/g" /opt/zabbix/etc/zabbix_agentd.conf
sed -i "s#tmp/zabbix_agentd.log#var/log/zabbix/zabbix_agentd.log#g" /opt/zabbix/etc/zabbix_agentd.conf
sed -i "s#tmp/zabbix_agentd.pid#opt/zabbix/pid/zabbix_agentd.pid#g" /opt/zabbix/etc/zabbix_agentd.conf
sed -i "s/#\ Timeout=3/Timeout=5/g" /opt/zabbix/etc/zabbix_agentd.conf
#sed -i "s/#\ Include=\/usr\/local\/etc\/zabbix_agentd.conf.d/Include=\/opt\/zabbix\/etc\/zabbix_agentd.conf.d/g" /opt/zabbix/etc/zabbix_agentd.conf
sed -i "s/#\ UnsafeUserParameters=0/UnsafeUserParameters=1/g" /opt/zabbix/etc/zabbix_agentd.conf
#start zabbix_agentd
#chkconfig add zabbix_agentd
chkconfig zabbix_agentd on
chkconfig zabbix_server on
/etc/init.d/zabbix_agentd restart
/etc/init.d/zabbix_server restart
#netstat -nltp | grep --color zabbix
revtel=`netstat -nltp | grep zabbix | grep -v grep | wc -l`
if [ $revtel -eq 0 ];then
    echo "zabbix_server install successed"
 else
    echo "zabbix_server install failed"
fi


php_value max_execution_time 300
php_value memory_limit 128M
php_value post_max_size 16M
php_value upload_max_filesize 2M
php_value max_input_time 300
php_value always_populate_raw_post_data -1
# php_value date.timezone Europe/Riga


sed -i 's/max_execution_time = 30/max_execution_time = 300/g' php.ini
sed -i 's/post_max_size = 8M/post_max_size = 16M/g' php.ini
sed -i 's/max_input_time = 60/max_input_time = 300/g' php.ini
sed -i 's/\;date.timezone =/\date.timezone = PRC/g' php.ini
