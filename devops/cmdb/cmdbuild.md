# CMDBuild 部署与使用

> CMDBuild是信息技术部门的ERP

- CMDBuild官网：CMDBuild

## 环境准备

> CentOS6，JDK+tomcat、postgresql（9.6.x）

- 下载最新版CMDBuild及相关软件

```bash
# 参考：http://www.cmdbuild.org/en/download
https://nchc.dl.sourceforge.net/project/cmdbuild/2.5.0/cmdbuild-2.5.0.zip -P /usr/local/src
https://sourceforge.net/projects/cmdbuild/files/2.5.0/shark-cmdbuild-2.5.0.zip -P /usr/local/src
# additional-report-libs-1.5.zip,
```

- 安装JDK环境及tomcat

```bash
yum install java-1.8.0-openjdk -y
yum install apache-tomcat # 参数自己配置
```

- 安装PostgreSQL 9.6

```bash

# 配置PostgreSQL源，参考http://blog.csdn.net/wh211212/article/details/79627984
yum install https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-6-x86_64/pgdg-centos96-9.6-3.noarch.rpm
yum install postgresql96 -y
```

- 新建数据库








