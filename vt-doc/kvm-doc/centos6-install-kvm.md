# CentOS6 mininial 安装KVM 详细教程

## 安装依赖包

```
[root@sh-kvm-1 ~]# yum update -y
[root@sh-kvm-1 ~]# yum -y install qemu-kvm libvirt python-virtinst bridge-utils
[root@kvm-1 ~]# lsmod | grep kvm
kvm_intel              54285  0
kvm                   333172  1 kvm_intel
[root@sh-kvm-1 ~]# /etc/rc.d/init.d/libvirtd start
Starting libvirtd daemon: [ OK ]
[root@sh-kvm-1 ~]# /etc/rc.d/init.d/messagebus start
Starting system message bus: [ OK ]
[root@sh-kvm-1 ~]# chkconfig libvirtd on
[root@sh-kvm-1 ~]# chkconfig messagebus on
```

## 配置桥接网络

```
# 网桥网卡配置
[root@sh-kvm-1 ~]# cp /etc/sysconfig/network-scripts/ifcfg-em1 /etc/sysconfig/network-scripts/ifcfg-br0
[root@sh-kvm-1 ~]# vi /etc/sysconfig/network-scripts/ifcfg-br0
DEVICE=br0
TYPE=Bridge
ONBOOT=yes
BOOTPROTO=none
IPADDR=192.168.0.67
NETMASK=255.255.255.0
GATEWAY=192.168.0.1
DNS1=114.114.114.114

# em1网卡配置
[root@sh-kvm-1 ~]# vi /etc/sysconfig/network-scripts/ifcfg-em1
# create new
DEVICE=em1
TYPE=Ethernet
ONBOOT=yes
BRIDGE=br0
HWADDR=14:18:77:40:29:D3
UUID=d2e2265d-f891-4574-918f-c76a4dd6f2eb
# 配置网桥这里注意
# bro网卡配置里面不需要em1的mac地址和UUID，em1网卡的mac地址和UUID跟着em1网卡走。 不然重启网络时会报错，报错在文章末尾。

[root@sh-kvm-1 ~]# /etc/rc.d/init.d/network restart

```

- 查看网桥配置状态

```
[root@sh-kvm-1 ~]# ifconfig
br0       Link encap:Ethernet  HWaddr 14:18:77:40:29:D3
          inet addr:192.168.1.125  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::1618:77ff:fe40:29d3/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:52655 errors:0 dropped:0 overruns:0 frame:0
          TX packets:20216 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:49670413 (47.3 MiB)  TX bytes:1665453 (1.5 MiB)

em1       Link encap:Ethernet  HWaddr 14:18:77:40:29:D3
          inet6 addr: fe80::1618:77ff:fe40:29d3/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:302969 errors:0 dropped:0 overruns:0 frame:0
          TX packets:96324 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:427674107 (407.8 MiB)  TX bytes:7173701 (6.8 MiB)
          Interrupt:41

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:7 errors:0 dropped:0 overruns:0 frame:0
          TX packets:7 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:608 (608.0 b)  TX bytes:608 (608.0 b)

virbr0    Link encap:Ethernet  HWaddr 52:54:00:68:65:A2
          inet addr:192.168.122.1  Bcast:192.168.122.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)

vnet0     Link encap:Ethernet  HWaddr FE:54:00:08:94:EC
          inet6 addr: fe80::fc54:ff:fe08:94ec/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:19 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3443 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:500
          RX bytes:1243 (1.2 KiB)  TX bytes:381667 (372.7 KiB)
```

##  创建虚拟机kvm-1

