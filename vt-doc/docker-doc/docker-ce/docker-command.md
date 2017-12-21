# Docker 常用命令收录

## 容器操作

```
docker build -t friendlyname .  # 使用当前目录下的内容创建Dockerfile镜像文件
docker run -p 4000:80 friendlyname  # 运行名为“friendlyname”的镜像，并设置端口映射
docker run -d -p 4000:80 friendlyname         # 后台运行容器
docker container ls                                # 查看运行中的容器
docker container ls -a             # 查看所有的容器，包括为运行的
docker container stop <hash>           # 优雅的停止容器进程
docker container kill <hash>         # 张志停止容器进程
docker container rm <hash>        # 从当前机器移除指定容器
docker container rm $(docker container ls -a -q)         # 移除所有容器
docker image ls -a                             # 查看当前机器上的所有镜像
docker image rm <image id>            # 从当前机器上移除指定镜像
docker image rm $(docker image ls -a -q)   # 从机器上移除所有容器
docker login             # 使用docker用户名密码登录CLI
docker tag <image> username/repository:tag  # 给镜像打标签
docker push username/repository:tag            # 上传镜像到笔者个人仓库
docker run username/repository:tag                   # 运行指定镜像的指定版本
```

## 服务相关

```
docker stack ls                                            # 列出应用程序
docker stack deploy -c <composefile> <appname>  # 运行制动的composefile
docker service ls                 # 列出与应用关联的正在运行的服务
docker service ps <service>                  # 列出与应用程序关联的任务
docker inspect <task or container>                   # 检查任务或容器状态
docker container ls -q                                      # 列出容器ID
docker stack rm <appname>                             # 删除一个应用程序
docker swarm leave --force      # 用swam管理下掉集群的一个节点
```