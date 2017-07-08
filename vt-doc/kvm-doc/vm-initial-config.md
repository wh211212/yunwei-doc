# 对安装完成的虚拟机进行初始化设置

> 保证上业务前，每台虚拟机的配置一致

rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
yum install salt-minion -y

- 安装saltstack客户端，通过批量对vm进行配置

- 设置hostname及hosts

更改hosts文件，/etc/sysconfig/network，及hostname


echo "192.168.0.99 salt" >> /etc/hosts


- 启动saltstack客户端


/etc/init.d/salt-minion start && chkconfig salt-minion on

# saltstack 服务端设置组
[root@zabbix ~]# cat /etc/salt/master.d/nodegroup.conf
nodegroups:
   group_vms: 'L@sh-kvm-1-1,sh-kvm-1-2,sh-kvm-1-3,sh-kvm-2-1,sh-kvm-2-2'

# 根据ip设置组   
