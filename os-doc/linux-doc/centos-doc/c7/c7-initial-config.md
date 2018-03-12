# 创建账号
useradd -s /bin/bash -d /home/wh -m wh && echo 211212 | passwd --stdin wh && echo "wh ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/wh

# 禁用selinux、关闭firewall

systemctl stop firewalld && systemctl disable firewalld 

sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config && getenforce

# 关闭邮件服务

systemctl stop postfix && systemctl disable postfix

## 更新系统

yum update -y

## 配置源

yum -y install yum-plugin-priorities && yum -y install epel-release


