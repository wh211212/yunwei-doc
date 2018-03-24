# aniu-saas 创建虚拟机

[root@aniu-saas ~]# lvcreate -n aniu-saas-5 -L 50G cl


virt-install -d --virt-type=kvm --name=aniu-saas-5  --vcpus=2 --memory=4096 --location=/media/CentOS-7-x86_64-Minimal-1611.iso --disk path=/dev/cl/aniu-saas-5 --network bridge=br0 --graphics none --extra-args='console=ttyS0' --force

