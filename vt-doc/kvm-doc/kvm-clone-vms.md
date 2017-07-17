# KVM克隆虚拟机

> 使用克隆的方式保存两台vm配置完全一致。

- 暂停虚拟机（suspend）用于克隆

```
[root@sh-kvm-2 ~]# virsh suspend kvm-1
[root@sh-kvm-2 ~]# less /dev/vg_shkvm2/kvm-3
Domain kvm-1 suspended
```

- 使用下面命令进行克隆

```
virt-clone \
 --connect qemu:///system \
 --original kvm-3 \
 --name kvm-4 \
 --file /dev/vg_shkvm3/kvm-4
```

 > 此操作大概会持续两到三分钟，依赖于原生vm的大小

- 克隆完成，可以重启原生虚拟机kvm-1

```
virsh resume kvm-1
```

- 启动克隆的虚拟机（kvm-2）

> 克隆虚拟机是原始VM的一个副本，所有VM属性(VCPUs、内存、磁盘空间)和磁盘内容将是相同的。克隆命令负责生成一个新的MAC地址对于VM克隆并更新适当的网络控制器配置文件(即。因此避免重复的MAC地址,需要修改克隆虚拟机的MAC

```
[root@sh-kvm-2-1 ~]# ifconfig -a | grep HWaddr
eth1      Link encap:Ethernet  HWaddr 52:54:00:C3:87:E7
# 把查到的MAC地址添加到ifcfg-eth0，改掉原来的MAC地址，注释UUID，修改IPADDR，然后重启network
[root@sh-kvm-2-1 network-scripts]# cat ifcfg-eth0  # 修改完成后的eth0网卡配置文件
DEVICE="eth0"
BOOTPROTO="static"
BROADCAST="192.168.0.255"
DNS1="114.114.114.114"
GATEWAY="192.168.0.1"
HWADDR="52:54:00:C3:87:E7"
IPADDR="192.168.0.95"
NETMASK="255.255.255.0"
NM_CONTROLLED="yes"
ONBOOT="yes"
TYPE="Ethernet"
UUID="050e9024-3a2b-46b8-a21f-2925aa7d4bec"
```
- 重启网络报错

```
[root@sh-kvm-2-1 network-scripts]# /etc/init.d/network restart
Shutting down loopback interface:  [  OK  ]
Bringing up loopback interface:  [  OK  ]
Bringing up interface eth0:  Device eth0 does not seem to be present, delaying initialization.
[FAILED]
```

> 这种情况是网卡mac故障导致的，修复过程：

```
[root@sh-kvm-2-1 ~ ]# cd/etc/udev/rules.d
[root@sh-kvm-2-1 rules.d]# cat 70-persistent-net.rules # 编辑70-persistent-net.rules，修改eth0的MAC地址为上面通过ifconfig命令搜出来的

SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", aTTR{address}=="52:54:00:C3:87:E7", ATTR{type}=="1", KERNEL=="eth*", NAME="eth0"
# 修改完成，完后重启网络，成功
执行start_udev
```
