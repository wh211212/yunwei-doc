# 执行远程脚本所有依赖包

ansible api -m yum -a "name=libselinux-python state=present"  # yum 安装

# 同步远程脚本

ansible api -m copy -a "src=/usr/local/src/cmd_track_install.sh dest=/tmp"

# 执行远程脚本

ansible api -m shell -a "/bin/bash /tmp/cmd_track_install.sh"

# 本地创建脚本，远程执行
echo "[root@localhost tmp]# cat test.txt
test for execte local script!" > /root/test.sh
chmod +x /root/test.sh
ansible api -m script -a "/root/test.sh"

# 执行playbook
