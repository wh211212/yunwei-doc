# 对安装完成的虚拟机进行初始化设置

> 保证上业务前，每台虚拟机的配置一致

rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
yum install salt-minion -y

- 安装saltstack客户端，通过批量对vm进行配置

- 设置hostname及hosts

更改hosts文件，/etc/sysconfig/network，及hostname

## hostname
sed -i 's/sh-kvm-3-1/localhost.localdomain/g' /etc/sysconfig/network
echo "127.0.0.1   localhost localhost.localdomain sh-kvm-3-1" > /etc/hosts
echo "192.168.0.99 salt" >> /etc/hosts
hstname sh-kvm-3-1

sed -i 's/localhost.localdomain/sh-kvm-3-8/g' /etc/sysconfig/network && echo "127.0.0.1   localhost localhost.localdomain sh-kvm-3-8" > /etc/hosts && echo "192.168.0.99 salt" >> /etc/hosts && hostname sh-kvm-3-8



- 启动saltstack客户端


/etc/init.d/salt-minion start && chkconfig salt-minion on

# saltstack 服务端设置组
[root@zabbix ~]# cat /etc/salt/master.d/nodegroup.conf
nodegroups:
   group_vms: 'L@sh-kvm-1-1,sh-kvm-1-2,sh-kvm-1-3,sh-kvm-2-1,sh-kvm-2-2'

# 根据ip设置组
salt -N group_vms cmd.run 'uname -a'
salt sh-kvm-3 cp.get_file salt://scripts/cmd_track_install.sh /tmp/cmd_track_install.sh
salt sh-kvm-3 cp.get_file salt://scripts/optimziation_os.sh /tmp/optimziation_os.sh

#
salt sh-kvm-3 cmd.run '/bin/bash /tmp/cmd_track_install.sh'
salt -sh-kvm-3 cmd.run '/bin/bash /tmp/optimziation_os.sh'

# 安装zabbix 监控
salt sh-kvm-3 state.sls zabbix.zabbix-agent env=prod
