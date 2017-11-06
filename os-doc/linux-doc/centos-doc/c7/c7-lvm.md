# 
yum install xfsprogs -y 

# 重新格式化挂载分区（类似mkfs.ext4）
mkfs.xfs -f /dev/cl_kvm-centos7/data

# 重新resize分区
 /dev/mapper/cl_kvm--centos7-var
 
# 重载
xfs_growfs /dev/mapper/cl-data
