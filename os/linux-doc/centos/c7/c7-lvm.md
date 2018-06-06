# 安装完成CentOS7 后对初始化LVM

## 卸载hone

```bash
umount /dev/mapper/centos-home
lvremove /dev/centos/home
# 编辑fstab 删除挂载home的配置文件
```

## 安装软件包
yum install xfsprogs -y 

# 重新格式化挂载分区（类似mkfs.ext4）
mkfs.xfs -f /dev/cl_kvm-centos7/data

# 重新resize分区
/dev/mapper/cl_kvm--centos7-var
 
# 重载
xfs_growfs /dev/mapper/cl-data

# 删除VG


