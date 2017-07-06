# virt-manager
> 遠程管理xen Dom0
yum install virt-manager -y

virsh -c xen+ssh://yunwei@192.168.0.66

# 

# xen guest config xml #

/etc/libvirt/libxl

# xen rename guest

[root@xen-1 libxl]# virsh list --all
 Id    Name                           State
----------------------------------------------------
 0     Domain-0                       running
 8     test1                          running

# 关闭虚拟机

virsh shutdwon crm-cas-admin

cd /etc/libvirt/libxl

virsh dumpxml test1 > test.xml

# 编辑配置文件

name test1 改为 name test

sed -i 's/test1/test/' test.xml  # 这里不建议使用sed直接修改，有可能lvm的名字中包含 test1，因为建议编辑文件进行修改

# 重定义虚拟机配置文件

virsh undefine test1
virsh define test.xml

# 启动虚拟机

virsh start test

# 设置自启动

virsh autostart test
