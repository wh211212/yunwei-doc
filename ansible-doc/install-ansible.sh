#!/bin/bash
# set env
# CentOS 6.8 + epel repo
# ansible-server 192.168.0.103
# apm-pinpoint 192.168.0.101
# pinpoint-agent 192.168.0.102

# set /etc/hosts
[root@ansible ~]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain ansible
192.168.0.101 apm-pinpoint
192.168.0.102 pinpoint-agent

# add epel
yum install ansible -y

# set ssh
ssh-keygen -t rsa
ssh-copy-id apm-pinpoint
ssh-copy-id pinpoint-agent

# config ansible
[root@ansible ansible]# egrep -v "^#|^$" hosts
192.168.0.103
[pinpoint]
192.168.0.101
192.168.0.102

# use ansible
[root@ansible ~]# ansible pinpoint -m ping   # 执行命令加参数 -o，便于阅读
192.168.0.101 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
192.168.0.102 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
#
[root@ansible playbook]# ansible pinpoint -m ping -o
192.168.0.102 | SUCCESS => {"changed": false, "ping": "pong"}
192.168.0.101 | SUCCESS => {"changed": false, "ping": "pong"}

[root@ansible ~]# ansible pinpoint -m command -a 'hostname'
192.168.0.102 | SUCCESS | rc=0 >>
pinpoint-agent

192.168.0.101 | SUCCESS | rc=0 >>
apm-pinpoint

[root@ansible ~]# ansible pinpoint -k -m  command -a 'hostname'   # -k use password
SSH password:
192.168.0.102 | SUCCESS | rc=0 >>
pinpoint-agent

192.168.0.101 | SUCCESS | rc=0 >>
apm-pinpoint

# use playbook
[root@ansible ~]# cat playbook_sample.yml
# target hostname or group name
- hosts: pinpoint

# define tasks
  tasks:
  - name: test task
    file: path=/root/test.conf state=touch owner=root group=root mode=0600

# run playbook
[root@ansible ~]# ansible-playbook playbook_sample.yml

PLAY [pinpoint] ****************************************************************

TASK [setup] *******************************************************************
ok: [192.168.0.102]
ok: [192.168.0.101]

TASK [test task] ***************************************************************
changed: [192.168.0.102]
changed: [192.168.0.101]

PLAY RECAP *********************************************************************
192.168.0.101              : ok=2    changed=1    unreachable=0    failed=0
192.168.0.102              : ok=2    changed=1    unreachable=0    failed=0
[root@ansible ~]# ansible pinpoint -m command -a 'ls -l /root'
192.168.0.102 | SUCCESS | rc=0 >>
total 0
-rw------- 1 root root 0 Mar  9 11:11 test.conf

192.168.0.101 | SUCCESS | rc=0 >>
total 0
-rw------- 1 root root 0 Mar  9 11:11 test.conf

# create a playbook for install httpd & running
[root@ansible ~]# cat playbook_httpd.yml
- hosts: pinpoint
# use priviledge (default : root)
  become: yes
# the way to use priviledge
  become_method: sudo    # 建议使用sudo，非必须
# define tasks
  tasks:
  - name: httpd is installed
    yum: name=httpd state=installed
  - name: httpd is running and enabled
    service: name=httpd state=started enabled=yes
[root@ansible ~]# ansible-playbook playbook_httpd.yml --ask-become-pass
SUDO password:

PLAY [pinpoint] ****************************************************************

TASK [setup] *******************************************************************
ok: [192.168.0.101]
ok: [192.168.0.102]

TASK [httpd is installed] ******************************************************
changed: [192.168.0.101]
changed: [192.168.0.102]

TASK [httpd is running and enabled] ********************************************
changed: [192.168.0.102]
changed: [192.168.0.101]

PLAY RECAP *********************************************************************
192.168.0.101              : ok=3    changed=2    unreachable=0    failed=0
192.168.0.102              : ok=3    changed=2    unreachable=0    failed=0

[root@ansible ~]# ansible pinpoint -m command -a '/sbin/service httpd status' -b --ask-become-pass
SUDO password:
192.168.0.102 | SUCCESS | rc=0 >>
httpd (pid  7382) is running...

192.168.0.101 | SUCCESS | rc=0 >>
httpd (pid  29301) is running...

