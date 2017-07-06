# xen 命令行工具介紹

> 參考：https://wiki.centos.org/zh/HowTos/Xen/Xen4QuickStart/Xen4Cli

# 使用xl在CentOS-6 Dom0机器上创建CentOS-6和CentOS-7 DomU的基本示例

- 查看xen信息

```
[root@xen-2 ~]# xl info
host                   : xen-2
release                : 4.9.25-27.el6.x86_64
version                : #1 SMP Wed May 3 14:13:47 UTC 2017
machine                : x86_64
nr_cpus                : 12
max_cpu_id             : 143
nr_nodes               : 2
cores_per_socket       : 6
threads_per_core       : 1
cpu_mhz                : 1600
hw_caps                : bfebfbff:2c100800:00000000:00007f00:77fefbff:00000000:00000021:000037ab
virt_caps              : hvm hvm_directio
total_memory           : 16159
free_memory            : 9797
sharing_freed_memory   : 0
sharing_used_memory    : 0
outstanding_claims     : 0
free_cpus              : 0
xen_major              : 4
xen_minor              : 6
xen_extra              : .3-14.el6
xen_version            : 4.6.3-14.el6
xen_caps               : xen-3.0-x86_64 xen-3.0-x86_32p hvm-3.0-x86_32 hvm-3.0-x86_32p hvm-3.0-x86_64
xen_scheduler          : credit
xen_pagesize           : 4096
platform_params        : virt_start=0xffff800000000000
xen_changeset          : Tue May 2 12:06:15 2017 +0100 git:52d94f1-dirty
xen_commandline        : dom0_mem=2048M,max:2048M cpuinfo com1=115200,8n1 console=com1,tty loglvl=all guest_loglvl=all
cc_compiler            : gcc (GCC) 4.4.7 20120313 (Red Hat 4.4.7-18)
cc_compile_by          : mockbuild
cc_compile_domain      : centos.org
cc_compile_date        : Tue May  2 12:16:10 UTC 2017
xend_config_format     : 4
```

> 本博文中，我们假定一个桥名为br0。所有虚拟机将使用此桥。以下是CentOS-6中此配置中使用的配置文件：

```
# 網卡配置
[root@xen-2 ~]# cat /etc/sysconfig/network-scripts/ifcfg-em1
DEVICE=em1
HWADDR=14:18:77:40:A9:59
TYPE=Ethernet
UUID=83cd8475-dc38-4b7f-a235-5f0820075082
ONBOOT=yes
BRIDGE=br0
BOOTPROTO=none
# 網橋網卡配置
[root@xen-2 ~]# cat /etc/sysconfig/network-scripts/ifcfg-br0
DEVICE=br0
TYPE=Bridge
ONBOOT=yes
BOOTPROTO=none
IPADDR=192.168.0.66
NETMASK=255.255.255.0
# PREFIX=24
GATEWAY=192.168.0.1
DNS1=114.114.114.114
DEFROUTE=yes
# IPV6INIT=no
# NM_CONTROLLED="no" 實時網卡配置生效
```

- 查看網絡配置信息

ifconfig -a

> 使用lvm創建空閒lv用來安裝DomU,查看vg看剩餘的空間進行合理劃分使用

```
[root@xen-2 ~]# vgdisplay
  --- Volume group ---
  VG Name               vg_xen2
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  7
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                5
  Open LV               5
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               557.59 GiB
  PE Size               4.00 MiB
  Total PE              142743
  Alloc PE / Size       39424 / 154.00 GiB
  Free  PE / Size       103319 / 403.59 GiB
  VG UUID               zib5Qm-JCPh-GiLc-nCUx-5pbT-hybY-QJjEX9
# 可以看出還有403.59 GiB可以使用
```

> 創建兩個20GB 的lv用來安裝DomU

```
[root@xen-2 ~]# lvcreate -L 20G -n c6-x8664-hvm vg_xen2
  Logical volume "c6-x8664-hvm" created.
[root@xen-2 ~]# lvcreate -L 20G -n c7-x8664-hvm vg_xen2
  Logical volume "c7-x8664-hvm" created.
```

- 查看lvdisplay

