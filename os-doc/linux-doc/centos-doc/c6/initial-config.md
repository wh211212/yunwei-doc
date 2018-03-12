# CentOS6 最小化安装完成后初始化

## 关闭防火墙和SELINUX

/etc/rc.d/init.d/iptables stop
/etc/rc.d/init.d/ip6tables stop
chkconfig iptables off
chkconfig ip6tables off

sed -i 's/enforcing/disabled/' /etc/selinux/config
setenforce 0

## 关闭不必要的服务

/etc/rc.d/init.d/netfs stop
chkconfig netfs off

## 更新系统

yum -y install yum-plugin-fastestmirror
yum -y update

## 添加EPEL源

rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm

## 定时任务设置

yum -y install cronie-noanacron
# yum remove cronie-anacron -y

## 配置vim

yum -y install vim-enhanced lrzsz
#echo " alias vi='vim' " >>  /etc/profile
echo "alias vi='vim' " >> ~/.bashrc
#source /etc/profile
source ~/.bashrc

## 添加用户

useradd yunwei
echo anwg123. | passwd --stdin yunwei

# 修改hosts文件
