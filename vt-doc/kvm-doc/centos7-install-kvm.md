# CentOS7 安装KVM


## 安装依赖包
yum -y update
[root@aniu ~]# yum -y install qemu-kvm qemu-img
[root@server ~]# yum -y install virt-manager libvirt libvirt-python libvirt-client
#[root@server ~]#yum groupinstall virtualization-client virtualization-platform virtualization-tools
[root@aniu ~]# systemctl start libvirtd
[root@aniu ~]# systemctl enable libvirtd

#
setenforce 0

## 配置桥接网络

```
# 使用nmcli命令设置网桥
# add bridge "br0"
[root@aniu ~]# nmcli c add type bridge autoconnect yes con-name br0 ifname br0
Connection 'br0' (0f4b7bc8-8c7a-461a-bff1-d516b941a6ec) successfully added.
# set IP for br0
[root@aniu ~]# nmcli c modify br0 ipv4.addresses 192.168.1.125/24 ipv4.method manual
# set Gateway for br0
[root@aniu ~]# nmcli c modify br0 ipv4.gateway 192.168.1.1
# set DNS for "br0"
[root@aniu ~]# nmcli c modify br0 ipv4.dns 192.168.1.1
# remove the current setting
[root@aniu ~]# nmcli c delete em1
# add an interface again as a member of br0
[root@aniu ~]# nmcli c add type bridge-slave autoconnect yes con-name em1 ifname em1 master br0
# restart
[root@aniu ~]# reboot
```

- 通过直接修改网卡配置设置网桥


```
[root@docker network-scripts]# cat ifcfg-br0
DEVICE=br0
STP=yes
TYPE=Bridge
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=br0
UUID=8754983c-7659-4e02-a180-ce47a2813123
ONBOOT=yes
BRIDGING_OPTS=priority=32768
IPADDR=192.168.1.125
PREFIX=24
GATEWAY=192.168.1.1
DNS1=192.168.1.1
IPV6_PEERDNS=yes
IPV6_PEERROUTES=yes
[root@docker network-scripts]# cat ifcfg-em1
TYPE=Ethernet
NAME=em1
DEVICE=em1
ONBOOT=yes
BRIDGE=br0
```


- 查看网桥配置状态

```
[root@docker ~]# ifconfig
br0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.1.125  netmask 255.255.255.0  broadcast 192.168.1.255
        inet6 fe80::7697:f8ff:2df5:632d  prefixlen 64  scopeid 0x20<link>
        ether 14:18:77:40:29:d3  txqueuelen 1000  (Ethernet)
        RX packets 4039  bytes 462978 (452.1 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 1108  bytes 129167 (126.1 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

em1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        ether 14:18:77:40:29:d3  txqueuelen 1000  (Ethernet)
        RX packets 4600  bytes 592610 (578.7 KiB)
        RX errors 0  dropped 28  overruns 0  frame 0
        TX packets 1505  bytes 159373 (155.6 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        device interrupt 51
```

- 更改主机名

[root@docker ~]# hostnamectl set-hostname kvm-1


##  创建虚拟机api-1

```
# 创建挂载卷
lvcreate -n api-1 -L 20G vg_kvm1
# 安装虚拟机
virt-install \
--name api-1 \
--ram 4096 \
--disk path=/dev/vg_kvm1/api-1 \
--vcpus 4 \
--os-type linux \
--os-variant rhel6 \
--network bridge=br0 \
--graphics none \
--console pty,target_type=serial \
--location 'http://mirrors.aliyun.com/centos/6.9/os/x86_64/' \
--extra-args 'console=ttyS0,115200n8 serial'
#
virt-install -d --name api-1 --ram 4096 --disk path=/dev/vg_kvm1/api-1 --vcpus 4 --os-type linux --os-variant rhel7 --network bridge=br0 --graphics none --console pty,target_type=serial --location 'https://mirrors.aliyun.com/centos/7/os/x86_64/' --extra-args 'console=ttyS0,115200n8 serial'
```

# 参考链接：

- https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/5/html/Virtualization/sect-Virtualization-Installing_the_virtualization_packages-Installing_KVM_packages_on_an_existing_Red_Hat_Enterprise_Linux_system.html
- https://www.server-world.info/en/note?os=CentOS_7&p=kvm
