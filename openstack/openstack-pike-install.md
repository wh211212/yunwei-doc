# install openstack pike 

## openstack version

https://releases.openstack.org/

（1）OpenStack的主要组件
服务	代码名称	描述
身份服务	Keystone	用户管理
计算服务	Nova	虚拟机管理
图像服务	Glance	管理像内核映像或磁盘映像这样的虚拟映像
仪表板	Horizon		通过Web浏览器提供GUI控制台
对象存储	Swift	提供云端存储
块存储	Cinder	虚拟机的存储管理
网络服务	Neutron	虚拟网络管理
编排服务	Heat	为虚拟机提供编排功能
计量服务	Ceilometer	提供会计用法测量功能
数据库服务	Trove	数据库资源管理
数据处理服务	Sahara	提供数据处理功能
裸金属供应	Ironic	提供裸机供应功能
消息服务	Zaqar	提供消息传递服务功能
共享文件系统	Manila	提供文件共享服务
DNS服务	Designate	提供DNS服务器服务
密钥管理器服务	Barbican	提供密钥管理服务

- 配置域名解析

```
# 每个节点都需要配置
# controller
10.1.1.2       controller

# compute1
10.1.1.6       compute1

# block1
10.1.1.7       block1 # 非必须

# object1
10.1.1.8       object1 # 非必须

# object2
10.1.1.9       object2  # 非必须
``` 

- 验证连通性

```bash
ping -c 4 compute1
ping -c 4 controller
```

- 安装时间服务器

```bash
# yum install chrony
编辑 /etc/chrony.conf 文件，修改server NTP_SERVER iburst
[root@controller ~]# systemctl enable chronyd.service
[root@controller ~]# systemctl start chronyd.service
[root@controller ~]# systemctl status chronyd.service
```

- 启用OpenStack库

```bash
yum -y install centos-release-openstack-pike 
sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/CentOS-OpenStack-pike.repo 
# 升级
yum upgrade
# 安装openstack客户端
yum --enablerepo=centos-openstack-pike install python-openstackclient
# RHEL 和 CentOS 默认启用了 SELinux . 安装 openstack-selinux 软件包以便自动管理 OpenStack 服务的安全策略:
yum --enablerepo=centos-openstack-pike install openstack-selinux
```

### 配置数据库

```bash
# 安装软件包
yum --enablerepo=centos-openstack-pike install mariadb mariadb-server python2-PyMySQL
# 配置mariadb，创建并编辑 /etc/my.cnf.d/openstack.cnf
[mysqld]
...
bind-address = 10.1.1.2
default-storage-engine = innodb
innodb_file_per_table
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
# 启动数据库
systemctl enable mariadb.service
systemctl start mariadb.service
mysql_secure_installation

### 配置NoSQL

- 安装并配置mongodb

```
# 安装MongoDB
yum --enablerepo=centos-openstack-pike install mongodb-server mongodb

# 编辑文件 /etc/mongod.conf 并完成如下动作
配置 bind_ip 使用控制节点管理网卡的IP地址

bind_ip = 10.1.1.2
# 默认情况下，MongoDB会在``/var/lib/mongodb/journal`` 目录下创建几个 1 GB 大小的日志文件。如果你想将每个日志文件大小减小到128MB并且限制日志文件占用的总空间为512MB，配置 smallfiles 的值：
smallfiles = true
```

### 消息队列

- 安装配置rabbitmq-server

```youtrack
# 安装rabbitmq-server包
yum --enablerepo=centos-openstack-pike install rabbitmq-server

# 启动消息队列服务并将其配置为随系统启动：
systemctl enable rabbitmq-server.service
systemctl start rabbitmq-server.service

#添加 openstack 用户
rabbitmqctl add_user openstack RABBIT_PASS # RABBIT_PASS可以自定义

# 给``openstack``用户配置写和读权限
rabbitmqctl set_permissions openstack ".*" ".*" ".*"
```

### 配置缓存

- 安装配置Memcached

```youtrack
# 安装软件包
yum --enablerepo=centos-openstack-pike install memcached python-memcached

# 启动Memcached服务，并且配置它随机启动
systemctl enable memcached.service
systemctl start memcached.service

# 注：笔者controller禁用了ipv6,memcached的启动参数需要修改
```

### 配置认证服务

> OpenStack Identity service 为认证管理，授权管理和服务目录服务管理提供单点整合。其它OpenStack服务将身份认证服务当做通用统一API来使用。身份服务包含这些组件：

- 服务器：一个中心化的服务器使用RESTful 接口来提供认证和授权服务。
- 驱动：驱动或服务后端被整合进集中式服务器中。它们被用来访问OpenStack外部仓库的身份信息, 并且它们可能已经存在于OpenStack被部署在的基础设施（例如，SQL数据库或LDAP服务器）中。
- 模块：中间件模块运行于使用身份认证服务的OpenStack组件的地址空间中。

> 配置 OpenStack 身份认证服务前，必须创建一个数据库和管理员令牌

```bash
# mysql -u root -pDB_PASSWORD
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'KEYSTONE_DBPASS';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'KEYSTONE_DBPASS';
# 用合适的密码替换 KEYSTONE_DBPASS
```
- 生成一个随机值在初始的配置中作为管理员的令牌

```bash
openssl rand -hex 10
61cb73a112d4429dcca7
```

- 安全并配置组件

```bash
# 安装相关软件包
yum --enablerepo=centos-openstack-pike install openstack-keystone httpd mod_wsgi

# 编辑文件 /etc/keystone/keystone.conf 并完成如下动作，在``[DEFAULT]``部分，定义初始管理令牌的值：
[DEFAULT]

admin_token = ADMIN_TOKEN （61cb73a112d4429dcca7）

# 在 [database] 部分，配置数据库访问：
[database]

connection = mysql+pymysql://keystone:KEYSTONE_DBPASS@controller/keystone # 将``KEYSTONE_DBPASS``替换为你为数据库选择的密码

