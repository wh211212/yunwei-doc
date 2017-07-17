# CentOS6 安装并破解Jira 7

> JIRA软件是为您的软件团队的每个成员构建的，用来规划，跟踪和发布优秀的软件。

> JIRA下载地址：https://www.atlassian.com/software/jira/download

https://confluence.atlassian.com/adminjiraserver074/installing-jira-applications-on-linux-881683168.html

## 最低硬件要求及软件安装

> 最小硬件依赖

- CPU: Quad core 2GHz+ CPU
- RAM: 6GB
- Minimum database space: 10GB
-------------------------------------

- 更新系统，安装java环境

```
# 注意：jira需要oracle的java,默认的openjdk是不行的
# http://www.oracle.com/technetwork/java/javase/downloads/index.html，下载jdk-8u131-linux-x64.rpm，然后上传到/usr/local/src
yum localinstall jdk-8u131-linux-x64.rpm -y
# 查看jdk是否安装成功
# java -version
java version "1.8.0_131"
Java(TM) SE Runtime Environment (build 1.8.0_131-b11)
Java HotSpot(TM) 64-Bit Server VM (build 25.131-b11, mixed mode)
```

- 安装mysql5.6,并创建jira数据库及jira用户，后面安装时会用到

> 注意：jira是支持5.7的，但是Confluence不支持5.7，所以这里安装mysql5.下载mysql的yum包 https://dev.mysql.com/downloads/ 安装

