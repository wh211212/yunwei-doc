# CentOS6/CentOS7 双网卡配置bonding

## 在CentOS6/RHEL6上配置网络绑定

> 网络绑定是将多个局域网卡（eth0和eth1）聚合成称为绑定接口的单个接口。 网络绑定是一项内核功能，也称为网卡绑定。 通常需要绑定来提供高可用性和负载均衡服务。

> 在本教程中，笔者在CentOS 6.X上配置网络绑定，笔者服务器有两个Lan卡（em1和em2）并将创建绑定接口（bond0)

- 步骤一、创建绑定文件（ifcfg-bond0）并指定IP地址，网络掩码和网关

```bash
# cat /etc/sysconfig/network-scripts/ifcfg-bond0 
DEVICE=bond0
IPADDR=192.168.0.210
NETMASK=255.255.255.0
GATEWAY=192.168.0.1
TYPE=Bond
ONBOOT=yes
NM_CONTROLLED=no
BOOTPROTO=static
# IP地址相关需自定义
```

- 步骤二、编辑em1和em2的文件，并确保输入主和从条目，如下所示

```bash
[root@aniu-cache-01 ~]# cat /etc/sysconfig/network-scripts/ifcfg-em1
DEVICE=em1
HWADDR=B8:2A:72:E1:09:6E
TYPE=Ethernet
UUID=f0fa2ed7-27a6-4c70-89da-45965a249dfa
ONBOOT=yes
NM_CONTROLLED=no
MASTER=bond0
SLAVE=yes
[root@aniu-cache-01 ~]# cat /etc/sysconfig/network-scripts/ifcfg-em2
DEVICE=em2
HWADDR=B8:2A:72:E1:09:6F
TYPE=Ethernet
UUID=c18e1b9e-4a86-47d1-84e2-c4e2a60863ba
ONBOOT=no
NM_CONTROLLED=no
MASTER=bond0
SLAVE=yes
```

- 步骤三、创建Bond文件（bonding.conf）

```bash
# vi /etc/modprobe.d/bonding.conf
alias bond0 bonding
options bond0 mode=1 miimon=100
# 高可用模式
```

> bonding.conf文件中使用的不同模式,功能不同，具体如下

- balance-rr or 0 — 用于容错和负载平衡的循环模式
- active-backup or 1 — 设置用于容错的活动备份模式
- balance-xor or 2 — 为容错和负载平衡设置异或（异或）模式。
- broadcast or 3 — 设置容错的广播模式。所有传输都在所有的从接口上发送。
- 802.3ad or 4 — 设置IEEE 802.3ad动态链接聚合模式。创建共享相同速度和双工设置的聚合组。
- balance-tlb or 5 — 设置传输负载平衡（TLB）模式以实现容错和负载平衡。
- balance-alb or 6 — 为容错和负载平衡设置活动负载平衡（ALB）模式。

- 步骤四、重启网络服务，并检查网络接口信息

```bash
[root@aniu-cache-01 ~]# ifconfig bond0
bond0     Link encap:Ethernet  HWaddr B8:2A:72:E1:09:6E  
          inet addr:192.168.0.210  Bcast:192.168.0.255  Mask:255.255.255.0
          inet6 addr: fe80::ba2a:72ff:fee1:96e/64 Scope:Link
          UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
          RX packets:271980 errors:0 dropped:0 overruns:0 frame:0
          TX packets:16989 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:45139572 (43.0 MiB)  TX bytes:1719627 (1.6 MiB)
```

- 步骤五、验证bonding状态

```bash
[root@aniu-cache-01 ~]# cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)

Bonding Mode: fault-tolerance (active-backup)
Primary Slave: None
Currently Active Slave: em1
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: em1
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: b8:2a:72:e1:09:6e
Slave queue ID: 0

Slave Interface: em2
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: b8:2a:72:e1:09:6f
Slave queue ID: 0
```

> 注意：根据上面显示的输出，正在使用主动备份绑定。要执行测试，只需禁用一个接口，并检查是否仍在使用bond ip访问您的机器。

## 在CentOS 7 / RHEL 7中配置NIC（网络接口卡）绑定

- 先决条件