# 在``[token]``部分，配置Fernet UUID令牌的提供者
[token] # 2715行

provider = fernet #2759行

# 初始化身份认证服务的数据库
su -s /bin/sh -c "keystone-manage db_sync" keystone

# 初始化Fernet keys
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
```

- 配置Apache HTTP 服务器

```bash
# 编辑``/etc/httpd/conf/httpd.conf`` 文件，配置``ServerName`` 选项为控制节点
ServerName controller

# 用下面的内容创建文件 /etc/httpd/conf.d/wsgi-keystone.conf

Listen 5000
Listen 35357

<VirtualHost *:5000>
    WSGIDaemonProcess keystone-public processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
    WSGIProcessGroup keystone-public
    WSGIScriptAlias / /usr/bin/keystone-wsgi-public
    WSGIApplicationGroup %{GLOBAL}
    WSGIPassAuthorization On
    ErrorLogFormat "%{cu}t %M"
    ErrorLog /var/log/httpd/keystone-error.log
    CustomLog /var/log/httpd/keystone-access.log combined

    <Directory /usr/bin>
        Require all granted
    </Directory>
</VirtualHost>

<VirtualHost *:35357>
    WSGIDaemonProcess keystone-admin processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
    WSGIProcessGroup keystone-admin
    WSGIScriptAlias / /usr/bin/keystone-wsgi-admin
    WSGIApplicationGroup %{GLOBAL}
    WSGIPassAuthorization On
    ErrorLogFormat "%{cu}t %M"
    ErrorLog /var/log/httpd/keystone-error.log
    CustomLog /var/log/httpd/keystone-access.log combined

    <Directory /usr/bin>
        Require all granted
    </Directory>
</VirtualHost>
```

- 启动 Apache HTTP 服务并配置其随系统启动：

```bash
# systemctl enable httpd.service
# systemctl start httpd.service
```

#### 创建服务实体和API端点

> 身份认证服务提供服务的目录和他们的位置。每个你添加到OpenStack环境中的服务在目录中需要一个 service 实体和一些 API endpoints 。

- 默认情况下，身份认证服务数据库不包含支持传统认证和目录服务的信息,必须使用为身份认证服务创建的临时身份验证令牌用来初始化的服务实体和API端点

```bash
# 配置认证令牌,将``ADMIN_TOKEN``替换为前面生成的认证令牌
export OS_TOKEN=61cb73a112d4429dcca7

# 配置端点URL：
export OS_URL=http://controller:35357/v3

# 配置认证 API 版本
export OS_IDENTITY_API_VERSION=3
```

- 创建服务实体和API端点

```bash
# 在你的Openstack环境中，认证服务管理服务目录。服务使用这个目录来决定您的环境中可用的服务。创建服务实体和身份认证服务
[root@controller ~]# openstack service create --name keystone --description "OpenStack Identity" identity
+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | OpenStack Identity               |
| enabled     | True                             |
| id          | d742db6ebec04b818900265f1f4b2272 |
| name        | keystone                         |
| type        | identity                         |
+-------------+----------------------------------+
# OpenStack 是动态生成 ID 的

# 身份认证服务管理了一个与您环境相关的 API 端点的目录。服务使用这个目录来决定如何与您环境中的其他服务进行通信。
OpenStack使用三个API端点变量代表每种服务：admin，internal和public。默认情况下，管理API端点允许修改用户和租户而公共和内部APIs不允许这些操作。在生产环境中，处于安全原因，变量为了服务不同类型的用户可能驻留在单独的网络上。对实例而言，公共API网络为了让顾客管理他们自己的云在互联网上是可见的。管理API网络在管理云基础设施的组织中操作也是有所限制的。内部API网络可能会被限制在包含OpenStack服务的主机上。此外，OpenStack支持可伸缩性的多区域。为了简单起见，本指南为所有端点变种和默认``RegionOne``区域都使用管理网络。
[root@controller ~]# openstack endpoint create --region RegionOne identity public http://controller:5000/v3
+--------------+----------------------------------+
| Field        | Value                            |
+--------------+----------------------------------+
| enabled      | True                             |
| id           | 0d1da27095894958828861c46862435c |
| interface    | public                           |
| region       | RegionOne                        |
| region_id    | RegionOne                        |
| service_id   | d742db6ebec04b818900265f1f4b2272 |
| service_name | keystone                         |
| service_type | identity                         |
| url          | http://controller:5000/v3        |
+--------------+----------------------------------+
[root@controller ~]# openstack endpoint create --region RegionOne identity internal http://controller:5000/v3
+--------------+----------------------------------+
| Field        | Value                            |
+--------------+----------------------------------+
| enabled      | True                             |
| id           | 8ef4213020c8477380e3975d9f0642d5 |
| interface    | internal                         |
| region       | RegionOne                        |
| region_id    | RegionOne                        |
| service_id   | d742db6ebec04b818900265f1f4b2272 |
| service_name | keystone                         |
| service_type | identity                         |
| url          | http://controller:5000/v3        |
+--------------+----------------------------------+
[root@controller ~]# openstack endpoint create --region RegionOne identity admin http://controller:35357/v3
+--------------+----------------------------------+
| Field        | Value                            |
+--------------+----------------------------------+
| enabled      | True                             |
| id           | b80f47772ee0441e8bcc8c28a5c34a1a |
| interface    | admin                            |
| region       | RegionOne                        |
| region_id    | RegionOne                        |
| service_id   | d742db6ebec04b818900265f1f4b2272 |
| service_name | keystone                         |
| service_type | identity                         |
| url          | http://controller:35357/v3       |
+--------------+----------------------------------+
# 每个添加到OpenStack环境中的服务要求一个或多个服务实体和三个认证服务中的API 端点变种
```

- 创建域、项目、用户和角色

> 身份认证服务为每个OpenStack服务提供认证服务

```bash
# 创建域``default``
[root@controller ~]# openstack domain create --description "Default Domain" default
+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | Default Domain                   |
| enabled     | True                             |
| id          | ac02661aedd84404a95497ec532d3fdb |
| name        | default                          |
+-------------+----------------------------------+

