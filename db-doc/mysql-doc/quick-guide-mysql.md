# 使用MySQL Yum存储库的快速指南

## 添加MySQL Yum源

- 下载：http://dev.mysql.com/downloads/repo/yum/.（本文已CentOS为例）

## 安装MySQL

```
sudo rpm -Uvh mysql57-community-release-el6-n.noarch.rpm
yum localinstall mysql57-community-release-el6-n.noarch.rpm -y # 安装
```

> 注：使用yum安装的mysql，会随着系统（yum update）更新而更新

## 版本选择

- 查看可供安装的MySQL版本

```
yum repolist all | grep mysql
```

## 配置MySQL源
```
# 这些貌似不需要配置
# for mysql57-community
cat > /etc/yum.repos.d/mysql-community.repo < EOF
[mysql57-community]
name=MySQL 5.7 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/6/$basearch/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
EOF
```
---------
```
# for mysql56-community
cat > /etc/yum.repos.d/mysql-community.repo < EOF
  
EOF
```


yum install mysql-community-embedded  mysql-community-server  mysql-community-devel mysql-community-client

> 注：可以把gpgcheck=1改为gpgcheck=0，即可不验证key文件

###

yum repolist enabled | grep mysql

## install mysql

>  sudo yum install mysql-community-server -y

## start mysql

> sudo service mysqld start
> sudo service mysqld status  # 查看状态

- 仅对于MySQL 5.7：在服务器的初始启动时，出现以下情况，假定服务器的数据目录为空：

> 查看root密码：'root'@'localhost' 超级账户已被创建

```
sudo grep 'temporary password' /var/log/mysqld.log
```
- 修改MySQL密码
update mysql.user set authentication_string=password('@Aniuproddb123.') where user='root';

> ALTER USER 'root'@'localhost' IDENTIFIED BY 'wQNROtCutvU8yOICpz81';
> 这里建议使用强密码，MySQL初始密码设置等级较高，一般密码设置通不过验证
> 密码示例： ABCabc123!@#  !QAZ2wsx123.

- MySQL安全初始化（仅适用于MySQL 5.6）

>　mysql_secure_installation

## 安装其他MySQL的产品和零件

```
yum --disablerepo=\* --enablerepo='mysql*-community*' list available
sudo yum install package-name

```

## 使用MySQL Yum升级MySQL

- 1. 选择升级版本

> 重要
有关从MySQL 5.5升级到5.6，看到从MySQL 5.5升级到5.6的重要信息(https://dev.mysql.com/doc/refman/5.6/en/upgrading-from-previous-series.html)。
有关从MySQL 5.6升级到5.7的重要信息，请参阅从MySQL 5.6升级到5.7(https://dev.mysql.com/doc/refman/5.7/en/upgrading-from-previous-series.html)。
有关从MySQL 5.7升级到8.0的重要信息，请参阅从MySQL 5.7升级到8.0(https://dev.mysql.com/doc/refman/8.0/en/upgrading-from-previous-series.html)。

- 2. 升级

> sudo yum update mysql-server


# Error
> ERROR 1820 (HY000): You must reset your password using ALTER USER statement before executing this statement.

- https://dev.mysql.com/doc/refman/5.7/en/password-expiration-policy.html
```
set global validate_password_policy=0;  # 重新使用alter重设密码即可 （0,1,2）
```

>
Policy	     Tests Performed
0 or LOW	   Length
1 or MEDIUM	 Length; numeric, lowercase/uppercase, and special characters
2 or STRONG	 Length; numeric, lowercase/uppercase, and special characters; dictionary file

- 安全设置

```
set global validate_password_mixed_case_count=2;
```

> 查看validate_password插件是否安装（MySQL5.7自带）

```
mysql> SHOW VARIABLES LIKE 'validate_password%';
+--------------------------------------+-------+
| Variable_name                        | Value |
+--------------------------------------+-------+
| validate_password_check_user_name    | OFF   |
| validate_password_dictionary_file    |       |
| validate_password_length             | 8     |   # 密码长度
| validate_password_mixed_case_count   | 1     |   # 大小写个数，默认为，意思是大小写字符至少分别有一个
| validate_password_number_count       | 1     |   # 最少数字数量
| validate_password_policy             | LOW   |   # 加密程度（最低）
| validate_password_special_char_count | 1     |   # 最少特殊字符数量
+--------------------------------------+-------+
```


- 修改mysql 配置文件跳过密码验证

```
[mysqld]
skip-grant-tables
skip-networking
```
- 重启mysqld

```
/etc/init.d/mysqld restart
```
- change root passwd

```
update mysql.user set authentication_string=PASSWORD('@Aniuproddb123.') where user='root' and host='localhost';
```

> ERROR 1819 (HY000): Your password does not satisfy the current policy requirements
