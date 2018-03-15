# 安装openstack pike 

- CentOS7 安装openstack pike  用到的命令

# services
for service in rabbitmq-server memcached mariadb mongod; do
systemctl stop $service
done

# keystone
systemctl stop httpd

# glance
systemctl stop openstack-glance-api openstack-glance-registry  
 
# nova
for service in api consoleauth conductor scheduler novncproxy; do
systemctl restart openstack-nova-$service
done

## 卸载openstack pike，重新安装

yum -y install rabbitmq-server memcached mariadb-server

systemctl start rabbitmq-server memcached mariadb