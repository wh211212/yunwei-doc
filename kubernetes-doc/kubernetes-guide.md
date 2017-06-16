# kubernetes learn

> https://kubernetes.io/

# kubernetes 解决方案

> https://kubernetes.io/docs/setup/pick-right-solution/

## Running Kubernetes Locally via Minikube

> Minikube是一种易于在本地运行Kubernetes的工具。 Minikube在您的笔记本电脑上的虚拟机内运行单节点Kubernetes群集，以便用户试图尝试使用Kubernetes或日常开发。

## Minikube Features

> DNS NodePorts ConfigMaps and Secrets Dashboards Container Runtime: Docker, and rkt Enabling CNI Ingress

## 安装Minikube

> 必须在计算机的BIOS中启用VT-x或AMD-v虚拟化。

## 安装Hypervisor(这里很坑)

> For Linux, install VirtualBox or KVM.

```
sudo yum install libvirt-daemon-kvm kvm -y # 貌似不行，应该是没启动导致
# 使用VirtualBox
wget http://yum.oracle.com/public-yum-ol7.repo
yum install VirtualBox-5.1 -y
```

## 安装kubectl

> 通过curl安装kubectl二进制文件

```
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
# 下载特定版本使用
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.6.3/bin/linux/amd64/kubectl
#
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```

## 安装Minikube from github

> https://github.com/kubernetes/minikube/releases

```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.19.1/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
```

# Minikube使用

```
[root@docker yum.repos.d]# minikube start
Starting local Kubernetes v1.6.4 cluster...
Starting VM...
E0616 16:34:45.719488    4099 start.go:127] Error starting host: Error creating host: Error with pre-create check: "VBoxManage not found. Make sure VirtualBox is installed and VBoxManage is in the path".
```
> 安装VirtualBox

```
wget http://download.virtualbox.org/virtualbox/rpm/rhel/virtualbox.repo
yum install VirtualBox-5.1 -y
```

> E0616 16:43:13.516212    4988 start.go:133] Error starting host:  Error creating host: Error with pre-create check: "We support Virtualbox starting with version 5. Your VirtualBox install is \"WARNING: The vboxdrv kernel module is not loaded. Either there is no module\\n         available for the current kernel (3.10.0-514.21.1.el7.x86_64) or it failed to\\n         load. Please recompile the kernel module and install it by\\n\\n           sudo /sbin/vboxconfig\\n\\n         You will not be able to start VMs until this problem is fixed.\\n5.1.22r115126\". Please upgrade at https://www.virtualbox.org"

- 启动virtualbox

```
 [root@docker ~]# /usr/lib/virtualbox/vboxdrv.sh setup
vboxdrv.sh: Stopping VirtualBox services.
vboxdrv.sh: Building VirtualBox kernel modules.
This system is not currently set up to build kernel modules (system extensions).
Running the following commands should set the system up correctly:

  yum install gcc make
  yum install kernel-devel-3.10.0-514.21.1.el7.x86_64
(The last command may fail if your system is not fully updated.)
  yum install kernel-devel
vboxdrv.sh: failed: Look at /var/log/vbox-install.log to find out what went wrong.

```

> 安装依赖，重新启动

```
yum install gcc make kernel-devel -y
#
[root@docker yum.repos.d]# /usr/lib/virtualbox/vboxdrv.sh setup
vboxdrv.sh: Stopping VirtualBox services.
vboxdrv.sh: Building VirtualBox kernel modules.
vboxdrv.sh: Starting VirtualBox services.
```

- 再次启动minikube

```
[root@docker ~]# minikube start
Starting local Kubernetes v1.6.4 cluster...
Starting VM...
Moving files into cluster...
Setting up certs...
Starting cluster components...
Connecting to cluster...
Setting up kubeconfig...
Kubectl is now configured to use the cluster.
```

##