```
# 服务器配置mysql repo源，https://dev.mysql.com/downloads/repo/yum/，下载mysql57-community-release-el6-11.noarch.rpm然后上传到/usr/local/src
# 默认启用的是5.7，更改为5.6
[mysql56-community]
name=MySQL 5.6 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.6-community/el/7/$basearch/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

[mysql57-community]
name=MySQL 5.7 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/$basearch/
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
-----------------
# 安装mysql
yum clean all && yum install mysql-community-server -y
# 启动mysql并设置自启
# /etc/init.d/mysqld start
Initializing MySQL database:  2017-07-17 16:35:02 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
2017-07-17 16:35:02 0 [Note] Ignoring --secure-file-priv value as server is running with --bootstrap.
2017-07-17 16:35:02 0 [Note] /usr/sbin/mysqld (mysqld 5.6.36) starting as process 13639 ...
2017-07-17 16:35:02 13639 [Note] InnoDB: Using atomics to ref count buffer pool pages
2017-07-17 16:35:02 13639 [Note] InnoDB: The InnoDB memory heap is disabled
2017-07-17 16:35:02 13639 [Note] InnoDB: Mutexes and rw_locks use GCC atomic builtins
2017-07-17 16:35:02 13639 [Note] InnoDB: Memory barrier is not used
2017-07-17 16:35:02 13639 [Note] InnoDB: Compressed tables use zlib 1.2.3
2017-07-17 16:35:02 13639 [Note] InnoDB: Using Linux native AIO
2017-07-17 16:35:02 13639 [Note] InnoDB: Not using CPU crc32 instructions
2017-07-17 16:35:02 13639 [Note] InnoDB: Initializing buffer pool, size = 128.0M
2017-07-17 16:35:02 13639 [Note] InnoDB: Completed initialization of buffer pool
2017-07-17 16:35:02 13639 [Note] InnoDB: The first specified data file ./ibdata1 did not exist: a new database to be created!
2017-07-17 16:35:02 13639 [Note] InnoDB: Setting file ./ibdata1 size to 12 MB
2017-07-17 16:35:02 13639 [Note] InnoDB: Database physically writes the file full: wait...
2017-07-17 16:35:02 13639 [Note] InnoDB: Setting log file ./ib_logfile101 size to 48 MB
2017-07-17 16:35:02 13639 [Note] InnoDB: Setting log file ./ib_logfile1 size to 48 MB
2017-07-17 16:35:03 13639 [Note] InnoDB: Renaming log file ./ib_logfile101 to ./ib_logfile0
2017-07-17 16:35:03 13639 [Warning] InnoDB: New log files created, LSN=45781
2017-07-17 16:35:03 13639 [Note] InnoDB: Doublewrite buffer not found: creating new
2017-07-17 16:35:03 13639 [Note] InnoDB: Doublewrite buffer created
2017-07-17 16:35:03 13639 [Note] InnoDB: 128 rollback segment(s) are active.
2017-07-17 16:35:03 13639 [Warning] InnoDB: Creating foreign key constraint system tables.
2017-07-17 16:35:03 13639 [Note] InnoDB: Foreign key constraint system tables created
2017-07-17 16:35:03 13639 [Note] InnoDB: Creating tablespace and datafile system tables.
2017-07-17 16:35:03 13639 [Note] InnoDB: Tablespace and datafile system tables created.
2017-07-17 16:35:03 13639 [Note] InnoDB: Waiting for purge to start
2017-07-17 16:35:03 13639 [Note] InnoDB: 5.6.36 started; log sequence number 0
2017-07-17 16:35:05 13639 [Note] Binlog end
2017-07-17 16:35:05 13639 [Note] InnoDB: FTS optimize thread exiting.
2017-07-17 16:35:05 13639 [Note] InnoDB: Starting shutdown...
2017-07-17 16:35:07 13639 [Note] InnoDB: Shutdown completed; log sequence number 1625977


2017-07-17 16:35:07 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
2017-07-17 16:35:07 0 [Note] Ignoring --secure-file-priv value as server is running with --bootstrap.
2017-07-17 16:35:07 0 [Note] /usr/sbin/mysqld (mysqld 5.6.36) starting as process 13661 ...
2017-07-17 16:35:07 13661 [Note] InnoDB: Using atomics to ref count buffer pool pages
2017-07-17 16:35:07 13661 [Note] InnoDB: The InnoDB memory heap is disabled
2017-07-17 16:35:07 13661 [Note] InnoDB: Mutexes and rw_locks use GCC atomic builtins
2017-07-17 16:35:07 13661 [Note] InnoDB: Memory barrier is not used
2017-07-17 16:35:07 13661 [Note] InnoDB: Compressed tables use zlib 1.2.3
2017-07-17 16:35:07 13661 [Note] InnoDB: Using Linux native AIO
2017-07-17 16:35:07 13661 [Note] InnoDB: Not using CPU crc32 instructions
2017-07-17 16:35:07 13661 [Note] InnoDB: Initializing buffer pool, size = 128.0M
2017-07-17 16:35:07 13661 [Note] InnoDB: Completed initialization of buffer pool
2017-07-17 16:35:07 13661 [Note] InnoDB: Highest supported file format is Barracuda.
2017-07-17 16:35:07 13661 [Note] InnoDB: 128 rollback segment(s) are active.
2017-07-17 16:35:07 13661 [Note] InnoDB: Waiting for purge to start
2017-07-17 16:35:07 13661 [Note] InnoDB: 5.6.36 started; log sequence number 1625977
2017-07-17 16:35:07 13661 [Note] Binlog end
2017-07-17 16:35:07 13661 [Note] InnoDB: FTS optimize thread exiting.
2017-07-17 16:35:07 13661 [Note] InnoDB: Starting shutdown...
2017-07-17 16:35:09 13661 [Note] InnoDB: Shutdown completed; log sequence number 1625987




PLEASE REMEMBER TO SET A PASSWORD FOR THE MySQL root USER !
To do so, start the server, then issue the following commands:

  /usr/bin/mysqladmin -u root password 'new-password'
  /usr/bin/mysqladmin -u root -h sh-kvm-3-1 password 'new-password'

Alternatively you can run:

  /usr/bin/mysql_secure_installation

which will also give you the option of removing the test
databases and anonymous user created by default.  This is
strongly recommended for production servers.

See the manual for more instructions.

Please report any problems at http://bugs.mysql.com/

The latest information about MySQL is available on the web at

  http://www.mysql.com

Support MySQL by buying support/licenses at http://shop.mysql.com

Note: new default config file not created.
Please make sure your config file is current

WARNING: Default config file /etc/my.cnf exists on the system
This file will be read by default by the MySQL server
If you do not want to use this, either remove it, or use the
--defaults-file argument to mysqld_safe when starting the server

                                                           [  OK  ]
Starting mysqld:                                           [  OK  ]

# 初始化mysql并重置密码

```

## 添加MySQL Yum源

- 下载：http://dev.mysql.com/downloads/repo/yum/.（本文已CentOS为例）
