virsh# xen虚拟机挂载硬盘

## 使用virsh命令挂载

- 1、创建一块大小100G的lvm卷

```
lvcreate -n api2-data -L 100G vg_xen3
```

- 2、dump一份虚拟机的配置文件，保存到用户家目录

```
virsh dumpxml api-2 > ~/api-2.xml
```

- 3、打开虚拟机（api-2）配置文件，扎到<disk>标签位置，查看当前硬盘的标签内内容如下：

```
<disk type='block' device='disk'>
  <source dev='/dev/vg_xen3/api-2'/>
  <target dev='xvda' bus='xen'/>
</disk>
```

- 4、重新编辑虚拟机配置文件，添加一个<disk>标签，更改之后为：

```
<disk type='block' device='disk'>
  <source dev='/dev/vg_xen3/api-2'/>
  <target dev='xvda' bus='xen'/>
</disk>
<disk type='block' device='disk'>
  <source dev='/dev/vg_xen1/nexus-data'/>
  <target dev='xvdb' bus='xen'/>
</disk>
# 注意dev的名字要修改 #
```

- 5、重启创建虚拟机

```
# 使用xl或者virsh把虚拟机停掉
xl shutodwn api-2
virsh shutdown api-2
# 使用virsh重新加载虚拟机配置文件

virsh start api-2 # 建议使用 start的方式
# 或者使用create
mv /etc/libvirt/libxl/apiserver1.xml /tmp/

virsh create ~/api-2.xml  # 亲测可用
```

- 6、连接虚拟机查看应按挂载

```
virsh console api-2 # 从Dom0上连接到guest
# 查看硬盘
[root@localhost ~]# fdisk -l

Disk /dev/xvda: 21.5 GB, 21474836480 bytes
255 heads, 63 sectors/track, 2610 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x0001a1cf

    Device Boot      Start         End      Blocks   Id  System
/dev/xvda1   *           1          64      512000   83  Linux
Partition 1 does not end on cylinder boundary.
/dev/xvda2              64        2611    20458496   8e  Linux LVM

Disk /dev/xvdb: 107.4 GB, 107374182400 bytes  # 可以看到硬盘已经挂载上去
255 heads, 63 sectors/track, 13054 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000
```

> 注意事项： 按住Ctrl+] 键退出虚拟机

# 关于 xl命令 和 virsh命令

> 博主使用virsh安装虚拟机，安装三台guest，分别为api-1,api-2,api-3、安装完成之后重启xen服务器，重新使用virsh list --all 查看虚拟机报错，因为初始libvirtd起不来，笔者在rc.local中设置自启，可以使用virsh list --all 查看虚拟机状态，状态为如下：

[root@xen-3 ~]# virsh list --all
 Id    Name                           State
----------------------------------------------------
 0     Domain-0                       running
 1     api-1                          running
 -     api-2                          shut off
 -     api-3                          shut off

[root@xen-3 ~]# xl list --all
option `' not supported.
Name                                        ID   Mem VCPUs	State	Time(s)
Domain-0                                     0  2045    12     r-----      51.0
api-1                                        1  4096     4     -b----      12.6
api-2                                        2     0     0     --p---       0.0   # 没启动成功，不知道为什么，下次重启 有可能api-1起不来，这里困扰两个礼拜啦
api-3                                        5  4096     4     -b----       0.2

使用xl list 查看状态如下：

> 分析： xen服务器使用virsh命令安装的虚拟机重启时 xl和virsh命令都会对虚拟机进行操作，一般是xl命令起作用

- 故障尝试修复：

libvirtd 服务无缘无故停掉。

xl list 查看虚拟机状态不正常

# 加到lvm组中

挂载lvm
mkfs.ext4 /dev/xvdb1
pvcreate /dev/xvdb1
vgextend VolGroup /dev/xvdb1
lvcreate -n data -L 49G VolGroup
mkdir /data
mkfs.ext4 /dev/VolGroup/data
mount /dev/VolGroup/data  /data/

echo "/dev/mapper/VolGroup-data    /data                   ext4    defaults        1 1" >> /ets/fstab

# 扩大lvm卷（root）
[root@jenkins ~]# lvextend -l +100%FREE /dev/mapper/VolGroup-lv_root
[root@jenkins ~]# resize2fs /dev/mapper/VolGroup-lv_root
[root@jenkins ~]# df -h
Filesystem            Size  Used Avail Use% Mounted on
/dev/mapper/VolGroup-lv_root
                      103G   40G   58G  41% /
tmpfs                 4.9G   12K  4.9G   1% /dev/shm
/dev/xvda1            477M  153M  299M  34% /boot

> 扩容成功
