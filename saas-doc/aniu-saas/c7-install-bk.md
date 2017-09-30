# 使用C7 kvm虚拟机安装蓝鲸平台

## 蓝鲸介绍

- 蓝鲸官网： http://bk.tencent.com/
- 蓝鲸社区版本下载：http://bk.tencent.com/download/
- 蓝鲸智云社区：http://bbs.bk.tencent.com/forum.php

## 蓝鲸安装准备

- 蓝鲸相关软件包（V3.1.5 Beta）及加密证书（内测版本需申请http://bk.tencent.com/download/#ssl）
- V3.1.5 Beta V3.1.5 install_ce-1.0.11 ssl_certificates.tar.gz
- 相关安装需关注蓝鲸公众号获取最新版本及获取方式，生成证书参考社区教程

> 参考笔者前一篇蓝鲸安装使用文章：http://blog.csdn.net/wh211212/article/details/56847030?locationNum=2&fps=1

## 系统环境准备

主机名 | IP地址 |系统版本| 模块角色|
:----------- | :-----------: | :-----------: | :-----------: 
aniu-saas-1    | 192.168.0.206       | CentOS7 |  nginx,appt,rabbitmq,kafka,zk,es,bkdata,consul,fta    
aniu-saas-2    | 192.168.0.207       | CentOS7 |  license,appo,kafka,zk,es,mysql,beanstalk,consul
aniu-saas-3    | 192.168.0.208       | CentOS7 |  paas,cmdb,job,gse,kafka,zk,es,consul,redis

> 这里注意：下载证书时， 需要同时填写部署 gse， license 的机器 MAC 地址。如果不放心，可以把三台服务器的mac地址都加上通过英文符号";"分割，建议安装的时候自信阅读官网文档

## c7系统初始化配置

- 设置三台服务器间可以ssh免密登录，不过多介绍
- 关闭SElinux ：sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
- 安装开发工具包：	yum	-y	groupinstall	"Development	Tools"
- 安装epel源: rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm (后面安装rabbitmnq-server时会用到)

## 安装步骤

### 配置域名解析

>  job , paas , cmdb 的域名配置 DNS 解析, 域名解析对应的 A 记录要求填写 nginx 所在机器的
ip 地址, 配置 DNS 时要使浏览器能访问,同时部署的服务器上也能访问对应的域名

- aniu-saas-1 （中控机）操作：

> 以下操作均在中控机执行：（会自动同步安装到另外两台）

```bash
[root@aniu-saas-1 data]# ll
total 1046960
-rw-r--r-- 1 root root 1069917253 Sep 30 16:11 bkce_src-3.1.5.tgz
-rw-r--r-- 1 root root    2137009 Sep 30 16:11 install_ce-1.0.11.tgz
-rw-r--r-- 1 root root      24757 Sep 30 16:11 ssl_certificates.tar.gz
[root@aniu-saas-1 data]# tar xf bkce_src-3.1.5.tgz 
[root@aniu-saas-1 data]# tar xf install_ce-1.0.11.tgz
[root@aniu-saas-1 data]# tar xf ssl_certificates.tar.gz -C ./src/cert/
```
- 准备相关配置文件

> 部署所需的基本配置文件都在install目录下：参考配置如下：

```bash
# aniu-saas-1
[root@aniu-saas-1 install]# cat install.config 
192.168.0.206 nginx,appt,rabbitmq,kafka,zk,es,bkdata,consul,fta
192.168.0.207 license,appo,kafka,zk,es,mysql,beanstalk,consul
192.168.0.208 paas,cmdb,job,gse,kafka,zk,es,consul,plugin,redis

```

> 注：1. 该配置⽂件,要保证逗号前后没有空⽩字符,⾏末没有空⽩字符, ip 后⾯使⽤空格与服务名
称隔开(不能使⽤ tab )
2. 含有多个内⽹ ip 的机器， install.config 中使⽤ /sbin/ifconfig 输出中的第⼀个内
⽹ ip
3. 在 ip 后⾯写上该机器要安装的服务列表即可.
4. nginx 与 cmdb 不能部署在同⼀台机器
5. gse 与 redis 需要部署在同⼀台机器上
6. gse 若需要跨云⽀持, gse 所在机器必须由外⽹ IP
6. 增加机器数量时, 可以将以上配置中的服务挪到新的机器上. 要保证: kafka , es , zk 的
每个组件的总数量为 3


- 根据实际情况修改global.env , ports.env

```bash
- ports.env 中可以配置各项服务的端⼝信息
- globals.env 配置⽂件中, 设定域名,账号密码等信息, 强烈建议修改掉默认值
- global.env 中配置的域名,必须保证可以在服务器上被解析到, 建议使⽤ DNS 进⾏配置,
域名解析对应的 A 记录要求填写 nginx 所在机器的 ip 地址.
若⽆ DNS 服务, 则,需要在安装蓝鲸服务的机器上都配置 hosts , 把 paas , job , cmdb 的
域名都指向 nginx 所在 ip , 
```
- 示例如下

