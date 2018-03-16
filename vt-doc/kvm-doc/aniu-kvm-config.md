# aniu-saas 创建虚拟机

[root@aniu-saas ~]# lvcreate -n aniu-saas-5 -L 50G cl


virt-install --name aniu-saas-5 --ram 4096 --disk path=/dev/cl/aniu-saas-5 --vcpus 2 --os-type linux --os-variant rhel7 --network bridge=br0 --graphics none --console pty,target_type=serial --location 'http://mirrors.aliyun.com/centos/7/os/x86_64/' --extra-args 'console=ttyS0,115200n8 serial'
  
  
