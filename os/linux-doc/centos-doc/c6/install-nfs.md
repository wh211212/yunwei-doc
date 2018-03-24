# CentOS6 安装nfs

> 配置nfs服务器在局域网内共享目录

```
nfs-server: .aniu.so 192.168.0.99
nfs-client: jenkins.aniu.so 192.168.0.103
```

## 配置nfs服务

```
[root@zabbix ~]# yum -y install nfs-utils
[root@zabbix ~]# vi /etc/idmapd.conf
# line 5: 取消注释，更改为自己定义的域名
Domain = aniu.so
[root@zabbix ~]# vi /etc/exports
# 编辑需要共享的目录及权限
/media 192.168.0.0/24(rw,no_root_squash)
[root@zabbix ~]# /etc/rc.d/init.d/rpcbind start
Starting rpcbind:                         [  OK  ]
[root@zabbix ~]# /etc/rc.d/init.d/nfs start
Starting NFS services:                    [  OK  ]
Starting NFS mountd:                      [  OK  ]
Starting NFS daemon:                      [  OK  ]
Starting RPC idmapd:                      [  OK  ]
[root@zabbix ~]# chkconfig rpcbind on
[root@zabbix ~]# chkconfig nfs on
```

## 启用iptables情况下做以下设置：

```
[root@zabbix ~]# vi /etc/sysconfig/nfs
# line 20,22: uncomment
LOCKD_TCPPORT=32803
LOCKD_UDPPORT=32769
# line 57: uncomment
MOUNTD_PORT=892
# line 63: uncomment
STATD_PORT=662
[root@zabbix ~]# /etc/rc.d/init.d/rpcbind restart
[root@zabbix ~]# /etc/rc.d/init.d/nfs restart
# allow 111, 2049 and fixed ports above
[root@zabbix ~]# for port in 111 662 892 2049 32803; do iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport $port -j ACCEPT; done
[root@zabbix ~]# for port in 111 662 892 2049 32769; do iptables -I INPUT 6 -p udp -m state --state NEW -m udp --dport $port -j ACCEPT; done
```

## nfs客户端安装

- 配置nfs客户端

```
[root@jenkins ~]# yum -y install nfs-utils
[root@jenkins ~]# vi /etc/idmapd.conf
# line 5: 取消注释，更改为自己定义的域名
Domain = aniu.so
[root@jenkins ~]# /etc/rc.d/init.d/rpcbind start
Starting rpcbind:                        [  OK  ]
[root@jenkins ~]# /etc/rc.d/init.d/netfs start
Mounting filesystems:                    [  OK  ]

[root@jenkins ~]# chkconfig rpcbind on
[root@jenkins ~]# chkconfig netfs on
# 修改服务器hosts
[root@jenkins ~]# echo "192.168.0.99 zabbix.aniu.so" >> /etc/hosts
[root@jenkins ~]# mount -t nfs zabbix.aniu.so:/media /media
[root@jenkins ~]# df -hT
Filesystem           Type   Size  Used Avail Use% Mounted on
/dev/mapper/VolGroup-lv_root
                     ext4    44G   20G   22G  48% /
tmpfs                tmpfs  4.9G   12K  4.9G   1% /dev/shm
/dev/xvda1           ext4   477M  153M  299M  34% /boot
zabbix.aniu.so:/media
                     nfs     59G   10G   47G  18% /media  # 可以看到共享目录我们已经挂载jenkins服务器，jenkins可以正常访问media目录的内容
```