# 为进行管理操作，创建管理的项目、用户和角色,创建 admin 项目：
[root@controller ~]# openstack project create --domain default --description "Admin Project" admin
+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | Admin Project                    |
| domain_id   | ac02661aedd84404a95497ec532d3fdb |
| enabled     | True                             |
| id          | f1008e21497349dc81ea27b4d9ba9b22 |
| is_domain   | False                            |
| name        | admin                            |
| parent_id   | ac02661aedd84404a95497ec532d3fdb |
+-------------+----------------------------------+

# 创建 admin 用户
[root@controller ~]#  openstack user create --domain default --password-prompt admin
User Password: # adminpassword
Repeat User Password: # adminpassword
+---------------------+----------------------------------+
| Field               | Value                            |
+---------------------+----------------------------------+
| domain_id           | ac02661aedd84404a95497ec532d3fdb |
| enabled             | True                             |
| id                  | 71e988ec419e4b2097e101307f5f241d |
| name                | admin                            |
| options             | {}                               |
| password_expires_at | None                             |
+---------------------+----------------------------------+

# 创建 admin 角色
[root@controller ~]# openstack role create admin
+-----------+----------------------------------+
| Field     | Value                            |
+-----------+----------------------------------+
| domain_id | None                             |
| id        | 0e977c355d594dc587c40d55e5143a83 |
| name      | admin                            |
+-----------+----------------------------------+

# 添加``admin`` 角色到 admin 项目和用户上
[root@controller ~]# openstack role add --project admin --user admin admin
# 这个命令执行后没有输出
# 创建的任何角色必须映射到每个OpenStack服务配置文件目录下的``policy.json`` 文件中。默认策略是给予“admin“角色大部分服务的管理访问权限。

# 创建``service``项目
[root@controller ~]# openstack project create --domain default --description "Service Project" service
+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | Service Project                  |
| domain_id   | ac02661aedd84404a95497ec532d3fdb |
| enabled     | True                             |
| id          | cc436e334fcc44a7a3568831379e5f2b |
| is_domain   | False                            |
| name        | service                          |
| parent_id   | ac02661aedd84404a95497ec532d3fdb |
+-------------+----------------------------------+

# 常规（非管理）任务应该使用无特权的项目和用户。作为例子，本指南创建 demo 项目和用户，创建``demo`` 项目
[root@controller ~]# openstack project create --domain default --description "Demo Project" demo
+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | Demo Project                     |
| domain_id   | ac02661aedd84404a95497ec532d3fdb |
| enabled     | True                             |
| id          | 53eaa06f2f9046d796fd4af5334c8e24 |
| is_domain   | False                            |
| name        | demo                             |
| parent_id   | ac02661aedd84404a95497ec532d3fdb |
+-------------+----------------------------------+

# 创建``demo`` 用户
[root@controller ~]# openstack user create --domain default --password-prompt demo
User Password: # demopassword
Repeat User Password:
+---------------------+----------------------------------+
| Field               | Value                            |
+---------------------+----------------------------------+
| domain_id           | ac02661aedd84404a95497ec532d3fdb |
| enabled             | True                             |
| id                  | 32d6b9909c6745d5bcfe2e0078130bb0 |
| name                | demo                             |
| options             | {}                               |
| password_expires_at | None                             |
+---------------------+----------------------------------+

# 创建 user 角色
[root@controller ~]# openstack role create user
+-----------+----------------------------------+
| Field     | Value                            |
+-----------+----------------------------------+
| domain_id | None                             |
| id        | d1a88d489ccb4423aaba6da025c9c583 |
| name      | user                             |
+-----------+----------------------------------+

# 添加 user``角色到 ``demo 项目和用户：
[root@controller ~]# openstack role add --project demo --user demo user
```
#### 验证操作

> 在安装其他服务之前确认身份认证服务的操作,在控制节点上执行这些命令

- 因为安全性的原因，关闭临时认证令牌机制：

```bash
编辑 /etc/keystone/keystone-paste.ini 文件，从``[pipeline:public_api]``，[pipeline:admin_api]``和``[pipeline:api_v3]``部分删除``admin_token_auth 。
```
- 重置``OS_TOKEN``和``OS_URL`` 环境变量：

```bash
[root@controller keystone]# unset OS_TOKEN OS_URL
```
- 作为 admin 用户，请求认证令牌：

```bash
[root@controller keystone]# openstack --os-auth-url http://controller:35357/v3 \
>   --os-project-domain-name default --os-user-domain-name default \
>   --os-project-name admin --os-username admin token issue
Password: 
+------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Field      | Value                                                                                                                                                                                   |
+------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| expires    | 2018-03-12T04:43:41+0000                                                                                                                                                                |
| id         | gAAAAABapfdtPRK3IEfGCWsENFCW2A2nHi0fKvBa5KOWACPRhtf9_B-Zf5a_CPP73MK7cf87Un3jQl_AqhQAlTorfYFtUqc5N9sEdZtG_3SZtoso5qeh0_eITbvFVfxk-5U0tgbZwZz1q4ZecCUTE4ZSTgSOMgA11imaiVhwxT-ADW5Y3Q3OD-A |
| project_id | f1008e21497349dc81ea27b4d9ba9b22                                                                                                                                                        |
| user_id    | 71e988ec419e4b2097e101307f5f241d                                                                                                                                                        |
+------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
```

- 作为``demo`` 用户，请求认证令牌

```bash
[root@controller keystone]# openstack --os-auth-url http://controller:5000/v3 \
>   --os-project-domain-name default --os-user-domain-name default \
>   --os-project-name demo --os-username demo token issue
Password: 
+------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Field      | Value                                                                                                                                                                                   |
+------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| expires    | 2018-03-12T04:44:02+0000                                                                                                                                                                |
| id         | gAAAAABapfeCQJnU2Et6YySKDbB0mbgki6Ob_kj-FbApEk6qj3VGIw-if9VlT9GDqFaZsiq5lxqgf1N7xPNynqAJgA_EA1Xgy40TbBXytQxQ8jyao7_coqtDe1hKt2ndYgZ1sak8Cceh4dP1z-vaaBDlsLL-OhxNg2uWRILYfY7IFi3LEpBpAb0 |
| project_id | 53eaa06f2f9046d796fd4af5334c8e24                                                                                                                                                        |
| user_id    | 32d6b9909c6745d5bcfe2e0078130bb0                                                                                                                                                        |
+------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
```

### 创建 OpenStack 客户端环境脚本

> 使用环境变量和命令选项的组合通过``openstack``客户端与身份认证服务交互。为了提升客户端操作的效率，OpenStack支持简单的客户端环境变量脚本即OpenRC 文件。这些脚本通常包含客户端所有常见的选项，当然也支持独特的选项,参考`OpenStack End User Guide <http://docs.openstack.org/user-guide/common/ cli_set_environment_variables_using_openstack_rc.html>`

