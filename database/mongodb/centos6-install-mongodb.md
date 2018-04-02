# CentOS 6 安装mongodb

- https://docs.mongodb.com/manual/installation/#tutorial-installation

## 安装MongoDB专业版

```bash
# 创建 /etc/yum.repos.d/mongodb-enterprise.repo
[mongodb-enterprise]
name=MongoDB Enterprise Repository
baseurl=https://repo.mongodb.com/yum/redhat/$releasever/mongodb-enterprise/3.4/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.4.asc

sudo yum install -y mongodb-enterprise

sudo service mongod start

sudo chkconfig mongod on 

sudo yum erase $(rpm -qa | grep mongodb-enterprise) # 卸载
```

## 安装mongodb社区版

```
#配置包管理系统

创建 /etc/yum.repos.d/mongodb-org-3.6.repo 

[mongodb-org-3.6]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.6/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.6.asc
```

- 安装MongoDB

```
sudo yum install -y mongodb-org
#
sudo yum install -y mongodb-org-3.6.3 mongodb-org-server-3.6.3 mongodb-org-shell-3.6.3 mongodb-org-mongos-3.6.3 mongodb-org-tools-3.6.3
```

- 启动MongoDB

```
sudo service mongod start
sudo chkconfig mongod on
sudo service mongod stop
```

- 使用MongoDB

```bash
mongo --host 127.0.0.1:27017
```

- 卸载删除MongoDB

```bash
sudo service mongod stop
sudo yum erase $(rpm -qa | grep mongodb-org)
sudo rm -r /var/log/mongodb
sudo rm -r /var/lib/mongo
```
