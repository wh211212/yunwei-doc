# xen-1 安装虚拟机 （100GM 32CPU 600G）

- https://wiki.xenproject.org/wiki/Xen_Project_Beginners_Guide

- 创建lvs卷

```bash
[root@xen-1 ~]# lvcreate -n xen-1 -L 20G vg_xen1
  Logical volume "xen-1" created.
```

- 格式化卷

```bash
[root@xen-1 ~]# mkfs.ext4 /dev/vg_xen1/xen-1
```

## 安装虚拟机

- 标准：由于硬盘限制，创建的虚拟机默认使用20G硬盘（当前最小化）

```bash
# 使用命令安装
#virt-install -d -n xen-1 -r 8192 --vcpus=4 --prompt --disk /dev/vg_xen1/xen-1 --nographics -p -l http://mirrors.aliyun.com/centos/6.9/os/x86_64/ --extra-args="text console=com1 utf8 console=hvc0"

#virt-install -d -n xen-1-1 -r 8192 --vcpus=4 --disk /dev/vg_xen1/xen-1-1 --nographics -p -l "http://192.168.0.48/os/centos6.7/" --extra-args="text console=com1 utf8 console=hvc0"


# 这里根据自定义选择使用 内存8G 4核CPU作为web服务器
```

- 为vm xen-2 创建lv xen-2


```
# 笔者使用过上面的命令安装有问题 故使用下面命令
[root@xen-1 ~]# virt-install \
--connect xen:/// \
--paravirt \
--name xen-1-2 \
--ram 8192 \
--disk path=/dev/vg_xen1/xen-1-2 \
--vcpus 4 \
--os-type linux \
--os-variant rhel6 \
--network bridge=br0 \
--graphics none \
--location 'http://mirrors.aliyun.com/centos/6.9/os/x86_64/' \
--extra-args 'text console=com1 utf8 console=hvc0'
```

