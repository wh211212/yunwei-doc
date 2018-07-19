#!/bin/bash
##########################################################################
# Script Name: auto_backup_gitlabdata.sh
# Author: wanghui
# Email: yunwei@aniu.tv
# Created Time: Thu 07 Sep 2017 08:59:26 PM CST
#########################################################################
# Blog address: http://blog.csdn.net/wh211212
#########################################################################
# Functions: auto backup gitlab data#
# backup gitlab config
# tar cfz /secret/gitlab/backups/$(date "+etc-gitlab-\%s.tgz") -C / etc/gitlab
# backup gitlab os
# /opt/gitlab/bin/gitlab-rake gitlab:backup:create
# gitlab本地备份路径
LocalBackDir=/var/opt/gitlab/backups

# 备份时间戳
#Date=`date +"%F-%T"`
Date=`date +%F`

# 邮件写入的文件
MailDir=$LocalBackDir/mail
[ -d $MailDir ] || mkdir -p $MailDir 
MailContent=$LocalBackDir/mail/mailcontent_$Date

# 邮件发送给谁
MailToUser1=hwang@aniu.tv
MailToUser2=yjiang@aniu.tv
MailToUser2=crshen@aniu.tv

# 备份日志目录
LogDir=$LocalBackDir/log
[ -d $LogDir ] || mkdir -p $LogDir

# 新建日志文件
LogFile=$LocalBackDir/log/backup_$Date.log
touch $LogFile

# 追加日志到日志文件
echo "Gitlab auto backup at local server, start at  $(date +"%Y-%m-%d %H:%M:%S")" >  $LogFile
echo "--------------------------------------------------------------------------" >> $LogFile

# 执行gitlab本地备份功能
/opt/gitlab/bin/gitlab-rake gitlab:backup:create

# $?符号显示上一条命令的返回值，如果为0则代表执行成功，其他表示失败
if [ $? -eq 0 ];then
   #追加日志到日志文件
   echo "--------------------------------Success!-------------------------------" >> $LogFile
   echo "Gitlab auto backup at local server, end at $(date +"%Y-%m-%d %H:%M:%S")" >> $LogFile

   #写Email的正文内容
   > "$MailContent"
   echo "GitLab Backup Daily Report,backup at local server Success ! Please Check your Email and read the following log file" >> $MailContent

   #读取mailcontent内容当做邮件正文 ，附件为Log文件
   #cat $MailContent | mail -s "Congratulation! GitLab backup at local server Success Report." $MailToUser1 < $LogFile
   cat $MailContent | mail -s "Congratulation! GitLab backup at local server Success Report." -a $LogFile $MailToUser1 -c $MailToUser2 $MailToUser3
else
   #追加日志到日志文件
   echo "--------------------------------Failed!----------------------------------" >> $LogFile
   echo "Gitlab auto backup at local server failed at $(date +"%Y-%m-%d %H:%M:%S")" >> $LogFile

   #写Email的正文内容
   > "$MailContent"
   echo "GitLab Backup Daily Report,Backup at local server failed Failed !  Please Check your Email and read the following log file !" >> $MailContent

   #读取mailcontent内容当做邮件正文附件为Log文件
   cat $MailContent | mail -s "Warning! GitLab Backup at local server Failed Report." $MailToUser1 -A $LogFile
fi