- 创建脚本

> 创建 admin 和 ``demo``项目和用户创建客户端环境变量脚本。本教程下来的部分会引用这些脚本，为客户端操作加载合适的的凭证。

```bash
# 编辑文件 admin-openrc 并添加如下内容：
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=ADMIN_PASS  #将 ADMIN_PASS 替换为你在认证服务中为 admin 用户选择的密码:adminpassword
export OS_AUTH_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
export PS1='[\u@\h \W(keystone)]\$ '

# 编辑文件 demo-openrc 并添加如下内容：
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=DEMO_PASS #将 DEMO_PASS 替换为你在认证服务中为 demo 用户选择的密码:demopassword
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2

# 为了方便使用把admin-openrc,demo-openrc重命名为：.admin-openrc, .demo-openrc
[root@controller ~]# mv admin-openrc .admin-openrc
[root@controller ~]# mv demo-openrc .demo-openrc 
[root@controller ~]# echo "source ~/.admin-openrc " >> ~/.bash_profile            
[root@controller ~]# echo "source ~/.demo-openrc " >> ~/.bash_profile  # 此配置不用
# 重载环境变量
[root@controller ~]# source ~/.bash_profile
```

- 使用脚本

> 加载``admin-openrc``文件来身份认证服务的环境变量位置和``admin``项目和用户证书：

```bash
. .admin-openrc

# 请求认证令牌:
[root@controller ~(keystone)]# openstack token issue
+------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Field      | Value                                                                                                                                                                                   |
+------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| expires    | 2018-03-12T05:00:18+0000                                                                                                                                                                |
| id         | gAAAAABapftSXrrKrpXAQImST3PVSr1XrSzVoCLGvQ9e3RHkZGE7DUYyO3gz3vd5OBs--IjPUsbBu8SIq-OKFSGtnp1qcGtYLBCrDtY7LwdT7pBfCIZtOk_aPZV9AUoDunGJAzSGRtDzU1W7vAFynQfuj1wxFYz6MPM60wdNwE2lUzRUh9Qi_1c |
| project_id | f1008e21497349dc81ea27b4d9ba9b22                                                                                                                                                        |
| user_id    | 71e988ec419e4b2097e101307f5f241d                                                                                                                                                        |
+------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
```

### 镜像服务（安装）

> 镜像服务 (glance) 允许用户发现、注册和获取虚拟机镜像。它提供了一个 REST API，允许您查询虚拟机镜像的 metadata 并获取一个现存的镜像。您可以将虚拟机镜像存储到各种位置，从简单的文件系统到对象存储系统—-例如 OpenStack 对象存储, 并通过镜像服务使用。

- 镜像服务概览

> OpenStack镜像服务是IaaS的核心服务，如同 :ref:`get_started_conceptual_architecture`所示。它接受磁盘镜像或服务器镜像API请求，和来自终端用户或OpenStack计算组件的元数据定义。它也支持包括OpenStack对象存储在内的多种类型仓库上的磁盘镜像或服务器镜像存储。大量周期性进程运行于OpenStack镜像服务上以支持缓存。同步复制（Replication）服务保证集群中的一致性和可用性。其它周期性进程包括auditors, updaters, 和 reapers。

- OpenStack镜像服务包括以下组件：

```bash
#glance-api
接收镜像API的调用，诸如镜像发现、恢复、存储。

#glance-registry
存储、处理和恢复镜像的元数据，元数据包括项诸如大小和类型。# glance-registry是私有内部服务，用于服务OpenStack Image服务。不要向用户暴露该服务

#数据库
存放镜像元数据，用户是可以依据个人喜好选择数据库的，多数的部署使用MySQL或SQLite。

#镜像文件的存储仓库
支持多种类型的仓库，它们有普通文件系统、对象存储、RADOS块设备、HTTP、以及亚马逊S3。记住，其中一些仓库仅支持只读方式使用。

#元数据定义服务
通用的API，是用于为厂商，管理员，服务，以及用户自定义元数据。这种元数据可用于不同的资源，例如镜像，工件，卷，配额以及集合。一个定义包括了新属性的键，描述，约束以及可以与之关联的资源的类型。
```

- 安装和配置镜像服务之前，必须创建创建一个数据库、服务凭证和API端点