# start & stop service
[root@ansible ~]# ansible pinpoint -m service -a "name=httpd state=stopped"    # service httpd stop
192.168.0.101 | SUCCESS => {
    "changed": true,
    "name": "httpd",
    "state": "stopped"
}
192.168.0.102 | SUCCESS => {
    "changed": true,
    "name": "httpd",
    "state": "stopped"
}
[root@ansible ~]# ansible pinpoint -m service -a "name=httpd state=started"    # service httpd start
192.168.0.102 | SUCCESS => {
    "changed": true,
    "name": "httpd",
    "state": "started"
}
192.168.0.101 | SUCCESS => {
    "changed": true,
    "name": "httpd",
    "state": "started"
}

# install packages & rpm
[root@ansible ~]# ansible pinpoint -m yum -a "name=lrzsz state=present"  # yum install lrzsz -y
[root@ansible ~]# ansible pinpoint -m yum -a "name=lrzsz state=absent"   # yum erase lrzsz -y

# use variables in ansible-playbook
[root@ansible ~]# cat playbook_variables.yml
- hosts: pinpoint
  become: yes
  become_method: sudo
  tasks:
  - name: general packahes are installed
    yum: name={{ item }} state=installed
    with_items:
      - vim-enhanced
      - wget
      - unzip
    tags: general_packages
#
[root@ansible ~]# ansible-playbook playbook_variables.yml --ask-become-pass
SUDO password:

PLAY [pinpoint] ****************************************************************

TASK [setup] *******************************************************************
ok: [192.168.0.102]
ok: [192.168.0.101]

TASK [general packahes are installed] ******************************************
changed: [192.168.0.101] => (item=[u'vim-enhanced', u'wget', u'unzip'])
changed: [192.168.0.102] => (item=[u'vim-enhanced', u'wget', u'unzip'])

PLAY RECAP *********************************************************************
192.168.0.101              : ok=2    changed=1    unreachable=0    failed=0
192.168.0.102              : ok=2    changed=1    unreachable=0    failed=0

# confirm ansible-playbook execute result
[root@ansible ~]# ansible pinpoint -m shell -a "rpm -qa | egrep 'vim-enhanced|wget|unzip'" --ask-become-pass   # --ask-become-pass 可不加
SUDO password:
192.168.0.101 | SUCCESS | rc=0 >>
vim-enhanced-7.4.629-5.el6_8.1.x86_64
wget-1.12-8.el6.x86_64
unzip-6.0-4.el6.x86_64

192.168.0.102 | SUCCESS | rc=0 >>
wget-1.12-8.el6.x86_64
vim-enhanced-7.4.629-5.el6_8.1.x86_64
unzip-6.0-4.el6.x86_64

# 使用“setup”模块显示“GATHERING FACTS”的内容
[root@ansible ~]# ansible ansible.aniu.co -m setup | less

# 使用来自“GATHERING FACTS”的变量的示例
[root@ansible ~]# cat playbook_gathering.yml
# refer to "ansible_distribution", "ansible_distribution_version"
- hosts: pinpoint
  tasks:
  - name: Refer to Gathering Facts
    command: echo "{{ ansible_distribution }} {{ ansible_distribution_version }}"
    register: dist
  - debug: msg="{{ dist.stdout }}"

[root@ansible ~]# ansible-playbook playbook_gathering.yml

PLAY [pinpoint] ****************************************************************

TASK [setup] *******************************************************************
ok: [192.168.0.102]
ok: [192.168.0.101]

TASK [Refer to Gathering Facts] ************************************************
changed: [192.168.0.102]
changed: [192.168.0.101]

TASK [debug] *******************************************************************
ok: [192.168.0.101] => {
    "msg": "CentOS 6.8"
}
ok: [192.168.0.102] => {
    "msg": "CentOS 6.8"
}

PLAY RECAP *********************************************************************
192.168.0.101              : ok=3    changed=1    unreachable=0    failed=0
192.168.0.102              : ok=3    changed=1    unreachable=0    failed=0

