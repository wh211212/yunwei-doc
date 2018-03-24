#  CentOS7 安装GlusterFS

## GlusterFS 介绍

> Gluster是一个大尺度文件系统。它是各种不同的存储服务器之上的组合，这些服务器由以太网或无限带宽技术Infiniband以及远程直接内存访问RDMA互相融汇，最终所形成的一个大的并行文件系统网络。它有包括云计算在内的多重应用，诸如：生物医药科学，文档存储。Gluster是由GNU托管的自由软件，证书是AGPL。Gluster公司是Gluster的首要商业赞助商，且提供商业产品以及基于Gluster的解决方案。

> Gluster是Client/Server架构。服务器典型的布置在存储砖上，每一台服务器运行一个名为glusterfsd 的守护进程，将本地文件系统作为卷进行输出。Gluster的客户端进程通过TCP/IP，InfiniBand或SDP一类客户协议连接到服务器，将远端卷组成一个大的所谓折叠式翻译器。最终的卷通过一种叫做FUSE的用户空间文件机制机载到客户机。有大量文件应用的I/O同样可以用libglusterfs 客户端库来直接连接服务器并内在的运行翻译器，而无需经过文件系统以及FUSE.大多数GlusterFS功能被实现为翻译器，包括了：

- 基于文件的镜像与赋值技术
- 基于文件的数据存储计算领域的数据带技术
- 基于文件的负载平衡技术
- 卷的双机备份技术
- 磁盘高速缓存技术以及排产技术
- 存储分配技术

##  GlusterFS安装

> 参考GlusterFS官方文档：http://docs.gluster.org/en/latest/Quick-Start-Guide/Quickstart/

### 至少两个节点

- 两台CentOS7，主机名为： server1 server2
- 两台主机网络互通
- 至少有两个虚拟磁盘，一个用于OS安装，另一个用于服务GlusterFS存储（sdb）（笔者使用lvm卷）

### 格式化并安装bricks

```
# server1，server2 执行
lvcreate -n glusterfs -L 50G centos
mkfs.xfs -i size=512 /dev/mapper/centos-glusterfs 
mkdir -p /data/brick1
echo '/dev/mapper/centos-glusterfs  /data/brick1 xfs defaults 1 2' >> /etc/fstab
mount -a && mount
```

### 安装GlusterFS

- 每一个节点安装GlusterFS

```bash
 yum install glusterfs-server -y
```

- 启动GlusterFS
```bash
[root@ovirt ~]# systemctl start glusterd
[root@ovirt ~]# systemctl status glusterd
● glusterd.service - GlusterFS, a clustered file-system server
   Loaded: loaded (/usr/lib/systemd/system/glusterd.service; disabled; vendor preset: disabled)
   Active: active (running) since Thu 2018-03-01 11:50:37 CST; 6s ago
  Process: 28808 ExecStart=/usr/sbin/glusterd -p /var/run/glusterd.pid --log-level $LOG_LEVEL $GLUSTERD_OPTIONS (code=exited, status=0/SUCCESS)
 Main PID: 28809 (glusterd)
   CGroup: /system.slice/glusterd.service
           └─28809 /usr/sbin/glusterd -p /var/run/glusterd.pid --log-level INFO

Mar 01 11:50:37 ovirt.aniu.so systemd[1]: Starting GlusterFS, a clustered file-system server...
Mar 01 11:50:37 ovirt.aniu.so systemd[1]: Started GlusterFS, a clustered file-system server.
```

- 如果开启防火需要配置防火墙

```bash
# iptables
iptables -I INPUT -p all -s <ip-address> -j ACCEPT

# firewalld
firewall-cmd --add-service=glusterfs --permanent  && firewall-cmd --reload
```

### 配置可信池

- server1

```bash
gluster peer probe server2
```

- 检查server1,server2上的对等状态
```bash
# server1
# gluster peer status
Number of Peers: 1

Hostname: server2
Uuid: 7529b9d2-f0c5-4702-9417-8d4cf6ca3247
State: Peer in Cluster (Connected)

# server2
# gluster peer status
Number of Peers: 1

Hostname: server1
Uuid: 7dcde0ed-f2fc-4940-a193-d69d02f356a5
State: Peer in Cluster (Connected)
```

### 设置一个GlusterFS卷

- 在server1和server2上执行

```bash
mkdir -p /data/brick1/gv0
```

- 从任意节点上执行：

