# 常用ansible命令

- 执行系统命令
```
[root@ansible ~]# ansible pinpoint -m shell -a 'hostname' -o  # 执行系统命令
192.168.0.102 | SUCCESS | rc=0 | (stdout) pinpoint-agent
192.168.0.101 | SUCCESS | rc=0 | (stdout) apm-pinpoint
```

- 文件复制
```
[root@ansible ~]# echo "itdevops is useful" > devops.txt
[root@ansible ~]# ansible pinpoint -m copy -a 'src=devops.txt dest=/root/devops.txt owner=root group=root mode=644 backup=yes' -o
192.168.0.102 | SUCCESS => {"changed": true, "checksum": "59e127fdd346abcd4a2e348e44691600018d95d5", "dest": "/root/devops.txt", "gid": 0, "group": "root", "md5sum": "9ada44440028d3aa4582f7d5cfcbfe99", "mode": "0644", "owner": "root", "size": 19, "src": "/root/.ansible/tmp/ansible-tmp-1489047961.58-135666976081973/source", "state": "file", "uid": 0}
192.168.0.101 | SUCCESS => {"changed": true, "checksum": "59e127fdd346abcd4a2e348e44691600018d95d5", "dest": "/root/devops.txt", "gid": 0, "group": "root", "md5sum": "9ada44440028d3aa4582f7d5cfcbfe99", "mode": "0644", "owner": "root", "size": 19, "src": "/root/.ansible/tmp/ansible-tmp-1489047961.6-141588290458447/source", "state": "file", "uid": 0}
[root@ansible ~]# ansible pinpoint -m shell -a 'cat /root/devops.txt' -o
192.168.0.102 | SUCCESS | rc=0 | (stdout) itdevops is useful
192.168.0.101 | SUCCESS | rc=0 | (stdout) itdevops is useful
```

- 软件包管理
```
[root@ansible ~]# ansible pinpoint -m yum -a 'name=lrzsz state=latest' -o     # 安装软件包
192.168.0.101 | SUCCESS => {"changed": false, "msg": "", "rc": 0, "results": ["All packages providing lrzsz are up to date", ""]}
192.168.0.102 | SUCCESS => {"changed": false, "msg": "", "rc": 0, "results": ["All packages providing lrzsz are up to date", ""]}

[root@ansible ~]# ansible pinpoint -m yum -a "name=lrzsz state=present"  # yum install lrzsz -y
[root@ansible ~]# ansible pinpoint -m yum -a "name=lrzsz state=absent"   # yum erase lrzsz -y
```
- 用户管理
```
[root@ansible ~]# echo ansible | openssl passwd -1 -stdin   # 使用openssl生成家加密密码
$1$7nQb45m/$QhN9DIM77y5A.CRyrHP.g/
[root@ansible ~]# ansible pinpoint -m user -a 'name=shaon password="$1$7nQb45m/$QhN9DIM77y5A.CRyrHP.g/"' -o
```
