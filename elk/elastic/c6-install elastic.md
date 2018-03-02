# 使用rpm安装elastic

 

[root@elk-stack yum.repos.d]# cat elasticsearch.repo 
[elasticsearch-6.x]
name=Elasticsearch repository for 6.x packages
baseurl=https://artifacts.elastic.co/packages/6.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md

# 
sudo yum install elasticsearch -y
sudo chkconfig --add elasticsearch

sudo -i service elasticsearch start
sudo -i service elasticsearch stop