# 使用playbook在目标主机创建不存在的文件
[root@ansible ~]# cat playbook_sample.yml
# set boolean with failed_when
# create "index.html" if result of boolean is "1"
- hosts: pinpoint
  become: yes
  become_method: sudo
  tasks:
  - name: index file exists or not
    shell: test -f /var/www/html/index.html
    ignore_errors: true
    register: file_exists
    failed_when: file_exists.rc not in [0, 1]

  - name: put index.html
    shell: echo "httpd index" > /var/www/html/index.html
    when: file_exists.rc == 1
#
[root@ansible ~]# ansible-playbook playbook_sample.yml

PLAY [pinpoint] ****************************************************************

TASK [setup] *******************************************************************
ok: [192.168.0.101]
ok: [192.168.0.102]

TASK [index file exists or not] ************************************************
changed: [192.168.0.102]
changed: [192.168.0.101]

TASK [put index.html] **********************************************************
changed: [192.168.0.101]
changed: [192.168.0.102]

PLAY RECAP *********************************************************************
192.168.0.101              : ok=3    changed=2    unreachable=0    failed=0
192.168.0.102              : ok=3    changed=2    unreachable=0    failed=0
#
[root@ansible ~]# ansible pinpoint -m shell -a 'cat /var/www/html/index.html'
192.168.0.102 | SUCCESS | rc=0 >>
httpd index

192.168.0.101 | SUCCESS | rc=0 >>
httpd index

# 使用playbook修改配置文件然后通知重启相关服务
[root@ansible ~]# cat ansible-playbook playbook_sshd.yml
cat: ansible-playbook: No such file or directory
- hosts: pinpoint
  become: yes
  become_method: sudo
  handlers:
  - name: restart sshd
    service: name=sshd state=restarted
  tasks:
  - name: edit sshd_config
    lineinfile: >
      dest=/etc/ssh/sshd_config
      regexp="{{ item.regexp }}"
      line="{{ item.line }}"
    with_items:
    - { regexp: '^#PermitRootLogin', line: 'PermitRootLogin no' }
    notify: restart sshd
    tags: Edit_sshd_config
#
[root@ansible ~]# ansible-playbook playbook_sshd.yml

PLAY [pinpoint] ****************************************************************

TASK [setup] *******************************************************************
ok: [192.168.0.102]
ok: [192.168.0.101]

TASK [edit sshd_config] ********************************************************
changed: [192.168.0.102] => (item={u'regexp': u'^#PermitRootLogin', u'line': u'PermitRootLogin no'})
changed: [192.168.0.101] => (item={u'regexp': u'^#PermitRootLogin', u'line': u'PermitRootLogin no'})

RUNNING HANDLER [restart sshd] *************************************************
changed: [192.168.0.101]
changed: [192.168.0.102]

PLAY RECAP *********************************************************************
192.168.0.101              : ok=3    changed=2    unreachable=0    failed=0
192.168.0.102              : ok=3    changed=2    unreachable=0    failed=0

# 使用普通用户执行playbook
[wh@ansible ~]$ ansible pinpoint -m command -a "grep '^#PermitRootLogin' /etc/ssh/sshd_config" -b
[WARNING]: log file at /var/log/ansible.log is not writeable and we cannot create it, aborting

192.168.0.102 | SUCCESS | rc=0 >>
#PermitRootLogin no

192.168.0.101 | SUCCESS | rc=0 >>
#PermitRootLogin no

# playbook中调用playbook实现，加上使用roles函数 # 重要

[root@ansible ansible]# ansible-playbook playbook_sample.yml

PLAY [pinpoint] ****************************************************************

TASK [setup] *******************************************************************
ok: [192.168.0.101]
ok: [192.168.0.102]

TASK [ins_python_lib : setuptools is installed] ********************************
ok: [192.168.0.102] => (item=[u'python-setuptools'])
ok: [192.168.0.101] => (item=[u'python-setuptools'])

TASK [ins_python_lib : pip is installed] ***************************************
ok: [192.168.0.102] => (item=pip)
ok: [192.168.0.101] => (item=pip)

TASK [ins_python_lib : httplib2 are installed] *********************************
ok: [192.168.0.101] => (item=httplib2)
changed: [192.168.0.102] => (item=httplib2)

PLAY RECAP *********************************************************************
192.168.0.101              : ok=4    changed=0    unreachable=0    failed=0
192.168.0.102              : ok=4    changed=1    unreachable=0    failed=0


#
ansible api -m yum -a "name=libselinux-python state=present"
