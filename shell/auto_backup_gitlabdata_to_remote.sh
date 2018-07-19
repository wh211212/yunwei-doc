#!/bin/bash
##########################################################################
# Script Name: auto_backup_gitlabdata_to_remote.sh
# Author: wanghui
# Email: yunwei@aniu.tv
# Created Time: Thu 07 Sep 2017 08:59:26 PM CST
#########################################################################
# Blog address: http://blog.csdn.net/wh211212
#########################################################################
# Functions:  #
# 
# Define some variables:  #
# Gitlab 档案备份路径
LocalBackDir=/var/opt/gitlab/backups

# Backup server 存储路径
RemoteBackDir=/mnt/backups/gitlab_backups/remote

# 远程备份使用用户及端口
RemoteUser=root
RemotePort=22

# 备份服务器IP
RemoteIP=192.168.0.222

# 备份时间戳
Date=`date +"%F-%T"`

# 备份日志文件
LogFile=$LocalBackDir/remote_backup.log

# 查找本地备份目录下一天以内且后缀为.tar的Gitlab备份文件
Backfile_Send_To_Remote=$(find /var/opt/gitlab/backups -type f -mtime -1 -name '*.tar')

#Backfile_Send_To_Remote=`find $LocalBackDir -type f -mtime -1 -name '*.tar'`

# 新建备份日志文件
touch $LogFile

# 记录备份日志
echo "${Date} Gitlab auto backup to remote server." >> $LogFile
echo "--------------------------------------------" >> $LogFile

# 打印每次备份的档案名
echo "The files need send to remote server is: $Backfile_Send_To_Remote" >> $LogFile

# 本地传输Gitlab备份档案到远程
scp -P $RemotePort $Backfile_Send_To_Remote $RemoteUser@$RemoteIP:$RemoteBackDir

# 备份结果追加到备份日志
if [ $? -eq 0 ];then
  echo ""
  echo "$Date Gitlab Remote Backup Succeed!" >> $LogFile
else
  echo "$Date Gitlab Remote Backup Failed!" >> $LogFile
fi
