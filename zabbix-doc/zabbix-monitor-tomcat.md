# Zabbix 监控tomcat


- 环境准备

> Zabbix Version: 3.0.x + Java Version 1.8.x + Tomcat Version: 8.x

## Zabbis Server 配置

- 如果Zabbix server是编译安装的需要添加 --enable-java编译参数，笔者使用的是yum 源安装的zabbix相关服务

yum install -y zabbix-java-gateway
or
./configure --enable-java --prefix=$PREFIX && make && make install

- 配置java 网关

# egrep -v "^#|^$" zabbix_java_gateway.conf  # 
LISTEN_IP="0.0.0.0"
LISTEN_PORT=10052
PID_FILE="/var/run/zabbix/zabbix_java.pid"
START_POLLERS=50
TIMEOUT=3
# egrep -v "^#|^$" zabbix_server.conf # zabbix Server配置文件修改
JavaGateway=127.0.0.1
JavaGatewayPort=10052
StartJavaPollers=5


/etc/init.d/zabbix-java-gateway start # 启动java gateway

netstat -lntp | grep 10052  # 测试启动

- 添加catalina-jmx-remote.jar

> 添加catalina-jmx-remote.jar到zabbix java gateway的lib目录下，catalina-jmx-remote.jar包可在http://archive.apache.org/dist/tomcat/下，在各版本目录的bin/extras/子目录下

cd /usr/sbin/zabbix_java/lib
wget http://archive.apache.org/dist/tomcat/tomcat-8/v8.5.9/bin/extras/catalina-jmx-remote.jar

[root@zabbix ~]# /etc/init.d/zabbix-java-gateway restart
Shutting down zabbix java gateway:                         [  OK  ]
Starting zabbix java gateway:                              [  OK  ]
                                                    [  OK  ]
[root@zabbix ~]# /etc/init.d/zabbix-server restart
Shutting down Zabbix server:                               [  OK  ]
Starting Zabbix server:                                    [  OK  ]

- 下载测试工具cmdline-jmxclient-0.10.3.jar

## 被监控tomcat 端配置

- 添加catalina-jmx-remote.jar

cd /data/tomcats/tomcat-8080/lib/
wget http://archive.apache.org/dist/tomcat/tomcat-8/v8.5.9/bin/extras/catalina-jmx-remote.jar
#http://archive.apache.org/dist/tomcat/tomcat-8/v8.5.16/bin/extras/catalina-jmx-remote.jar

- 修改tomcat的catalina.sh启动脚本

# vim /data/tomcats/tomcat-8080/bin/catalina.sh
CATALINA_OPTS="
-Dcom.sun.management.jmxremote 
-Dcom.sun.management.jmxremote.port=10052  #jmx监听的端口，需要和jmx服务端指定的一直
-Dcom.sun.management.jmxremote.ssl=false 
-Dcom.sun.management.jmxremote.authenticate=false 
-Djava.rmi.server.hostname=192.168.0.97"  #tomcat 自己的主机地址

CATALINA_OPTS="
-Dcom.sun.management.jmxremote 
-Dcom.sun.management.jmxremote.port=12345
-Dcom.sun.management.jmxremote.ssl=false 
-Dcom.sun.management.jmxremote.authenticate=false"

> 编辑完成重启tomcat

- 使用cmdline-jmxclient-0.10.3.jar 测试

# java -jar cmdline-jmxclient-0.10.3.jar - 192.168.0.97:10052 java.lang:type=Memory NonHeapMemoryUsage
08/23/2017 19:55:02 +0800 org.archive.jmx.Client NonHeapMemoryUsage: 
committed: 38797312
init: 2555904
max: -1
used: 37130952










