# saltstack 常用命令

## 查看所有的KEYS

- salt-key --list-all

# 接受一个特定的钥匙

- salt-key --accept=<key>
- salt-key --accept-all

# 发送命令
在您接受每个密钥后，从Salt-Master发送一个命令，以验证您的Salt Minions是否正在侦听：

- salt '*' test.ping

# 运行命令

- salt '*' cmd.run 'ls -l /etc'

# 显示磁盤使用

- salt '*' disk.usage

# 安装包安裝

- salt '*' pkg.install cowsay

# 顯示網絡接口

- salt '*' network.interfaces

# 指定目標運行命令

- salt 'zabbix.aniu.so' network.interfaces
- salt '*.aniu.so' disk.usage  # 模糊匹配

# 基於系統類型進行匹配
```
[root@zabbix minions]# salt -G 'os:CentOS' test.ping
zabbix.aniu.so:
    True
jenkins.aniu.so:
    True
```
# 基于正则匹配目标

- salt -E 'minion[0-9]' test.ping

# 基于列表

- salt -L 'zabbix.aniu.so,jenkins.aniu.so' test.ping

# 基于组目标匹配

```
[root@zabbix minions]# salt -L 'zabbix.aniu.so,jenkins.aniu.so' test.ping
zabbix.aniu.so:
    True
jenkins.aniu.so:
    True
```

# 可以在一个命令中组合多个目标类型

- salt -C 'G@os:Ubuntu and minion* or S@192.168.50.*' test.ping

# 使用stats模块定义目标主机执行操作

# 定义入口文件
```
[root@zabbix salt]# cat top.sls
base:
  '*':
    - init.env_init
prod:
  '*':
    - init.test
```

# 执行定义好的state文件
salt '*' state.sls init.nettools test=True env=base

salt '*' state.sls init.test test=True env=prod # 测试执行

salt '*' state.sls init.test env=prod # 执行

# 使用state文件安装软件包

```
install vim:
  pkg.installed:
    - name: vim

    remove vim:
      pkg.removed:
        - name: vim
```

# 创建目录

```
create my_new_directory:
 file.directory:
   - name: /opt/my_new_directory
   - user: root
   - group: root
   - mode: 755
```
# 确认服务状态

```
Make sure the mysql service is running:
  service.running:
    - name: mysql
```

# 使用同一ID执行多个函数

```
Install mysql and make sure the mysql service is running:
  pkg.installed:
    - name: mysql
  service.running:
    - name: mysql
```

#
```
Make sure the redis service is running and enable it to start at boot:
  service.running:
    - name: redis
    - enable: True
```

# 下载GIT REPO

```
https://github.com/saltstack/salt-bootstrap:
  git.latest:
    - rev: develop
    - target: /tmp/salt
```
#

```
Clone the SaltStack bootstrap script repo:
  pkg.installed:
    - name: git # make sure git is installed first!
  git.latest:
    - name: https://github.com/saltstack/salt-bootstrap
    - rev: develop
    - target: /tmp/salt
```

# 添加用户

```
user account for yunwei:
  user.present:
    - name: yunwei
    - shell: /bin/bash
    - home: /home/yunwei
    - groups:
      - sudo
```

# 添加到主机

```
gitlab in hosts file:
  host.present:
    - name: gitlab.aniu.so
    - ip: 192.168.0.55
```

# 执行函数执行

```
restart redis:
  module.run:
    - name: service.restart
    - m_name: redis  # m_name gets passed to the execution module as "name"

```
> 执行功能（“远程执行功能”的缩写）是从salt命令行调用的命令，它们以salt.module *开头

# ftp同步备份
```
ftpusername: me
ftppassword: oxfm4@8t5gglu^h^&

sync directory using lftp:
  cmd.run:
    - name: lftp -c "open -u {{ pillar['ftpusername'] }},{{ pillar['ftppassword'] }}
           -p 22 sftp://example.com;mirror -c -R /local /remote"
```

# 直接测试
```
salt '*' state.apply ftpsync pillar='{"ftpusername": "test", "ftppassword": "0ydyfww3giq8"}'
```

# 目录同步

```
include:
  - lftp

sync directory using lftp:
  cmd.run:
    - name: lftp -c "open -u {{ pillar['ftpusername'] }},{{ pillar['ftppassword'] }}
           -p 22 sftp://example.com;mirror -c -R /local /remote"
```

# 依赖关系

> 必需条件允许您明确指定状态中的ID的依赖关系。如果添加一个表示id1需要id4的语句，则首先应用id4。

salt 'zabbix.aniu.so' state.show_sls init.git env=base

# JINJA

> Jinja最常见的用途之一是将条件语句插入Salt柱文件。 因为许多发行版具有不同的包名称，您可以使用os grain来设置平台特定的路径，包名称和其他值。

```
{% if grains['os_family'] == 'RedHat' %}
apache: httpd
git: git
{% elif grains['os_family'] == 'Debian' %}
apache: apache2
git: git-core
{% endif %}
```

> 将上面的代码片段保存到saltstack / columns / common.sls文件中，然后运行以下命令进行刷新，然后列出每个子节点的Salt柱值
salt '*' saltutil.refresh_pillar
salt '*' pillar.items

# 循环在Salt状态下创建用户和文件夹很有用

```
{% for usr in ['yunwei','dev','dba'] %}
{{ usr }}:
  user.present
{% endfor %}
#
{% for DIR in ['/tmp/dir1','/tmp/dir2','/tmp/dir3'] %}
{{ DIR }}:
  file.directory:
    - user: root
    - group: root
    - mode: 774
{% endfor %}
```
# 文件管理

```
backup saltstack master file:
  file.managed:
    - name: /tmp/master
    - source: salt://files/master

update master file:
  file.append:
    - name: /tmp/master
    - text: "# test fileappend function."

copy some files to the web server:
  file.recurse:
    - name: /var/www/html
    - source: salt://files/www
```

![saltstack](https://docs.saltstack.com/en/latest/images/get-started-diagram.png)
