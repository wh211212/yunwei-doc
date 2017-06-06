# tysx-prod-1

1、（192.168.76.100） 更改主机名为tysx-prod-1

2、执行cmd_track

bash cmd_track_install.sh


#
yum install php haproxy keepalived -y

3、挂载目录

lvcreate -n log -L 100G vg0
lvcreate -n data -L 100G vg0

mkfs.ext4 /dev/vg0/data
mkfs.ext4 /dev/vg0/log

/dev/mapper/vg0-log /var                       ext4    defaults        1 1
/dev/mapper/vg0-data /data                       ext4    defaults        1 1

4、安装依赖包
yum -y install rsync wget vim openssh-clients iftop iotop sysstat  lsof telnet traceroute htop  gcc-c++ tree man iptraf lrzsz net-tools  dstat tree ntp dos2unix

5、




# tysx-prod-2
