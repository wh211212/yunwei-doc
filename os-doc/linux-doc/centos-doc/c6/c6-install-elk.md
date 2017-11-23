# CentOS6 配置ELK-6日志平台

## 安装Elasticsearch

- 通过elastic官方源安装

rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

vim /etc/yum.repos.d//elasticsearch.repo
[elasticsearch-6.x]
name=Elasticsearch repository for 6.x packages
baseurl=https://artifacts.elastic.co/packages/6.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md