```bash
# 创建数据库glance
[root@controller ~(keystone)]# mysql -u root -pAniudba123.
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 10
Server version: 10.1.20-MariaDB MariaDB Server

Copyright (c) 2000, 2016, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE DATABASE glance;
Query OK, 1 row affected (0.00 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' \
    ->   IDENTIFIED BY 'GLANCE_DBPASS';
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' \
    ->   IDENTIFIED BY 'GLANCE_DBPASS';
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> flush privileges;
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> exit
Bye

# 要创建服务证书,创建 glance 用户,
[root@controller ~(keystone)]# openstack user create --domain default --password-prompt glance
User Password: #glancepassword
Repeat User Password:
+---------------------+----------------------------------+
| Field               | Value                            |
+---------------------+----------------------------------+
| domain_id           | ac02661aedd84404a95497ec532d3fdb |
| enabled             | True                             |
| id                  | ab5176ac1d794612bf51771d78994e53 |
| name                | glance                           |
| options             | {}                               |
| password_expires_at | None                             |
+---------------------+----------------------------------+

# 添加 admin 角色到 glance 用户和 service 项目上
openstack role add --project service --user glance admin

# 创建``glance``服务实体
[root@controller ~(keystone)]# openstack service create --name glance --description "OpenStack Image" image
+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | OpenStack Image                  |
| enabled     | True                             |
| id          | c109bef0d8834b6a83210f16e657ecd4 |
| name        | glance                           |
| type        | image                            |
+-------------+----------------------------------+

# 创建镜像服务的 API 端点
[root@controller ~(keystone)]#  openstack endpoint create --region RegionOne image public http://controller:9292
+--------------+----------------------------------+
| Field        | Value                            |
+--------------+----------------------------------+
| enabled      | True                             |
| id           | d72f29584b814113b056916e1c8772ec |
| interface    | public                           |
| region       | RegionOne                        |
| region_id    | RegionOne                        |
| service_id   | c109bef0d8834b6a83210f16e657ecd4 |
| service_name | glance                           |
| service_type | image                            |
| url          | http://controller:9292           |
+--------------+----------------------------------+
[root@controller ~(keystone)]# openstack endpoint create --region RegionOne image internal http://controller:9292
+--------------+----------------------------------+
| Field        | Value                            |
+--------------+----------------------------------+
| enabled      | True                             |
| id           | e37550a16f8641b79cfefa3d4d1a5ad8 |
| interface    | internal                         |
| region       | RegionOne                        |
| region_id    | RegionOne                        |
| service_id   | c109bef0d8834b6a83210f16e657ecd4 |
| service_name | glance                           |
| service_type | image                            |
| url          | http://controller:9292           |
+--------------+----------------------------------+
[root@controller ~(keystone)]# openstack endpoint create --region RegionOne image admin http://controller:9292
+--------------+----------------------------------+
| Field        | Value                            |
+--------------+----------------------------------+
| enabled      | True                             |
| id           | 01bcbe56776c42568cfad5a13094c81c |
| interface    | admin                            |
| region       | RegionOne                        |
| region_id    | RegionOne                        |
| service_id   | c109bef0d8834b6a83210f16e657ecd4 |
| service_name | glance                           |
| service_type | image                            |
| url          | http://controller:9292           |
+--------------+----------------------------------+
```

#### 安全并配置组件

- 安装软件包：

```bash
yum --enablerepo=centos-openstack-pike install openstack-glance
```

- 编辑文件 /etc/glance/glance-api.conf 并完成如下动作

```bash
# 在 [database] 部分，配置数据库访问：
[database]
# 
connection = mysql+pymysql://glance:GLANCE_DBPASS@controller/glance # 将``GLANCE_DBPASS`` 替换为你为镜像服务选择的密码

# 在 [keystone_authtoken] 和 [paste_deploy] 部分，配置认证服务访问
[keystone_authtoken]
...
auth_uri = http://controller:5000
auth_url = http://controller:35357
memcached_servers = controller:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = glance
password = GLANCE_PASS 

[paste_deploy]
...
flavor = keystone
# 将 GLANCE_PASS 替换为你为认证服务中你为 glance 用户选择的密码,在 [keystone_authtoken] 中注释或者删除其他选项

# 在 [glance_store] 部分，配置本地文件系统存储和镜像文件位置：
[glance_store]
...
stores = file,http
default_store = file
filesystem_store_datadir = /var/lib/glance/images/

```

- 编辑文件 ``/etc/glance/glance-registry.conf``并完成如下动作：

```bash
# 在 [database] 部分，配置数据库访问：
[database]
# 
connection = mysql+pymysql://glance:GLANCE_DBPASS@controller/glance # 将``GLANCE_DBPASS`` 替换为你为镜像服务选择的密码

# 在 [keystone_authtoken] 和 [paste_deploy] 部分，配置认证服务访问：
[keystone_authtoken]
...
auth_uri = http://controller:5000
auth_url = http://controller:35357
memcached_servers = controller:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = glance
password = GLANCE_PASS

[paste_deploy]
...
flavor = keystone
# 将 GLANCE_PASS 替换为你为认证服务中你为 glance 用户选择的密码。在 [keystone_authtoken] 中注释或者删除其他选项。

# 查看 
[root@controller ~]# egrep -v '^#|^$' /etc/glance/glance-api.conf 
[DEFAULT]
bind_host = 0.0.0.0
[cors]
[database]
connection = mysql+pymysql://glance:GLANCE_DBPASS@controller/glance
[glance_store]
stores = file,http
default_store = file
filesystem_store_datadir = /var/lib/glance/images/
[image_format]
[keystone_authtoken]
auth_uri = http://controller:5000
auth_url = http://controller:35357
memcached_servers = controller:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = glance
password = glancepassword
[matchmaker_redis]
[oslo_concurrency]
[oslo_messaging_amqp]
[oslo_messaging_kafka]
[oslo_messaging_notifications]
[oslo_messaging_rabbit]
[oslo_messaging_zmq]
[oslo_middleware]
[oslo_policy]
[paste_deploy]
flavor = keystone
[profiler]
[store_type_location_strategy]
[task]
[taskflow_executor]
#
[root@controller ~]# egrep -v '^#|^$' /etc/glance/glance-registry.conf
[DEFAULT]
bind_host = 0.0.0.0
[database]
connection = mysql+pymysql://glance:GLANCE_DBPASS@controller/glance
[keystone_authtoken]
auth_uri = http://controller:5000
auth_url = http://controller:35357
memcached_servers = controller:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = glance
password = glancepassword
[matchmaker_redis]
[oslo_messaging_amqp]
[oslo_messaging_kafka]
[oslo_messaging_notifications]
[oslo_messaging_rabbit]
[oslo_messaging_zmq]
[oslo_policy]
[paste_deploy]
flavor = keyston
```