> globals.env

```bash
[root@aniu-saas-1 install]# cat globals.env 
# vim:ft=sh

# 产品信息含义
#   PAAS    集成平台
#   CMDB    配置平台
#   JOB     作业平台
#   GSE     管控平台
#   BKDATA  数据平台

## environment variables

# 域名信息
export BK_DOMAIN="ops.aniu.so"           # 蓝鲸根域名(不含主机名)
export PAAS_FQDN="paas.$BK_DOMAIN"       # PAAS 完整域名
export CMDB_FQDN="cmdb.$BK_DOMAIN"       # CMDB 完整域名
export JOB_FQDN="job.$BK_DOMAIN"         # JOB 完整域名
export APPO_FQDN="o.$BK_DOMAIN"          # 正式环境完整域名
export APPT_FQDN="t.$BK_DOMAIN"          # 测试环境完整域名

# DB 信息
export MYSQL_USER="root"                 # mysql 用户名
export MYSQL_PASS="@Aniudb123."          # mysql 密码
export REDIS_PASS="@Aniuredis123."       # redis 密码

# 账户信息(建议修改)
export MQ_USER=admin
export MQ_PASS=aniumq
export ZK_USER=aniuzk
export ZK_PASS='anwg123.'

export PAAS_ADMIN_USER=admin
export PAAS_ADMIN_PASS=anwg123.

# 以下变量值不可以修改.每个企业统一
export IMAGE_NAME='bkbase/python:1.0'
You have new mail in /var/spool/mail/root
```
> hosts 配置
```bash
# saas
192.168.0.206 aniu-saas-1
192.168.0.207 aniu-saas-2
192.168.0.208 aniu-saas-3
# aniu-saas
192.168.0.206 paas.ops.aniu.so job.ops.aniu.so cmdb.ops.aniu.so
# 笔者的hosts配置文件
```

### 更改pip源

- 在aniu-saas-1上配置：

```bash
# vi src/.pip/pip.conf
[global]
index-url = http://mirrors.aliyun.com/pypi/simple
trusted-host = mirrors.aliyun.com
```

### 配置nginx repo

```bash
# 在aniu-saas-1 aniu-saas-3 上配置
rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
```

### 配置免密登陆

> 参考下面在任意一条服务器执行：

```bash
$	ssh-keygen	-t	rsa	-b	2048	(有确认提示,⼀直按回⻋即可)
$	cat	~/.ssh/id_rsa.pub	>	~/.ssh/authorized_keys
$	chmod	600	~/.ssh/authorized_keys
$	for	ip	in $(awk	'{print	$1}'	install.config	);	do
>					rsync	-a	~/.ssh/authorized_keys	root@$ip:/root/.ssh/;	
>	done
```

### 开始正式安装

> 安装过程的输出说明
- ⽩⾊: 普通输出
- 蓝⾊: 步骤说明
- ⻩⾊: 警告消息, 可忽略
- 红⾊: 失败提示,或者错误提示

> 笔者使用集成方式安装：

- 以下步骤若有报错/失败, 需要根据提示修复错误后, 重新执⾏

```bash
$	./bk_install	base_service		#	安装基础环境
$	./bk_install	bk_products		#	安装蓝鲸主要产品,	并初始化数据.
#	该步骤安装完成后,	可以通过浏览器打开蓝鲸了.	cmdb,	job	都应该能访问才算是正常
$	./bk_install	app_mgr		#	安装 开发者中⼼的	App	管理器
#	该步骤安装完成后,	可以在开发者中⼼的 服务器信息 和 第三⽅服务信息,	中看到已经成功激活的服务
器
# 此步骤可能会提示安装Rabbitmq失败，解决方法：

** yum install erlang -y # 安装Rabbitmq-server需要的环境 **

$	./bk_install	gse_agent				#	在所有机器上安装	gse_agent  
#	该步骤安装完成后,	可以在	CC	的资源池中看到安装蓝鲸的服务器	ip	列表，此步骤选择性执行，笔者执行的时候有些问题
```

> 笔者这里不介绍单步安装的方式，参考：http://www.cnblogs.com/Bourbon-tian/p/7607817.html

### 本地浏览器访问蓝鲸相关平台查看情况：

- 配置平台：http://cmdb.ops.aniu.so/

![这里写图片描述](http://img.blog.csdn.net/20171001071243558?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 工作台：http://paas.ops.aniu.so

![这里写图片描述](http://img.blog.csdn.net/20171001071349572?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

> 初始安装工作台只有配置平台和作业平台，后面功能组件是笔者手动安装上去的

- 作业平台：http://job.ops.aniu.so/
![这里写图片描述](http://img.blog.csdn.net/20171001071522404?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

### 安装总结

> 由于笔者之前安装过2.1版本的蓝鲸，因此这次安装过程比较顺利，建议初次尝试的同学，多阅读几遍官网安装文档，笔者后续会介绍蓝鲸的相关使用。










