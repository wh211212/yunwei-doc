# CentOS6 安装完整初始化操作


- 安装salts-minion

- 通过salt初始化客户机

# 安装zabbix

salt cache state.sls zabbix.zabbix-agent saltenv=prod


salt cache cp.get_file salt://scripts/cmd_track_install.sh /tmp/cmd_track_install.sh
salt cache cmd.run 'bash /tmp/cmd_track_install.sh'