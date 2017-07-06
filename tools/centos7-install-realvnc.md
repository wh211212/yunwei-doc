# CentOS7 安装realvnc

> 官网教程：https://www.realvnc.com/docs/redhat-install-remove.html

## 下载安装包

wget https://www.realvnc.com/download/file/vnc.files/VNC-6.1.1-Linux-x64-RPM.tar.gz

## 安装VNC Connect

> 安装依赖

yum install -y xterm

yum remove tigervnc xvnc vncpasswd

tar zxvf VNC-6.1.1-Linux-x64-RPM.tar.gz
rpm -ivh VNC-Viewer-6.1.1-Linux-x64.rpm
