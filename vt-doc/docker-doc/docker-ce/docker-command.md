# docker 常用命令总结

## 容器篇

- 使用当前目录下的Dockerfile创建一个镜像文件

docker build -t images_name .

- 运行 “images_name” 映射端口80到80

docker run -p 80:80 images_name

- 后台运行

docker run -d -p 80:80 images_name

- 查看所有正在运行的容器

docker container ls 

- 查看所有的容器,包括正在运行的，和停止运行的

docker container ls -a

- 有好的停止一个容器

docker container stop container_id

- 强制停止一个容器

docker container kill <hash:container_id> 

- 从本机删除指定容器

docker container rm <hash>

- 删除所有容器

docker container rm $(docker container ls -a -q) 

- 列出本机所有的镜像

docker image ls -a 

- 从本机删除指定镜像

docker image rm <image id>

- 删除所有容器

docker image rm $(docker image ls -a -q)

- 命令行登录docker




