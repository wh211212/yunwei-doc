# add mariadb repo

> 参考地址： https://downloads.mariadb.org/mariadb/repositories

- 创建mariadb源

```bash
[root@jumpserver ~]# cat /etc/yum.repos.d/MariaDB.repo 
# MariaDB 10.2 CentOS repository list - created 2018-03-19 15:21 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.2/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
```

- 安装mariadb

```bash
sudo yum install MariaDB-server MariaDB-client
```
