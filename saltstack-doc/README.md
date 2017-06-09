# ops-saltstack

Saltstack 实现自动化部署“中小型web架构”：

1、架构功能和应用
  系统初始化
  Haproxy服务
  Keepalived服务
  Nginx服务
  PHP（FastCGI）服务
  Memcached服务

  案例架构图如下：
![](https://github.com/wh211212/ops-saltstack/blob/master/salt/base/images/ops-saltstack.png "ops-saltstack")

2、环境规划
  环境规划包括两种：
    实践案例的网络配置及服务器环境
    SaltStack中file_roots和Pillar_roots定义的SaltStack环境
2.1.1 实现环境设置
  需要至少两台以上的虚拟机或者物理机，本教程的实验环境如表2-1所示。
  案例实验环境
  saltstack-master	10.1.1.97	master、minion、Haproxy+Keepalived、Nginx+PHP	CentOS 6.8 mininal
  saltstack-minion	10.1.1.98	Minion、Memcached、Haproxy+Keepalived、Nginx+PHP	CentOS 6.8 mininal

2.1.2 Saltstack环境设置
  SaltStack环境设置
  使用两个环境base和prod，base环境用来存放初始化的功能，prod环境用于放置生产的配置管理功能：
  编辑master配置文件
  [root@saltstack-master ~]# egrep -v "^#|^$" /etc/salt/master
  #Filse Server settings
  file_roots:
    base:
      - /srv/salt/base
    prod:
      - /srv/salt/prod
  #Pillar settings
  pillar_roots:
    base:
      - /srv/pillar/base
    prod:
      - /srv/pillar/prod

参考链接：
http://docs.saltstack.cn/zh_CN/latest/topics/tutorials/starting_states.html
https://docs.saltstack.com/en/latest/
https://github.com/ist0ne/salt-states

#append
  架构优化：
  数据持久层采用MySQL，MySQL采用主从模式，提高可用性，缓冲层增加Redis服务减轻Memcached服务的压力，增加自动化部署Tomcat服务的模块，方便快速调用。

#services
  通过saltstack快速部署jdk环境，并安装tomcat服务及相关设置。
  "db-mysql":tomcat,redis,lnmp

#LNMP架构
  1、通过saltstack快速部署lnmp架构，修改/etc/master，添加/srv/salt/dev环境，作为分布式监控系统搭建的base环境。
  2、使用Zabbix搭建企业级分布式监控系统。
  3、Zabbix架构及Zabbix监控系统架构
  ![Zabbix](https://github.com/wh211212/ops-saltstack/blob/master/salt/base/images/zabbix.png "zabbix")

  ![Zabbix-net](https://github.com/wh211212/ops-saltstack/blob/master/salt/base/images/zabbix-net.png "Zabbix分布式监控系统")

#Salt SSH
  1、Salt Rosters
  、

# saltstack 安装

rpm --import https://repo.saltstack.com/yum/redhat/6/x86_64/latest/SALTSTACK-GPG-KEY.pub

cat > /etc/yum.repos.d/saltstack.repo << EOF
[saltstack-repo]
name=SaltStack repo for RHEL/CentOS $releasever
baseurl=https://repo.saltstack.com/yum/redhat/$releasever/$basearch/latest
enabled=1
gpgcheck=1
gpgkey=https://repo.saltstack.com/yum/redhat/$releasever/$basearch/latest/SALTSTACK-GPG-KEY.pub  
EOF