- 写入镜像服务数据库：

```bash
su -s /bin/sh -c "glance-manage db_sync" glance
```

- 启动镜像服务、配置他们随机启动
```bash
# systemctl enable openstack-glance-api.service \
  openstack-glance-registry.service
# systemctl start openstack-glance-api.service \
  openstack-glance-registry.service
```

- 验证操作

> 使用 `CirrOS <http://launchpad.net/cirros>`__对镜像服务进行验证，CirrOS是一个小型的Linux镜像可以用来帮助你进行 OpenStack部署测试.

```bash
# 下载源镜像
wget http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img

# 使用 QCOW2 磁盘格式， bare 容器格式上传镜像到镜像服务并设置公共可见，这样所有的项目都可以访问它：
[root@controller ~]# openstack image create "cirros"  --file cirros-0.4.0-x86_64-disk.img --disk-format qcow2 --container-format bare --public
+------------------+------------------------------------------------------+
| Field            | Value                                                |
+------------------+------------------------------------------------------+
| checksum         | 443b7623e27ecf03dc9e01ee93f67afe                     |
| container_format | bare                                                 |
| created_at       | 2018-03-12T06:33:03Z                                 |
| disk_format      | qcow2                                                |
| file             | /v2/images/5be4203b-066c-46c6-88e0-5b6eac765f0a/file |
| id               | 5be4203b-066c-46c6-88e0-5b6eac765f0a                 |
| min_disk         | 0                                                    |
| min_ram          | 0                                                    |
| name             | cirros                                               |
| owner            | f1008e21497349dc81ea27b4d9ba9b22                     |
| protected        | False                                                |
| schema           | /v2/schemas/image                                    |
| size             | 12716032                                             |
| status           | active                                               |
| tags             |                                                      |
| updated_at       | 2018-03-12T06:33:04Z                                 |
| virtual_size     | None                                                 |
| visibility       | public                                               |
+------------------+------------------------------------------------------+

# 确认镜像的上传并验证属性
[root@controller ~]# openstack image list
+--------------------------------------+--------+--------+
| ID                                   | Name   | Status |
+--------------------------------------+--------+--------+
| 5be4203b-066c-46c6-88e0-5b6eac765f0a | cirros | active |
+--------------------------------------+--------+--------+
```

## 计算服务

### 计算服务概览

> 使用OpenStack计算服务来托管和管理云计算系统。OpenStack计算服务是基础设施即服务(IaaS)系统的主要部分，模块主要由Python实现。

> OpenStack计算组件请求OpenStack Identity服务进行认证；请求OpenStack Image服务提供磁盘镜像；为OpenStack dashboard提供用户与管理员接口。磁盘镜像访问限制在项目与用户上；配额以每个项目进行设定（例如，每个项目下可以创建多少实例）。OpenStack组件可以在标准硬件上水平大规模扩展，并且下载磁盘镜像启动虚拟机实例。

OpenStack计算服务由下列组件所构成：

- nova-api 服务

> 接收和响应来自最终用户的计算API请求。此服务支持OpenStack计算服务API，Amazon EC2 API，以及特殊的管理API用于赋予用户做一些管理的操作。它会强制实施一些规则，发起多数的编排活动，例如运行一个实例。

- nova-api-metadata 服务

> 接受来自虚拟机发送的元数据请求。``nova-api-metadata``服务一般在安装``nova-network``服务的多主机模式下使用。

- nova-compute 服务 

> 一个持续工作的守护进程，通过Hypervior的API来创建和销毁虚拟机实例。例如：

```bash
XenServer/XCP 的 XenAPI
KVM 或 QEMU 的 libvirt
VMware 的 VMwareAPI
```
> 过程是蛮复杂的。最为基本的，守护进程同意了来自队列的动作请求，转换为一系列的系统命令如启动一个KVM实例，然后，到数据库中更新它的状态

- nova-scheduler 服务

> 拿到一个来自队列请求虚拟机实例，然后决定那台计算服务器主机来运行它

- nova-conductor 模块

> 媒介作用于``nova-compute``服务与数据库之间。它排除了由``nova-compute``服务对云数据库的直接访问。nova-conductor模块可以水平扩展。但是，不要将它部署在运行``nova-compute``服务的主机节点上

- nova-cert 模块

> 服务器守护进程向Nova Cert服务提供X509证书。用来为``euca-bundle-image``生成证书。仅仅是在EC2 API的请求中使用

- nova-network worker 守护进程

> 与``nova-compute``服务类似，从队列中接受网络任务，并且操作网络。执行任务例如创建桥接的接口或者改变IPtables的规则

- nova-consoleauth 守护进程

> 授权控制台代理所提供的用户令牌。

- nova-novncproxy 守护进程

> 提供一个代理，用于访问正在运行的实例，通过VNC协议，支持基于浏览器的novnc客户端。

- nova-spicehtml5proxy 守护进程

> 提供一个代理，用于访问正在运行的实例，通过 SPICE 协议，支持基于浏览器的 HTML5 客户端。

- nova-xvpvncproxy 守护进程

> 提供一个代理，用于访问正在运行的实例，通过VNC协议，支持OpenStack特定的Java客户端。

- nova-cert 守护进程

> X509 证书

- nova 客户端

> 用于用户作为租户管理员或最终用户来提交命令

- 队列

> 一个在守护进程间传递消息的中央集线器。

- SQL数据库

```bash
存储构建时和运行时的状态，为云基础设施，包括有：

可用实例类型

使用中的实例

可用网络

项目
```

### 安装并配置控制节点

- 安装和配置 Compute 服务前，必须创建数据库服务的凭据以及 API endpoints

