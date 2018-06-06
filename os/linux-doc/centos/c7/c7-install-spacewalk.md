# CentOS7 安装Spacewalk

> Spacewalk是一个开源的Linux系统管理解决方案。
> Spacewalk官网：https://spacewalkproject.github.io/

## Spacewalk安装

- 为Spacewalk配置必需的存储库。下载前确保最新的RPM。

```bash
yum install -y http://yum.spacewalkproject.org/latest/RHEL/7/x86_64/spacewalk-repo-2.7-2.el7.noarch.rpm
#
[root@localhost ~]# rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
Retrieving https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
warning: /var/tmp/rpm-tmp.wzo1mP: Header V3 RSA/SHA256 Signature, key ID 352c64e5: NOKEY
Preparing...                          ################################# [100%]
Updating / installing...
   1:epel-release-7-11                ################################# [100%]
[root@localhost ~]# (cd /etc/yum.repos.d && curl -O https://copr.fedorainfracloud.org/coprs/g/spacewalkproject/java-packages/repo/epel-7/group_spacewalkproject-java-packages-epel-7.repo)
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   395  100   395    0     0    456      0 --:--:-- --:--:-- --:--:--   456
```

- 可以选择PostgreSQL和Oracle 10g或更高版本使用的后端数据库。笔者选择PostgreSQL。

```bash
yum -y install spacewalk-setup-postgresql spacewalk-postgresql perl dojo
```

