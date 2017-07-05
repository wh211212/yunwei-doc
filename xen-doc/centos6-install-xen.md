https://wiki.centos.org/zh/HowTos/Xen/Xen4QuickStart
# xen 安装
cat /proc/cpuinfo 确定支持虚拟化（pae）

yum install centos-release-xen -y
3.  yum update ，查看/etc/grub.conf是否成功安装新的内核，reboot并使用新的内核
4. yum install xen ，查看/etc/grub.conf是否添加了xen的参数


在安装 Xen 及内核的过程中，一个名叫 grub-bootxen.sh 的脚本应已被执行，它会更新 grub 的设置（CentOS 6 是 /boot/grub/grub.conf，CentOS 7 是 /boot/grub2/grub.cfg）。在 CentOS 6，假若你查看 /boot/grub/grub.conf，它应该含有类似以下的内容：

yum install libvirt python-virtinst libvirt-daemon-xen

#  配置桥接网络

配置ifcfg-br0
DEVICE=br0
TYPE=Bridge
ONBOOT=yes
BOOTPROTO=none
IPADDR=192.168.0.67
NETMASK=255.255.255.0
GATEWAY=192.168.0.1
DEFROUTE=yes

配置ifcfg-em1
DEVICE=em1
HWADDR=14:18:77:40:29:D3
TYPE=Ethernet
UUID=1bd441dd-0d5a-444e-b158-718a03770484
ONBOOT=yes
BRIDGE=br0
BOOTPROTO=none
#IPADDR=192.168.0.67
#NETMASK=255.255.255.0
#GATEWAY=192.168.0.1

lvcreate -n db_master -L 20G vg_fzxen1
virt-install -d -n db_master -r 4096 --vcpus=3 --disk /dev/vg_fzxen4/fz_db_master --nographics -p -l "http://192.168.0.48/os/centos6.7/" --extra-args="text console=com1 utf8 console=hvc0"
#
xm block-attach db_master phy:/dev/vg_fzxen4/db_master_data /dev/xvdb w
xm console TestVM2
 fdisk /dev/xvdb
挂载lvm
mkfs.ext4 /dev/xvdb1
pvcreate /dev/xvdb1
vgextend VolGroup /dev/xvdb1
lvcreate -n data -L 99G VolGroup
mkdir /data
mkfs.ext4 /dev/VolGroup/data
lvextend -L +1020M /dev/VolGroup/data
resize2fs /dev/VolGroup/data
mount /dev/VolGroup/data  /data/

echo "/dev/mapper/VolGroup-data    /data                   ext4    defaults        1 1" >> /etc/fstab

# 安装脚本


#!/bin/bash
# functions: secure_config


virt-install -d -n api-1 -r 4096 --vcpus=4 --prompt --disk /dev/vg_xen2/api-1 --nographics -p -l http://mirrors.aliyun.com/centos/6.9/os/x86_64/ --extra-args="text console=com1 utf8 console=hvc0"

virt-install -d -n crm-cas-admin -r 8192 --vcpus=4 --prompt --disk /dev/vg_xen1/crm-cas-admin --nographics -p -l http://mirrors.aliyun.com/centos/6.8/os/x86_64/ --extra-args="text console=com1 utf8 console=hvc0"


# virt-clone
virt-clone --original elk-stack-1 --name elk-stack-2 --file /dev/vg_xenold2/elk-stack-2

# xen generel command
# add disk to guest

virsh attach-disk aniu-co-1 /dev/vg_xen1/aniu-co-data xvdb

xl list
xl info
virsh console gusetos
virsh shutdown guestos
virsh undefine guestos

#
virt-install \
--connect xen:/// \
--paravirt \
--name centos7 \
--ram 4096 \
--disk path=/dev/vg_kvmelk/centos7 \
--vcpus 4 \
--os-type linux \
--os-variant rhel7 \
--network bridge=br0 \
--graphics none \
--location 'http://ftp.iij.ad.jp/pub/linux/centos/7/os/x86_64/' \
--extra-args 'text console=com1 utf8 console=hvc0'
