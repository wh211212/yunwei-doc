# RocketMQ 介绍

> Apache RocketMQ™是一个开源的分布式消息传递和流数据平台。

- RocketMQ Github： https://github.com/apache/incubator-rocketmq/
- RocketMQ 文档：http://rocketmq.apache.org/docs

## 安装依赖

> 64bit OS, Linux/Unix/Mac + 64bit OS, Linux/Unix/Mac + Maven 3.2.x + Git

- 安装相关依赖

```
# 安装maven
[root@linuxprobe ~]# sudo wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
[root@linuxprobe ~]# yum install apache-maven -y

# 安装git
[root@linuxprobe ~]# yum install git -y
```
![install-maven](http://img.blog.csdn.net/20170911135028432?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 克隆和打包

```
[root@linuxprobe ~]# cd /opt
[root@linuxprobe opt]# git clone -b develop https://github.com/apache/incubator-rocketmq.git
[root@linuxprobe ~]# cd incubator-rocketmq
[root@linuxprobe incubator-rocketmq]# mvn -Prelease-all -DskipTests clean install -U （打包过程可能会比较久）
[root@linuxprobe incubator-rocketmq]# cd distribution/target/apache-rocketmq
```
![mvn-install](http://img.blog.csdn.net/20170911135947388?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 启动服务

```
[root@linuxprobe apache-rocketmq]# nohup sh bin/mqnamesrv &
# 查看日志
[root@linuxprobe apache-rocketmq]# tail -f ~/logs/rocketmqlogs/namesrv.log
```

![log-rocketmq](http://img.blog.csdn.net/20170911140223535?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 启动Broker

```
# 查看hosts解析
[root@linuxprobe ~]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain linuxprobe.com 
10.1.1.87 linuxprobe.com 
# 
[root@linuxprobe apache-rocketmq]# nohup sh bin/mqbroker -n linuxprobe.com:9876 &
[root@linuxprobe apache-rocketmq]# tail -f ~/logs/rocketmqlogs/broker.log
```
![这里写图片描述](http://img.blog.csdn.net/20170911174446844?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

![这里写图片描述](http://img.blog.csdn.net/20170911174456432?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

> 从图中可以看出Broker服务已经启动成功

- 发送和接送消息

> 提前设置环境变量：NAMESRV_ADDR
```
[root@linuxprobe apache-rocketmq]# export NAMESRV_ADDR=linuxprobe.com:9876
# 生产环境使用建议设置全局变量
[root@linuxprobe apache-rocketmq]# sh bin/tools.sh org.apache.rocketmq.example.quickstart.Producer
SendResult [sendStatus=SEND_OK, msgId= ...
[root@linuxprobe apache-rocketmq]# sh bin/tools.sh org.apache.rocketmq.example.quickstart.Consumer
ConsumeMessageThread_%d Receive New Messages: [MessageExt...
```
![Producer](http://img.blog.csdn.net/20170911175118257?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

![Consumer](http://img.blog.csdn.net/20170911175734407?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

> 笔者这里执行获取消息程序的时候出现啦阻塞（暂未解决）

- 停止服务

```
[root@linuxprobe apache-rocketmq]# export NAMESRV_ADDR=linuxprobe.com:9876
[root@linuxprobe apache-rocketmq]# sh bin/mqshutdown namesrv
```
![mqshutdown-rocketmq](http://img.blog.csdn.net/20170911175945156?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

## 参考链接

- http://rocketmq.apache.org/docs/quick-start/
- http://rocketmq.apache.org/docs/faq/

