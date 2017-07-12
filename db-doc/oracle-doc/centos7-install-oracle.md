# CentOS7安装Oracle Database 12c

> 安装依赖，安装桌面环境，安装依赖包

```
# 安装桌面环境
yum -y update
yum -y groups install "GNOME Desktop"
startx  # 启动桌面环境
```
## 从epel源安装
yum -y install novnc python-websockify numpy

openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/pki/tls/certs/novnc.pem -out /etc/pki/tls/certs/novnc.pem -days 365
