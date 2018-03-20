# 初识Kubernetes

## Kubernetes官网：https://kubernetes.io/

## kubernetes运行java web应用

## 环境准备

CentOS7 + Kubernetes

- 关闭自带防火墙

systemctl disable firewalld
systemctl stop firewalld

- 安装etcd和kubernetes(会自动安装docker)
yum install -y etcd kubernetes

- 修改配置文件

vim /etc/sysconfig/docker

OPTIONS='--selinux-enabled=false --insecure-registry gcr.io'

# Kubernetes apiserver 配置文件为/etc/kubernetes/apiserver，删除--admission_contorl参数

- 按顺序启动下面服务

[root@k8s ~]# systemctl start etcd
[root@k8s ~]# systemctl start docker
[root@k8s ~]# systemctl start kube-apiserver
[root@k8s ~]# systemctl start kube-controller-manager
[root@k8s ~]# systemctl start kube-scheduler
[root@k8s ~]# systemctl start kubelet
[root@k8s ~]# systemctl start kube-proxy

> 启动服务时，另外打开一个session使用 journalctl -f启动日志

- 错误日志：
actual_state_of_world.go:475] Failed to set statusUpdateNeeded to needed true because nodeName="127.0.0.1"  does not exist
Can't get Node "aniu-k8s", assuming iptables proxy, err: nodes "aniu-k8s" not found

- 启动完成，说明单机版的Kubernetes集群安装启动完成

## Kubernetes 使用

- 笔者使用Docker进行镜像下载地址为：https://hub.docker.com/u/kubeguide/

## 启动MySQL服务




