# xen 網橋配置

> 參考：https://wiki.centos.org/zh/HowTos/Xen/Xen4QuickStart/Xen4Networking6

yum install bridge-utils -y

- ifcfg-eth0

```
DEVICE=eth0
NM_CONTROLLED=no
ONBOOT=yes
TYPE=Ethernet
BRIDGE="br1"
USERCTL=no
```

- ifcfg-br1

```
DEVICE=br1
BOOTPROTO=none
NM_CONTROLLED=no
ONBOOT=yes
TYPE=Bridge
IPADDR=192.168.0.5
PREFIX=24
GATEWAY=192.168.0.1
DNS1=8.8.8.8
DNS2=8.8.4.4
USERCTL=no
```
