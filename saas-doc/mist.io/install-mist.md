# CentOS6 安装mist.io

> Mist.io不仅作为SaaS提供，而且还作为独立安装的开源软件组件，使组织和工程师能够在内部管理其基础设施。

> 开源组件可以连接到Mist.io服务进行监控。目前，它缺乏SaaS提供的一些功能，即日志部分以及创建和运行脚本的功能。

## 通过docker镜像安装mist.io

> https://registry.hub.docker.com/u/mist/mistio/

```
[root@zabbix ~]# docker pull mist/mistio
[root@zabbix ~]# docker images
REPOSITORY                      TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
mist/mistio                     latest              4128f7bf09a8        14 months ago       1.305 GB
[root@zabbix ~]# docker run --name mistio -d --publish 8000:8000 mist/mistio
[root@zabbix ~]# docker ps # 查看运行的容器
CONTAINER ID        IMAGE                           COMMAND                CREATED             STATUS              PORTS                              NAMES
63ec842434be        mist/mistio                     "/bin/sh -c /init.sh   2 minutes ago       Up 2 minutes        0.0.0.0:8000->8000/tcp             mistio
```

> 上述命令将Docker镜像引导为守护进程，并将其暴露在8000端口,现在可以在ip：8000上启动浏览器，例如http://192.168.0.99:8000/，您应该看到Mist.io UI


> 如果mist.io安装失败，通过查看日志看报错

## 可以使用docker exec -it ID / bin / bash访问带有bash的容器

```
docker exec -it 63ec842434be /bin/bash
```
- 获取最新的mist.io镜像

```
docker pull mist/mistio
```

## 通过buildout按住样mist.io

```
sudo yum install git python-virtualenv python-devel erlang pcre python-lxml gcc libxml2 libxml2-python libxml2-devel python-zc-buildout
# 具体详细教程参考下面链接，这里不多做介绍
```

## 补充通过docker-compose安装mistio

- 安装docker-compose

```
[root@zabbix ~]# curl -L https://github.com/docker/compose/releases/download/1.14.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
102   617    0   617    0     0    610      0 --:--:--  0:00:01 --:--:--  2056
100 8084k  100 8084k    0     0   210k      0  0:00:38  0:00:38 --:--:-- 1984k
# 添加权限及设置软链接

[root@zabbix ~]# chmod +x /usr/local/bin/docker-compose
[root@zabbix ~]# ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```

- 从github下载mist.io最新版本的yaml配置文件，编辑修改监听的端口，通过docker-compose运行mistio,mistio docker-compose.yanl配置文件默认启用的是80端口作为UI,api等服务的监听端口，本机实验环境的80端口已经被使用，更改80为8000

```
# 下载mistio docker-compose配置文件
[yunwei@zabbix ~]$ wget https://github.com/mistio/mist.io/releases/download/v2.0.0/docker-compose.yml
# 更改端口
[root@zabbix yunwei]# sed -i 's/80/8000/g' docker-compose.yml
[root@zabbix yunwei]# sed -i 's/800081/8081/g' docker-compose.yml
# 运行docker-compose
docker-compose up -d  # 报错，docker engine版本太低
```
- 在另外一台CentOS7 测试下安装测试

```

```

- 报错：

```
[root@docker-1 ~]# docker-compose up -d  # 报错，docker engine版本太低
ERROR: Couldn't connect to Docker daemon at http+docker://localunixsocket - is it running?

If it's at a non-standard location, specify the URL with the DOCKER_HOST environment variable.
# 好像是Docker没启动导致的报错
```

## 参考链接

- http://docs.mist.io/article/39-installation
