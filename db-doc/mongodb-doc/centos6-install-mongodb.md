# CentOS 6 安装mongodb

- https://docs.mongodb.com/manual/installation/#tutorial-installation

/etc/yum.repos.d/mongodb-enterprise.repo

[mongodb-enterprise]
name=MongoDB Enterprise Repository
baseurl=https://repo.mongodb.com/yum/redhat/$releasever/mongodb-enterprise/3.4/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.4.asc

sudo yum install -y mongodb-enterprise

sudo service mongod start

sudo chkconfig mongod on

sudo yum erase $(rpm -qa | grep mongodb-enterprise)