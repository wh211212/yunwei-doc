# 安装gitlab
https://about.gitlab.com/installation/#centos-6

sudo yum install -y curl openssh-server openssh-clients cronie
sudo lokkit -s http -s ssh

curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash
sudo yum install -y gitlab-ce

## 编辑gitlab.rb

同步现有gitlab配置



sudo gitlab-ctl reconfigure


