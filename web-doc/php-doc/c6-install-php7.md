# CentOS6 安装php7

 yum -y install http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
 
yum install php php-fpm php-bcmatch php-gd php-mbstring php-mcrypt php-mysql  
 
# 安装php相关功能模块
yum --enablerepo=remi-safe -y install php72-php php72-php-common php72-php-pear php72-php-enchant php72-php-gd php72-php-mcrypt php72-php-fpm php72-php-recode php72-php-xml php72-php-mbstring php72-php-mysql php72-php-cli

# 
php72 -v

 # os initial
yum update -y

hostname=gp-tv189-2

sed -i 's/localhost.localdomain/gp-tv189-2/g' /etc/sysconfig/network
echo "127.0.0.1   localhost localhost.localdomain gp-tv189-2" >> /etc/hosts
hostname gp-tv189-2


# install nginx
yum install nginx -t

# config nginx


# install php

yum install php php-fpm php-pear php-pdo php-pecl-memcache php-mbstring php-mysql php-gd php-xml php-xmlrpc php-tidy php-devel php-cli php-common php-redis -y


# pull web code
git config --global http.sslVerify false 
git clone https://yunwei:anwg123.@gitlab.aniu.so/aniu-web/tv189.git pc-tv189