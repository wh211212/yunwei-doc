# CentOS6 安装并破解confluence

## Confluence 简介

> confluence是一个专业的企业知识管理与协同软件，可以用于构建企业wiki。通过它可以实现团队成员之间的协作和知识共享。

- Confluence官网：https://www.atlassian.com/software/confluence


## 安装环境准备

- jdk1.8
- mysql5.6

> 参考jira破解安装，这里笔者把Confluence和jira安装到同一台服务器，因此上面环境配置参考：http://blog.csdn.net/wh211212/article/details/76020723

## 为Confluence创建对应的数据库、用户名和密码

```
mysql -uroot -p'211212' -e "create database confluence default character set utf8 collate utf8_bin;grant all on confluence.* to 'confluence'@'%' identified by 'confluencepasswd';"
# 根据自己的习惯，重新定义Confluence的用户名和密码
```

## 下载confluence安装文件及其破解包

- Confluence下载：https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-6.3.1-x64.bin （当前最新版本）
- 链接：http://pan.baidu.com/s/1qXY29Fu 密码：1w9g # confluence-6.x 破解用jar包

> 这里建议直接在服务器上面通过wget下载Confluence安装文件，下载到本地的上传到服务器过程中有可能损坏安装文件导致不能正常安装

## 安装并破解confluence

- 安装confluence

```
# 移动到confluence安装文件所在目录，执行下面命令进行安装：
chmod +x atlassian-confluence-6.3.1-x64.bin
sudo ./atlassian-confluence-6.3.1-x64.bin
```
![confluence-install](http://img.blog.csdn.net/20170725212450667?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

> 通过上图可以看出confluence安装到了/opt/atlassian/confluence和/var/atlassian/application-data/confluence目录下，并且confluence默认监听的端口是8090.一路默认安装即可
> 注：confluence的主要配置文件，为/opt/atlassian/confluence/conf/server.xml，和jira类似。此server.xml相当于tomcat中的server.xml配置文件

## 配置通过域名访问confluence

- 启动完成之后，通过ip地址访问confluence如下图

![access-confluence](http://img.blog.csdn.net/20170725212641344?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

### 使用NGINX代理Confluence的请求

- 更改confluence的配置文件server.xml

```
更改前：<Context path="" docBase="../confluence" debug="0" reloadable="false">

更改后：<Context path="/confluence" docBase="../confluence" debug="0" reloadable="false">
```

- 设置url重定向

```
<Connector port="8090" connectionTimeout="20000" redirectPort="8443"
           maxThreads="48" minSpareThreads="10"
           enableLookups="false" acceptCount="10" debug="0" URIEncoding="UTF-8"
           protocol="org.apache.coyote.http11.Http11NioProtocol"
           proxyName="wiki.aniu.so" proxyPort="80"/>
```

- 配置nginx

```
server {
    listen wiki.aniu.so:80;
    server_name wiki.aniu.so;
    location /confluence {
        client_max_body_size 100m;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Server $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://localhost:8090/confluence;
    }
    location /synchrony {
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Server $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://localhost:8091/synchrony;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
    }
}
# 配置完成重启confluence和nginx，然后通过域名:http://wiki.aniu.so/confluence 访问confluence
```

![access-confluence](http://img.blog.csdn.net/20170725214226801?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

> 从上图可以看出，通过域名nginx代理confluence已经成功，这里设置为中文继续安装。

![install-confluence](http://img.blog.csdn.net/20170725214443502?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

> 选择产品安装并点击下一步，继续安装

![license](http://img.blog.csdn.net/20170725214656124?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 这里由于没有插件授权先不勾选，点击下一步


![crack](http://img.blog.csdn.net/20170725214826129?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 通过上图可以看出需要输入授权码，下面介绍破解授权码。

### 破解confluence

- 复制上述截图中的Server ID（BEBV-EVUW-VSN5-KJMK），然后关闭confluence，使用如下命令：

> http://www.techlife.com.cn/?thread-2.htm

```
1、安装Confluence，需要KEY的时候从官网直接申请一个测试KEY
2、替换俩个文件，分别是
/opt/atlassian/confluence/confluence/WEB-INF/lib/atlassian-extras-decoder-v2-3.2.jar
/opt/atlassian/confluence/confluence/WEB-INF/atlassian-bundled-plugins/atlassian-universal-plugin-manager-plugin-2.22.jar
替换前必须做备份，方便回退。
3、重启Confluence服务，正常使用产品。
```
![gey-key](http://img.blog.csdn.net/20170726111416048?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 选择外界数据库

![choice-db](http://img.blog.csdn.net/20170726111400846?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 连接数据库信息

![jdbc](http://img.blog.csdn.net/20170726111506926?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 使用mysql

![connect-mysql](http://img.blog.csdn.net/20170726122540686?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 选择空白站点继续安装：

![jira](http://img.blog.csdn.net/20170726122729893?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

![这里写图片描述](http://img.blog.csdn.net/20170726122927444?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 由于我的jira是https的，导致confluence集成jira时除了问题，就使用confluence自己管理账户。

![这里写图片描述](http://img.blog.csdn.net/20170726123224700?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 进入欢迎界面

![这里写图片描述](http://img.blog.csdn.net/20170726123442891?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
![这里写图片描述](http://img.blog.csdn.net/20170726123452761?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
![这里写图片描述](http://img.blog.csdn.net/20170726123804760?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 到这里，confluence安装使用已经基本完成，然后开始破解。

```
替换文件，
/opt/atlassian/confluence/confluence/WEB-INF/lib/atlassian-extras-decoder-v2-3.2.jar
# 从百度云下载破解用的jar文件，然后重启confluence
```