```
--- Logical volume ---
LV Path                /dev/vg_xen2/c6-x8664-hvm
LV Name                c6-x8664-hvm
VG Name                vg_xen2
LV UUID                kfhWE4-0LRz-e9IH-udN9-aPs1-HP2X-A83vZi
LV Write Access        read/write
LV Creation host, time xen-2, 2017-06-22 18:24:57 +0800
LV Status              available
# open                 0
LV Size                20.00 GiB
Current LE             5120
Segments               1
Allocation             inherit
Read ahead sectors     auto
- currently set to     256
Block device           253:5

--- Logical volume ---
LV Path                /dev/vg_xen2/c7-x8664-hvm
LV Name                c7-x8664-hvm
VG Name                vg_xen2
LV UUID                mEMjYg-8KvL-i2ig-Gn3q-idCQ-EtU5-layZUo
LV Write Access        read/write
LV Creation host, time xen-2, 2017-06-22 18:25:20 +0800
LV Status              available
# open                 0
LV Size                20.00 GiB
Current LE             5120
Segments               1
Allocation             inherit
Read ahead sectors     auto
- currently set to     256
Block device           253:6
#
```
> 使用CentOS IOS安裝，創建/opt/isos/ 存放下載的CentOS-6.8-x86_64-minimal.iso and CentOS-7-x86_64-Minimal-1611.iso，下載地址：http://isoredirect.centos.org/centos/6/isos/x86_64/
> http://isoredirect.centos.org/centos/7/isos/x86_64/

```
[root@xen-2 ~]# cd /opt/isos/
[root@xen-2 isos]# ll
total 1154052
-rw-r--r--. 1 root root 468713472 Jun 22 18:32 CentOS-6.8-x86_64-minimal.iso
-rw-r--r--. 1 root root 713031680 Jun 22 18:33 CentOS-7-x86_64-Minimal-1611.iso
```

- PV（paravirtualized半虚拟化）和HVM（fully virtualized完全虚拟化），本文中創建一個HVM

# 使用xl

> 创建一个完全虚拟化的CentOS-6和CentOS-7，首先需要VMs的配置文件，在xen包中有一个名为/etc/xen/xlexample.hvm的示例HVM配置文件。在/etc/xen下创建一个config.d的目录。存放我们的vm配置文件

```
# mkdir dir
mkdir /etc/xen/config.d
```
- /etc/xen/config.d/c6-x8664.hvm.cfg
```
builder = "hvm"
name = "c6-x8664.hvm"
memory = 4096
vcpus = 2
serial='pty'
vif = [ 'mac=00:16:3E:29:00:00,bridge=br0' ]
disk = [ 'phy:/dev/vg_xen2/c6-x8664-hvm,xvda,rw', 'file:/opt/isos/CentOS-6.8-x86_64-minimal.iso,xvdb:cdrom,r' ]
boot = "dc"
sdl = 0
vnc = 1
vnclisten  = "192.168.0.66"
vncdisplay = 1
vncpasswd  = "supersecret"
stdvga=1
videoram = 64
```
- /etc/xen/config.d/c7-x8664.hvm.cfg

```
builder = "hvm"
name = "c7-x8664.hvm"
memory = 4096
vcpus = 2
serial='pty'
vif = [ 'mac=00:16:3E:29:00:01,bridge=br0' ]
disk = [ 'phy:/dev/vg_xen2/c7-x8664-hvm,xvda,rw', 'file:/opt/isos/CentOS-7-x86_64-Minimal-1611.iso,xvdb:cdrom,r' ]
boot = "dc"
sdl = 0
vnc = 1
vnclisten  = "192.168.0.66"
vncdisplay = 1
vncpasswd  = "supersecret"
stdvga=1
videoram = 64
```

> 注： 配置文件需要注意的几点，vg_name, mac地址，vnclisten，确保这些信息都存在。

00:16:3E:6E:60:E1

## 这里vnclisten 搞不定

# 安装tigervnc-server

```
yum -y install tigervnc-server xsetroot xterm twm
[root@xen-2 ~]# vncpasswd
Password: # supersecret
Verify:
# 运行vnc server
vncserver :1 -geometry 800x600 -depth 24
# 停掉vnc server
vncserver -kill :1
```

# 安装realvnc

/etc/init.d/vncserver-x11-serviced start #initd
