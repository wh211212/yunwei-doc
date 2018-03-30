# CentOS7 安装并使用Ovirt 4.2

## Ovirt 4.2 安装

> 参考：http://blog.csdn.net/wh211212/article/details/77413178
> 参考：http://blog.csdn.net/wh211212/article/details/79412081（需要使用）

- 环境准备，两台主机

>
>  禁用selinux，关闭防火墙
> 10.1.1.2 （ovirt-engine+GlusterFS）
10.1.1.3  （GlusterFS+nfs）


- hosts设置

```
10.1.1.2 ovirt.aniu.so server1
10.1.1.3 nfs.aniu.so docker.aniu.so server2
```
- Ovirt官网文档：

> http://www.ovirt.org/documentation/

- oVirt安装

```
yum install http://resources.ovirt.org/pub/yum-repo/ovirt-release42.rpm
yum -y install ovirt-engine
```
> 安装过程全部使用默认，建议使用默认

- 在两台主机server1,server2上安装ovirt node

```
#
yum install http://resources.ovirt.org/pub/yum-repo/ovirt-release42.rpm
yum -y install vdsm
```

## 配置Ovirt 

- 安装完成，通过浏览器访问https://ovirt.aniu.so/ovirt-engine/

![这里写图片描述](http://img.blog.csdn.net/20180305090738953?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

- 登录ovirt UI，用户名 admin，密码是安装过程中设置的密码

![这里写图片描述](http://img.blog.csdn.net/2018030509084654?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

## 使用Ovirt创建虚拟机

- 创建数据中心

![这里写图片描述](http://img.blog.csdn.net/20180305091046327?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

> 存储类型选择共享的，类型选择本地，每个数据中心下面只能添加一个主机，不采用这种方式

- 创建集群

![这里写图片描述](http://img.blog.csdn.net/20180305091249464?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

> 假如有多个数据中心，创建集群的时候选择在那个数据中心下面创建，根据使用选择CPU架构，其他默认即可

- 添加主机

![这里写图片描述](http://img.blog.csdn.net/20180305091511791?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

> 添加主机时注意关闭自动配置防火墙选项，在高级设置里面，使用root账号 密码即可，添加主机过程可以查看，事件查看安装过程

- 查看添加完成的主机

![这里写图片描述](http://img.blog.csdn.net/20180305091754543?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)
![这里写图片描述](http://img.blog.csdn.net/20180305091847584?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

## 添加存储

- 添加nfs data存储域，用于创建虚拟机

![这里写图片描述](http://img.blog.csdn.net/20180305092022915?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

> 标注的地方都需要修改，注意根据自己的配置填入对应的

- 添加iso存储域，用于存放镜像文件

![这里写图片描述](http://img.blog.csdn.net/20180305092212364?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

- 添加glusterfs data 存储域，高可用 用于创建虚拟机

![这里写图片描述](http://img.blog.csdn.net/20180305092336328?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

- 添加系统镜像文件

```
# 使用命令
先把镜像文件上传到服务器上，执行上传命令
engine-iso-uploader --nfs-server=nfs.aniu.so:/export/iso upload /usr/local/src/CentOS-7-x86_64-Minimal-1611.iso
# 或者通过filezilla上传到服务的 data存储域目录下。然后到移动到正确的位置
```
![这里写图片描述](http://img.blog.csdn.net/20180305093055456?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

## 创建虚拟机

![这里写图片描述](http://img.blog.csdn.net/20180305093210467?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

![这里写图片描述](http://img.blog.csdn.net/20180305093301787?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

> 添加硬盘的时候可以选择不同的data存储域

- 运行虚拟机

> 这里笔者安装ovirt-engine的服务器安装了桌面环境，然后通过VNC远程进行虚拟的安装，不安装系统桌面时，笔者配置完虚拟机运行后，通过console不能连上去，会让下载vv格式的文件，很烦，安装桌面配置VNC笔者这里不过多赘述

![这里写图片描述](http://img.blog.csdn.net/20180305093724416?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)
![这里写图片描述](http://img.blog.csdn.net/2018030509382258?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

- 虚拟机在线迁移

![这里写图片描述](http://img.blog.csdn.net/20180305093912513?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

> 迁移的时候选择要迁移到的主机，注意：不同数据中心下面的虚拟机不能迁移

## ovirt备份

> 参考：https://www.ovirt.org/documentation/admin-guide/chap-Backups_and_Migration/

```
engine-backup --scope=all --mode=backup --file=ovirt-backup.txt --log=/var/log/ovirt-engine/ovirt-engine.log
```

> 笔者安装配置遇到的问题：

- 存储域添加完成后不知道如何删除