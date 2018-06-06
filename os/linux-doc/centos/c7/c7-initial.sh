#!/usr/bin/env bash
# ***********************************************
# @Time     : 2018/3/9 20:21
# @Author   : shaonbean@qq.com
# @Software : PyCharm
# @Blog     : http://blog.csdn.net/wh211212
# ***********************************************
# CentOS 7 Initial
useradd -s /bin/bash -d /home/wh -m wh && echo 211212 | passwd --stdin wh && echo "wh ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/wh

systemctl stop firewalld && systemctl disable firewalld

sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config && getenforce

systemctl stop postfix && systemctl disable postfix

yum update -y

yum -y install yum-plugin-priorities && yum -y install epel-release

yum install vim lrzsz -y


