#!/bin/bash
############################################
# Functions: rsync crm concract by one hour
# Changelog:
# 2017-04-27  hwang@aniu.tv initial
###########################################
# backup from 192.168.0.8
Date=`date +'%y-%m-%d-%H'`
#/usr/bin/rsync -avzP --password-file=/etc/rsync.password deploy@192.168.0.8::contracts /data/crm/contracts/$Date >/dev/null 2>&1
#/usr/bin/rsync -avzqP --password-file=/etc/rsync.password deploy@192.168.0.8::contracts /data/crm/contracts/$Date
#/usr/bin/rsync -az --delete --password-file=/etc/rsync.password deploy@192.168.0.8::contracts /data/crm/contracts/$Date
# add rsync
/usr/bin/rsync -arzuv --password-file=/etc/rsync.password deploy@192.168.0.8::contracts /data/crm/contracts/
if [ $? -eq 0 ];then
  echo "--- ${Date} backup crm concract succeed! ---" >> /var/log/rsync.log
else
  echo "--- ${Date} backup crm concract succeed!" --->> /var/log/rsync.log
fi

