# 在企业Linux主机上部署自托管引擎

## 安装ovirt官方源

yum install http://resources.ovirt.org/pub/yum-repo/ovirt-release42.rpm -y

- 安装自托管引擎包：
yum install ovirt-hosted-engine-setup -y

- 安装引擎虚拟机安装的oVirt引擎虚拟设备软件包：
yum install ovirt-engine-appliance -y

## 配置基于EL的自托管引擎