```bash
# 创建数据库nova,nova_api
[root@controller ~]# mysql -u root -pAniudba123.       
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 29
Server version: 10.1.20-MariaDB MariaDB Server

Copyright (c) 2000, 2016, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE DATABASE nova_api;
Query OK, 1 row affected (0.00 sec)

MariaDB [(none)]> CREATE DATABASE nova;
Query OK, 1 row affected (0.00 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' \
    ->   IDENTIFIED BY 'NOVA_DBPASS';
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' \
    ->   IDENTIFIED BY 'NOVA_DBPASS';
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' \
    ->   IDENTIFIED BY 'NOVA_DBPASS';
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' \
    ->   IDENTIFIED BY 'NOVA_DBPASS';
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> flush privileges;
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> exit
Bye

# 要创建服务证书,创建 nova 用户,给 nova 用户添加 admin 角色
[root@controller ~]# openstack user create --domain default --password-prompt nova
User Password: #novapassword
Repeat User Password:
+---------------------+----------------------------------+
| Field               | Value                            |
+---------------------+----------------------------------+
| domain_id           | ac02661aedd84404a95497ec532d3fdb |
| enabled             | True                             |
| id                  | a9dbc6d038d74d8580b9422f74785e19 |
| name                | nova                             |
| options             | {}                               |
| password_expires_at | None                             |
+---------------------+----------------------------------+
[root@controller ~]# openstack role add --project service --user nova admin
#

# 创建 nova 服务实体
[root@controller ~]# openstack service create --name nova --description "OpenStack Compute" compute
+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | OpenStack Compute                |
| enabled     | True                             |
| id          | 70185ac2917a4cb18c00ca28828eac95 |
| name        | nova                             |
| type        | compute                          |
+-------------+----------------------------------+

# 创建 Compute 服务 API 端点
[root@controller ~]# openstack service create --name nova \
>   --description "OpenStack Compute" compute
+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | OpenStack Compute                |
| enabled     | True                             |
| id          | 70185ac2917a4cb18c00ca28828eac95 |
| name        | nova                             |
| type        | compute                          |
+-------------+----------------------------------+
[root@controller ~]# openstack endpoint create --region RegionOne \
>   compute public http://controller:8774/v2.1/%\(tenant_id\)s
+--------------+-------------------------------------------+
| Field        | Value                                     |
+--------------+-------------------------------------------+
| enabled      | True                                      |
| id           | e5be8e10fe47477c848e5ab6cc28110a          |
| interface    | public                                    |
| region       | RegionOne                                 |
| region_id    | RegionOne                                 |
| service_id   | 70185ac2917a4cb18c00ca28828eac95          |
| service_name | nova                                      |
| service_type | compute                                   |
| url          | http://controller:8774/v2.1/%(tenant_id)s |
+--------------+-------------------------------------------+
[root@controller ~]# openstack endpoint create --region RegionOne \
>   compute internal http://controller:8774/v2.1/%\(tenant_id\)s
+--------------+-------------------------------------------+
| Field        | Value                                     |
+--------------+-------------------------------------------+
| enabled      | True                                      |
| id           | 541dea4301a84077b5b8c3c29b1eb620          |
| interface    | internal                                  |
| region       | RegionOne                                 |
| region_id    | RegionOne                                 |
| service_id   | 70185ac2917a4cb18c00ca28828eac95          |
| service_name | nova                                      |
| service_type | compute                                   |
| url          | http://controller:8774/v2.1/%(tenant_id)s |
+--------------+-------------------------------------------+
[root@controller ~]# openstack endpoint create --region RegionOne \
>   compute admin http://controller:8774/v2.1/%\(tenant_id\)s
+--------------+-------------------------------------------+
| Field        | Value                                     |
+--------------+-------------------------------------------+
| enabled      | True                                      |
| id           | f1878fcd16ab49a6b10ada425e8347c5          |
| interface    | admin                                     |
| region       | RegionOne                                 |
| region_id    | RegionOne                                 |
| service_id   | 70185ac2917a4cb18c00ca28828eac95          |
| service_name | nova                                      |
| service_type | compute                                   |
| url          | http://controller:8774/v2.1/%(tenant_id)s |
+--------------+-------------------------------------------+

#
[root@controller ~]# openstack service create --name placement --description "OpenStack Compute Placement service" placement
+-------------+-------------------------------------+
| Field       | Value                               |
+-------------+-------------------------------------+
| description | OpenStack Compute Placement service |
| enabled     | True                                |
| id          | 7784b868e2074eeab1a849982d8c3422    |
| name        | placement                           |
| type        | placement                           |
+-------------+-------------------------------------+
[root@controller ~]# echo $controller

[root@controller ~]# openstack endpoint create --region RegionOne placement public http://controller:8778
+--------------+----------------------------------+
| Field        | Value                            |
+--------------+----------------------------------+
| enabled      | True                             |
| id           | 7d3431bb046649658a7522b8c094b891 |
| interface    | public                           |
| region       | RegionOne                        |
| region_id    | RegionOne                        |
| service_id   | 7784b868e2074eeab1a849982d8c3422 |
| service_name | placement                        |
| service_type | placement                        |
| url          | http://controller:8778           |
+--------------+----------------------------------+
[root@controller ~]# openstack endpoint create --region RegionOne placement internal http://controller:8778
+--------------+----------------------------------+
| Field        | Value                            |
+--------------+----------------------------------+
| enabled      | True                             |
| id           | 87f08f420dbf42cfb309635a2b084db8 |
| interface    | internal                         |
| region       | RegionOne                        |
| region_id    | RegionOne                        |
| service_id   | 7784b868e2074eeab1a849982d8c3422 |
| service_name | placement                        |
| service_type | placement                        |
| url          | http://controller:8778           |
+--------------+----------------------------------+
[root@controller ~]# openstack endpoint create --region RegionOne placement admin http://controller:8778 
+--------------+----------------------------------+
| Field        | Value                            |
+--------------+----------------------------------+
| enabled      | True                             |
| id           | 6652e951aaa44a00bb2611b780728a13 |
| interface    | admin                            |
| region       | RegionOne                        |
| region_id    | RegionOne                        |
| service_id   | 7784b868e2074eeab1a849982d8c3422 |
| service_name | placement                        |
| service_type | placement                        |
| url          | http://controller:8778           |
+--------------+----------------------------------+
```

