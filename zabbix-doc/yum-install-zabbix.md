# zabbix repo

rpm -ivh http://repo.zabbix.com/zabbix/3.0/rhel/6/x86_64/zabbix-release-3.0-1.el6.noarch.rpm

# install zabbix-server-mysql & zabbix-web-mysql

yum install zabbix-server-mysql zabbix-web-mysql

#

shell> mysql -uroot -p<root_password>
mysql> create database zabbix character set utf8 collate utf8_bin;
mysql> grant all privileges on *.* to zabbix@localhost identified by '@Aniuzabbix123.';
mysql> quit;