```bash
# 在server1上执行
[root@ovirt ~]# gluster volume create gv0 replica 2 server1:/data/brick1/gv0 server2:/data/brick1/gv0
Replica 2 volumes are prone to split-brain. Use Arbiter or Replica 3 to avoid this. See: http://docs.gluster.org/en/latest/Administrator%20Guide/Split%20brain%20and%20ways%20to%20deal%20with%20it/.
Do you still want to continue?
 (y/n) y
volume create: gv0: success: please start the volume to access data
[root@ovirt ~]# gluster volume start gv0
volume start: gv0: success
```

- 确认volume“已启动”

```bash
[root@ovirt ~]# gluster volume info # 每个节点都可以执行
 
Volume Name: gv0
Type: Replicate
Volume ID: caab8c47-3617-4d13-900a-5d6ca300e034
Status: Started
Snapshot Count: 0
Number of Bricks: 1 x 2 = 2
Transport-type: tcp
Bricks:
Brick1: server1:/data/brick1/gv0
Brick2: server2:/data/brick1/gv0
Options Reconfigured:
transport.address-family: inet
nfs.disable: on
performance.client-io-threads: off
```

### 测试GlusterFS volume

- 在另外一台服务器上测试

```bash
# 安装glusterfs客户端软件
yum -y install glusterfs glusterfs-fuse
# 挂载
mount -t glusterfs server1:/gv0 /mnt
for i in `seq -w 1 100`; do cp -rp /var/log/messages /mnt/copy-test-$i; done
# 
```

- 检查挂载点

```bash
ls -lA /mnt/copy* | wc -l
```

> 你应该看到100个文件返回。接下来，检查每台服务器上的GlusterFS砖安装点：

```bash
# server1,server2上分别执行
ls -lA /data/brick1/gv0/copy* | wc -l
```
> 使用我们在此列出的方法在每台服务器上看到100个文件。如果没有复制，在分发卷（这里没有详细说明）中，每个卷上应该会看到大约50个文件。

## 架构

- 分布式卷

![这里写图片描述](https://cloud.githubusercontent.com/assets/10970993/7412364/ac0a300c-ef5f-11e4-8599-e7d06de1165c.png)

```
gluster volume create test-volume server1:/exp1 server2:/exp2 server3:/exp3 server4:/exp4
Creation of test-volume has been successful
Please start the volume to access data
#
#gluster volume info
Volume Name: test-volume
Type: Distribute
Status: Created
Number of Bricks: 4
Transport-type: tcp
Bricks:
Brick1: server1:/exp1
Brick2: server2:/exp2
Brick3: server3:/exp3
Brick4: server4:/exp4
```

- 复制Glusterfs卷

![这里写图片描述](https://cloud.githubusercontent.com/assets/10970993/7412379/d75272a6-ef5f-11e4-869a-c355e8505747.png)

```
# gluster volume create test-volume replica 2 transport tcp server1:/exp1 server2:/exp2
Creation of test-volume has been successful
Please start the volume to access data
```

- 分布式复制Glusterfs卷

![这里写图片描述](https://cloud.githubusercontent.com/assets/10970993/7412402/23a17eae-ef60-11e4-8813-a40a2384c5c2.png)

```
# gluster volume create test-volume replica 2 transport tcp server1:/exp1 server2:/exp2 server3:/exp3 server4:/exp4
Creation of test-volume has been successful
Please start the volume to access data
```
- 条纹Glusterfs卷
![这里写图片描述](https://cloud.githubusercontent.com/assets/10970993/7412387/f411fa56-ef5f-11e4-8e78-a0896a47625a.png)

```
# gluster volume create test-volume stripe 2 transport tcp server1:/exp1 server2:/exp2
Creation of test-volume has been successful
Please start the volume to access data
```

- 分布式条纹Glusterfs卷

![这里写图片描述](https://cloud.githubusercontent.com/assets/10970993/7412394/0ce267d2-ef60-11e4-9959-43465a2a25f7.png)

```
# gluster volume create test-volume stripe 4 transport tcp
 server1:/exp1 server2:/exp2 server3:/exp3 server4:/exp4 server5:/exp5 server6:/exp6 server7:/exp7 server8:/exp8
Creation of test-volume has been successful
Please start the volume to access data.
```

> 更多glusterfs资料请参考：http://docs.gluster.org/en/latest/Administrator%20Guide/overview/
