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

缺图

> 通过上图可以看出confluence安装到了/opt/atlassian/confluence和/var/atlassian/application-data/confluence目录下，并且confluence默认监听的端口是8090.
> 注：confluence的主要配置文件，为/opt/atlassian/confluence/conf/server.xml，和jira类似。此server.xml相当于tomcat中的server.xml配置文件

## 配置通过域名访问confluence