```
# 创建挂载卷
lvcreate -n kvm-1 -L 20G vg_shkvm1
# 安装虚拟机
virt-install \
--name kvm-2 \
--ram 4096 \
--disk path=/dev/vg_shkvm2/kvm-2 \
--vcpus 4 \
--os-type linux \
--os-variant rhel6 \
--network bridge=br0 \
--graphics none \
--console pty,target_type=serial \
--location 'http://mirrors.aliyun.com/centos/6.9/os/x86_64/' \
--extra-args 'console=ttyS0,115200n8 serial'
# 使用网易源
# 4核8G centos6
virt-install --name kvm-2 --ram 8192 --disk path=/dev/vg_shkvm3/kvm-2 --vcpus 4 --os-type linux --os-variant rhel6 --network bridge=br0 --graphics none --console pty,target_type=serial --location 'http://mirrors.163.com/centos/7/os/x86_64/' --extra-args 'console=ttyS0,115200n8 serial'
# 4核8G centos7
virt-install --name kvm-2 --ram 8192 --disk path=/dev/vg_shkvm3/kvm-2 --vcpus 4 --os-type linux --os-variant rhel7 --network bridge=br0 --graphics none --console pty,target_type=serial --location 'http://mirrors.163.com/centos/7/os/x86_64/' --extra-args 'console=ttyS0,115200n8 serial'
# 8核32G
virt-install --name kvm-2 --ram 32768 --disk path=/dev/vg_shkvm3/kvm-2 --vcpus 8 --os-type linux --os-variant rhel6 --network bridge=br0 --graphics none --console pty,target_type=serial --location 'http://mirrors.163.com/centos/7/os/x86_64/' --extra-args 'console=ttyS0,115200n8 serial'
# 8核16G
virt-install --name kvm-2 --ram 16384 --disk path=/dev/vg_shkvm3/kvm-2 --vcpus 8 --os-type linux --os-variant rhel6 --network bridge=br0 --graphics none --console pty,target_type=serial --location 'http://mirrors.163.com/centos/7/os/x86_64/' --extra-args 'console=ttyS0,115200n8 serial'
# 2核8G
virt-install --name kvm-2 --ram 8192 --disk path=/dev/vg_shkvm3/kvm-2 --vcpus 2 --os-type linux --os-variant rhel6 --network bridge=br0 --graphics none --console pty,target_type=serial --location 'http://mirrors.163.com/centos/7/os/x86_64/' --extra-args 'console=ttyS0,115200n8 serial'


```

## 图形安装教程

- 选择安装语言

![这里写图片描述](http://img.blog.csdn.net/20170706110336735?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 设置网络配置，使用静态IP

![这里写图片描述](http://img.blog.csdn.net/20170706110357198?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

> 配置静态ip，忘记截图，按照上面网桥ip，设置相同局域网ip即可

-  静态ip配置成功，如下图会加载安装镜像：

![这里写图片描述](http://img.blog.csdn.net/20170706110507330?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

-  选择使用文本方式安装，即命令行模式

![这里写图片描述](http://img.blog.csdn.net/20170706110627220?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

-  Re-initialize all 初始化磁盘

![这里写图片描述](http://img.blog.csdn.net/20170706110719119?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

> 这里选择初始化全部硬盘，还有一种情况是如果在重装虚拟机的时候，当前lvm卷上面已经存在系统，可以选择替换当前系统的方式安装，这样会保留原来lvm卷上系统的完整信息。

- 选择时区，上海

![这里写图片描述](http://img.blog.csdn.net/20170706110905758?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 设置root密码

![这里写图片描述](http://img.blog.csdn.net/20170706110931845?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 安装系统安装位置

![这里写图片描述](http://img.blog.csdn.net/20170706110950918?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 初始化磁盘

![这里写图片描述](http://img.blog.csdn.net/20170706111025132?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 开始安装系统包文件

![这里写图片描述](http://img.blog.csdn.net/20170706111047331?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
![这里写图片描述](http://img.blog.csdn.net/20170706111104748?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

> 等待系统安装包安装完成，重启系统。

-  参考虚拟机kvm-1的安装，安装kvm-2

## 安装kvm-2

```
# 创建挂载卷
lvcreate -n kvm-2 -L 20G vg_shkvm1
# 安装虚拟机
virt-install \
--name kvm-2 \
--ram 2048 \
--disk path=/dev/vg_shkvm1/kvm-2 \
--vcpus 2 \
--os-type linux \
--os-variant rhel6 \
--network bridge=br0 \
--graphics none \
--console pty,target_type=serial \
--location 'http://mirrors.aliyun.com/centos/6.9/os/x86_64/' \
--extra-args 'console=ttyS0,115200n8 serial'

# 使用本地镜像安装

virt-install \
--name vm1 \
--ram=2048 \
--vcpus=2 \
--disk path=/vm-images/vm1.img,size=15 \
--cdrom /root/RHEL-7.0-20140507.0-Server-x86_64-dvd1.iso

```

## 安装过程中报错解决

> 配置桥接时报错：device em1 does not seem to be present delaying initialization ；device br0 already exists,can't create bridge with the same name，#本次安装故障原因是br0网卡配置是name没有改，导致重启时重启创建em1报错

```
> 删除/etc/udev/rules.d/70-persistent-net.rules这个文件
将ifcfg-br0文件中的mac地址和UUID这两行内容注释掉

start_udev

重启服务器，网卡恢复正常。
如果还是无法启动，查看新产生的/etc/udev/rules.d/70-persistent-net.rules内容,并将网卡的配置文件改成相应的内容

```

## 参考教程

- https://www.server-world.info/en/note?os=CentOS_6&p=kvm&f=2