#### 安全并配置组件

- 安装nova软件包

```bash
yum --enablerepo=centos-openstack-pike install openstack-nova-api openstack-nova-conductor \
  openstack-nova-console openstack-nova-novncproxy \
  openstack-nova-scheduler
```
- 编辑``/etc/nova/nova.conf``文件并完成下面的操作

```bash
# 在``[DEFAULT]``部分，只启用计算和元数据API：
enabled_apis = osapi_compute,metadata

# 在``[api_database]``和``[database]``部分，配置数据库的连接：
[api_database]
...
connection = mysql+pymysql://nova:NOVA_DBPASS@controller/nova_api

[database]
...
connection = mysql+pymysql://nova:NOVA_DBPASS@controller/nova

# 在 “[DEFAULT]” 和 “[oslo_messaging_rabbit]”部分，配置 “RabbitMQ” 消息队列访问
[DEFAULT]
...
rpc_backend = rabbit

[oslo_messaging_rabbit]
...
rabbit_host = controller
rabbit_userid = openstack
rabbit_password = RABBIT_PASS

# 在 “[DEFAULT]” 和 “[keystone_authtoken]” 部分，配置认证服务访问：
[DEFAULT]
...
auth_strategy = keystone

[keystone_authtoken]
...
auth_uri = http://controller:5000
auth_url = http://controller:35357
memcached_servers = controller:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = nova
password = NOVA_PASS

# 在 [DEFAULT 部分，配置``my_ip`` 来使用控制节点的管理接口的IP 地址。
[DEFAULT]
...
my_ip = 10.1.1.2

# 在 [DEFAULT] 部分，使能 Networking 服务：
[DEFAULT]
...
use_neutron = True
firewall_driver = nova.virt.firewall.NoopFirewallDriver

# 默认情况下，计算服务使用内置的防火墙服务。由于网络服务包含了防火墙服务，你必须使用``nova.virt.firewall.NoopFirewallDriver``防火墙服务来禁用掉计算服务内置的防火墙服务

# 在``[vnc]``部分，配置VNC代理使用控制节点的管理接口IP地址 ：
[vnc]
...
vncserver_listen = $my_ip
vncserver_proxyclient_address = $my_ip

# 在 [glance] 区域，配置镜像服务 API 的位置：
[glance]
...
api_servers = http://controller:9292

# 在 [oslo_concurrency] 部分，配置锁路径：
[oslo_concurrency]
...
lock_path = /var/lib/nova/tmp

```

- 同步Compute 数据库

```bash
[root@controller ~]# su -s /bin/sh -c "nova-manage api_db sync" nova
Option "rpc_backend" from group "DEFAULT" is deprecated for removal (Replaced by [DEFAULT]/transport_url).  Its value may be silently ignored in the future.
[root@controller ~]# su -s /bin/sh -c "nova-manage db sync" nova
Option "rpc_backend" from group "DEFAULT" is deprecated for removal (Replaced by [DEFAULT]/transport_url).  Its value may be silently ignored in the future.
WARNING: cell0 mapping not found - not syncing cell0.
/usr/lib/python2.7/site-packages/pymysql/cursors.py:165: Warning: (1831, u'Duplicate index `block_device_mapping_instance_uuid_virtual_name_device_name_idx`. This is deprecated and will be disallowed in a future release.')
  result = self._query(query)
/usr/lib/python2.7/site-packages/pymysql/cursors.py:165: Warning: (1831, u'Duplicate index `uniq_instances0uuid`. This is deprecated and will be disallowed in a future release.')
  result = self._query(query)
  # 报警可以忽略
[root@controller ~]# for service in api consoleauth conductor scheduler novncproxy; do
systemctl start openstack-nova-$service
systemctl enable openstack-nova-$service
done
 su -s /bin/bash nova -c "nova-manage cell_v2 map_cell0 \
--database_connection mysql+pymysql://nova:NOVA_DBPASS@controller/nova_cell0"

su -s /bin/bash nova -c "nova-manage cell_v2 create_cell --name cell1 \
--database_connection mysql+pymysql://nova:NOVA_DBPASS@controller/nova \
--transport-url rabbit://openstack:RABBIT_PASS@controller:5672"
# 重启
for service in api consoleauth conductor scheduler novncproxy; do
systemctl restart openstack-nova-$service
done
```

- 启动 Compute 服务并将其设置为随系统启动

```bash
# systemctl enable openstack-nova-api.service \
  openstack-nova-consoleauth.service openstack-nova-scheduler.service \
  openstack-nova-conductor.service openstack-nova-novncproxy.service
# systemctl start openstack-nova-api.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service
```

### 安装和配置计算节点

> 安装和配置计算节点,计算节点需支持对虚拟化的硬件加速。

- 安装 openstack-nova-compute软件包

```bash
yum --enablerepo=centos-openstack-pike  install openstack-nova-compute
```

- 编辑``/etc/nova/nova.conf``文件并完成下面的操作

```bash
# 在``[DEFAULT]`` 和 [oslo_messaging_rabbit]部分，配置``RabbitMQ``消息队列的连接：
[DEFAULT]
...
rpc_backend = rabbit

[oslo_messaging_rabbit]
...
rabbit_host = controller
rabbit_userid = openstack
rabbit_password = RABBIT_PASS

# 在 “[DEFAULT]” 和 “[keystone_authtoken]” 部分，配置认证服务访问：
[DEFAULT]
...
auth_strategy = keystone

[keystone_authtoken]
...
auth_uri = http://controller:5000
auth_url = http://controller:35357
memcached_servers = controller:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = nova
password = NOVA_PASS
```


















