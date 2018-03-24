# use epel

yum -y install rabbitmq-server
service rabbitmq-server start
chkconfig rabbitmq-server on

# use rabbitmq

rabbitmqctl add_user aniu password # 新建用户
rabbitmqctl list_users # 查看用户
rabbitmqctl change_password aniu strongpassword # 设置强密码
rabbitmqctl set_user_tags aniu administrator # 更改用户权限
rabbitmqctl delete_user aniu # 删除用户

rabbitmqctl add_vhost /aniu_vhost
rabbitmqctl list_vhosts
rabbitmqctl list_vhosts

rabbitmqctl set_permissions -p /aniu_vhost aniu ".*" ".*" ".*"
rabbitmqctl list_permissions -p /aniu_vhost
rabbitmqctl list_user_permissions aniu
rabbitmqctl clear_permissions -p /aniu_vhost aniu

# use rabbitmq with php


# use web UI
ln -s /usr/lib/rabbitmq/bin/* /usr/bin/
rabbitmq-plugins enable rabbitmq_management
/etc/init.d/rabbitmq-server restart

# access rabbitmq UI

http://(RabbitMQ server's hostname or IP address):15672/

> 使用新建的administrator或者guest登錄
