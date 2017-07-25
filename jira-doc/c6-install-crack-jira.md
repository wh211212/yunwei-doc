

# CentOS6 安装并破解Jira 7

> JIRA软件是为您的软件团队的每个成员构建的，用来规划，跟踪和发布优秀的软件。

- https://confluence.atlassian.com/adminjiraserver074/installing-jira-applications-on-linux-881683168.html

## 最低硬件要求及软件安装

> 最小硬件依赖

- CPU: Quad core 2GHz+ CPU
- RAM: 6GB
- Minimum database space: 10GB

-------------------------------------

- 更新系统，安装java环境

```
# 注意：jira需要oracle的java,默认的openjdk是不行的
# http://www.oracle.com/technetwork/java/javase/downloads/index.html，下载jdk-8u131-linux-x64.rpm，然后上传到/usr/local/src
yum localinstall jdk-8u131-linux-x64.rpm -y
# 查看jdk是否安装成功
# java -version
java version "1.8.0_131"
Java(TM) SE Runtime Environment (build 1.8.0_131-b11)
Java HotSpot(TM) 64-Bit Server VM (build 25.131-b11, mixed mode)
```

- 安装mysql5.6,并创建jira数据库及jira用户，后面安装时会用到

> 注意：jira是支持5.7的，但是Confluence不支持5.7，所以这里安装mysql5.下载mysql的yum包 https://dev.mysql.com/downloads/ 安装

```
# 服务器配置mysql repo源，https://dev.mysql.com/downloads/repo/yum/，下载mysql57-community-release-el6-11.noarch.rpm然后上传到/usr/local/src
# 默认启用的是5.7，更改为5.6
[mysql56-community]
name=MySQL 5.6 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.6-community/el/7/$basearch/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

[mysql57-community]
name=MySQL 5.7 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/$basearch/
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
-----------------
# 安装mysql
yum clean all && yum install mysql-community-server -y
# 启动mysql并设置自启
# /etc/init.d/mysqld start
Initializing MySQL database:
  /usr/bin/mysqladmin -u root password 'new-password'
  /usr/bin/mysqladmin -u root -h sh-kvm-3-1 password 'new-password'

Alternatively you can run:

  /usr/bin/mysql_secure_installation
--defaults-file argument to mysqld_safe when starting the server

                                                           [  OK  ]
Starting mysqld:                                           [  OK  ]

# 初始化mysql并重置密码
/usr/bin/mysql_secure_installation
# 创建jira数据库和jira用户
mysql -uroot -p'211212' -e "create database jira;grant all on jira.* to 'jira'@'%' identified by 'jirapasswd';"
# 测试jira连接mysql
 mysql -ujira -pjirapasswd # 连接成功
```

## 安装jira

> JIRA下载地址：https://www.atlassian.com/software/jira/download，下载，然后上传到/usr/local/src

wget https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-7.4.1-x64.bin

```
cd /usr/local/src
chmod a+x atlassian-jira-software-7.4.1-x64.bin
sudo ./atlassian-jira-software-7.4.1-x64.bin
# 使用默认安装,安装完成会启动jira
```
- 关闭已启动的jira，然后把破解包里面的atlassian-extras-3.2.jar和mysql-connector-java-5.1.42-bin.jar两个文件复制到/opt/atlassian/jira/atlassian-jira/WEB-INF/lib/目录下

```
/opt/atlassian/jira/bin/stop-jira.sh # 停止jira
/opt/atlassian/jira/bin/start-jira.sh # 启动jira
```

- 其中atlassian-extras-2.jar是用来替换原来的atlassian-extras-2.jar文件，用作破解jira系统的。

- 而mysql-connector-java-5.1.42-bin.jar是用来连接mysql数据库的驱动软件包

- 重新启动jira，访问ip：8080

## 安装成功并启动jira，通过浏览器访问

![这里写图片描述](http://img.blog.csdn.net/20170724162724316?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

> langguage可以选择语言，默认支持中文，选择自己安装，然后继续

![这里写图片描述](http://img.blog.csdn.net/20170724163037184?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 配置域名访问http://jira.aniu.so/jira

![这里写图片描述](http://img.blog.csdn.net/20170724174921012?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

> 注意：上图中的Mode中，我们在此使用的是Private模式，在这个模式下，用户的创建需要由管理员创建。而在Public模式下，用户是可以自己进行注册。

- 下面这个页面是需要我们输入jira的license，如下：

![这里写图片描述](http://img.blog.csdn.net/20170724175416223?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

> 注意：上图中的Server ID：BC2Z-EHVP-ERV0-RQUY

> 因为我们没有正式的license，所以需要我们在jira官网注册一个账号，然后利用这个账号申请一个可以试用30天的license，如下：

![这里写图片描述](http://img.blog.csdn.net/20170724175802250?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

> 注意：这个图中的Server ID就是我们上面刚刚截图的Server ID。

![这里写图片描述](http://img.blog.csdn.net/20170724175841990?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

> 点击生成许可证

![这里写图片描述](http://img.blog.csdn.net/20170724175951425?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 通过上图，我们可以很明显的看到试用license已经申请成功。下面开始创建管理员账户，点击Next（此过程较慢。需等待）如下：

![这里写图片描述](http://img.blog.csdn.net/20170724180357297?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

> 设置管理员的页面忘记截图，这里可以忽略，稍后设置邮件通知，点击继续出现欢迎界面。选择中文继续：

![这里写图片描述](http://img.blog.csdn.net/20170724180555844?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

![这里写图片描述](http://img.blog.csdn.net/20170724180712235?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 创建一个新项目

![这里写图片描述](http://img.blog.csdn.net/20170724181120225?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 选择开发方式

![这里写图片描述](http://img.blog.csdn.net/20170724181238700?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

![这里写图片描述](http://img.blog.csdn.net/20170724181334111?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

![这里写图片描述](http://img.blog.csdn.net/20170724181507715?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

![这里写图片描述](http://img.blog.csdn.net/20170724182021685?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 到此jira7.4.1软件的安装就已经基本快结束了，下面我们来介绍jira的破解

## jira破解

> 破解jira，其实我们已经破解了,在上面章节我们复制atlassian-extras-3.2.jar到/opt/atlassian/jira/atlassian-jira/WEB-INF/lib/目录下时，再次启动jira时就已经破解了。

![这里写图片描述](http://img.blog.csdn.net/20170724182732939?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

> 到这里，jira的安装和破解基本完成，等下放上破解jira的百度云链接,
> 链接：http://pan.baidu.com/s/1i5kRZgT 密码：5d4g

- jira使用中相关问题，后续会写博文介绍。
