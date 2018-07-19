#!/bin/bash
##########################################################################
# Script Name: auto_remove_old_backupdata.sh
# Author: wanghui
# Email: yunwei@aniu.tv
# Created Time: Thu 07 Sep 2017 08:59:26 PM CST
#########################################################################
# Blog address: http://blog.csdn.net/wh211212
#########################################################################
# Functions: auto remove old gitlab data#
GitlabBackDir=/var/opt/gitlab/backups
GitlabBackDir1=/mnt/backups/gitlab_backups

# 查找远程备份路径下，超过3天的Gitlab备份档案，然后删除
find $GitlabBackDir -type f -mtime +3 -name '*.tar' -exec rm {} \;

find $GitlabBackDir1 -type f -mtime +3 -name '*.tar' -exec rm {} \;

echo "Remove old backup succeed!"
