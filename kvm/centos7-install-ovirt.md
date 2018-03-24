# oVirt安装使用

- 环境准备，CentOS6 192.168.0.222 aniu-ovirt

```
echo -e "192.168.0.222 aniu-ovirt\n" >> /etc/hosts
```

> oVirt官方文档

```
- http://www.ovirt.org/documentation/
- http://www.ovirt.org/documentation/quickstart/quickstart-guide/#for-each-host-ovirt-node-fedora-host-centos-host
```

- oVirt安装

```
yum install http://resources.ovirt.org/pub/yum-repo/ovirt-release36.rpm
yum -y install ovirt-engine
```

- engine-setup

- 一路默认（个别自定义）# 这里不过多介绍

- 安装完成浏览器访问

https://ovirt.aniu.tv/ovirt-engine # ovirt.aniu.tv 是oVirt交互式安装时自定义的域名

![ovirt-admin](http://img.blog.csdn.net/20170819154709271?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 登录管理门户，用户名admin，密码为交互式安装时候设置的密码

![access-ovirt](http://img.blog.csdn.net/20170819154839052?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

## 安装主机

- 先把本机加入集群，进入管理页面后，左树依次展开找到“主机”，然后“新建”，填入本机参数（笔者环境防火墙都是禁止状态，所以就不自动配置防火墙了）。

![add-host](http://img.blog.csdn.net/20170819155807233?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 添加hosts过程需要等待，可以查看下ovirt的日志，看运行是否正常：

```
cd /var/log/ovirt-engine/

tailf server.log 
tailf engine.log
# 注意：笔者的环境 server.log 日志有下面报错
2017-08-19 15:56:46,388 WARN  [org.apache.sshd.client.channel.ChannelExec] (pool-12-thread-3) Unknown channel request: keepalive@openssh.com
2017-08-19 15:56:52,789 WARN  [org.apache.sshd.client.session.ClientConnectionService] (pool-12-thread-3) Unknown global request: keepalive@openssh.com

```

> 根据上面两个日志的输出，可以看出ovirt运行过程中是否出现了问题。

- 新建集群，并添加一台主机测试

![devops-cluster](http://img.blog.csdn.net/20170819161647836?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)