```bash
# 如果bonding模块没有加载到你的Linux机器上，那么使用下面的命令来加载。
modprobe bonding

# 要列出绑定模块信息，请使用以下命令
[root@aniu-k8s ~]# modinfo bonding  # 类似下面信息
filename:       /lib/modules/3.10.0-693.17.1.el7.x86_64/kernel/drivers/net/bonding/bonding.ko.xz
author:         Thomas Davis, tadavis@lbl.gov and many others
description:    Ethernet Channel Bonding Driver, v3.7.1
version:        3.7.1
license:        GPL
alias:          rtnl-link-bond
rhelversion:    7.4
srcversion:     33C47E3D00DF16A17A5AB9C
depends:        
intree:         Y
vermagic:       3.10.0-693.17.1.el7.x86_64 SMP mod_unload modversions 
signer:         CentOS Linux kernel signing key
sig_key:        50:6C:68:68:80:9D:2C:BF:54:0B:F0:D9:83:D5:C6:70:9D:BC:4F:22
sig_hashalgo:   sha256
parm:           max_bonds:Max number of bonded devices (int)
parm:           tx_queues:Max number of transmit queues (default = 16) (int)
parm:           num_grat_arp:Number of peer notifications to send on failover event (alias of num_unsol_na) (int)
parm:           num_unsol_na:Number of peer notifications to send on failover event (alias of num_grat_arp) (int)
parm:           miimon:Link check interval in milliseconds (int)
parm:           updelay:Delay before considering link up, in milliseconds (int)
parm:           downdelay:Delay before considering link down, in milliseconds (int)
parm:           use_carrier:Use netif_carrier_ok (vs MII ioctls) in miimon; 0 for off, 1 for on (default) (int)
parm:           mode:Mode of operation; 0 for balance-rr, 1 for active-backup, 2 for balance-xor, 3 for broadcast, 4 for 802.3ad, 5 for balance-tlb, 6 for balance-alb (charp)
parm:           primary:Primary network device to use (charp)
parm:           primary_reselect:Reselect primary slave once it comes up; 0 for always (default), 1 for only if speed of primary is better, 2 for only on active slave failure (charp)
parm:           lacp_rate:LACPDU tx rate to request from 802.3ad partner; 0 for slow, 1 for fast (charp)
parm:           ad_select:802.3ad aggregation selection logic; 0 for stable (default), 1 for bandwidth, 2 for count (charp)
parm:           min_links:Minimum number of available links before turning on carrier (int)
parm:           xmit_hash_policy:balance-xor and 802.3ad hashing method; 0 for layer 2 (default), 1 for layer 3+4, 2 for layer 2+3, 3 for encap layer 2+3, 4 for encap layer 3+4 (charp)
parm:           arp_interval:arp interval in milliseconds (int)
parm:           arp_ip_target:arp targets in n.n.n.n form (array of charp)
parm:           arp_validate:validate src/dst of ARP probes; 0 for none (default), 1 for active, 2 for backup, 3 for all (charp)
parm:           arp_all_targets:fail on any/all arp targets timeout; 0 for any (default), 1 for all (charp)
parm:           fail_over_mac:For active-backup, do not set all slaves to the same MAC; 0 for none (default), 1 for active, 2 for follow (charp)
parm:           all_slaves_active:Keep all frames received on an interface by setting active flag for all slaves; 0 for never (default), 1 for always. (int)
parm:           resend_igmp:Number of IGMP membership reports to send on link failure (int)
parm:           packets_per_slave:Packets to send per slave in balance-rr mode; 0 for a random slave, 1 packet per slave (default), >1 packets per slave. (int)
parm:           lp_interval:The number of seconds between instances where the bonding driver sends learning packets to each slaves peer switch. The default is 1. (uint)
```

- 步骤：1创建bond接口文件

```bash
$ cat /etc/sysconfig/network-scripts/ifcfg-bond0
DEVICE=bond0
TYPE=Bond
NAME=bond0
BONDING_MASTER=yes
BOOTPROTO=none
ONBOOT=yes
IPADDR=192.168.1.70
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
BONDING_OPTS="mode=5 miimon=100"
```

- 步骤：2编辑NIC接口文件

```bash
# ifcfg-enp0s3
[root@openstack ~]# vi /etc/sysconfig/network-scripts/ifcfg-enp0s3
TYPE=Ethernet
BOOTPROTO=none
DEVICE=enp0s3
ONBOOT=yes
HWADDR="08:00:27:69:60:c9"
MASTER=bond0
SLAVE=yes

# ifcfg-enp0s8
[root@openstack ~]# cat /etc/sysconfig/network-scripts/ifcfg-enp0s8
TYPE=Ethernet
BOOTPROTO=none
DEVICE=enp0s8
ONBOOT=yes
HWADDR="08:00:27:ea:71:8d"
MASTER=bond0
SLAVE=yes
```

- 步骤：3重新启动网络服务

```bash
root@openstack ~]# systemctl restart network.service
```

- 步骤：4测试和验证绑定界面。

```bash
# ifcofnig

# cat /proc/net/bonding/bond0
```

- 步骤：5容错测试

```bash
$ ifdown enp0s8
# 查看网络bond0状态
```











