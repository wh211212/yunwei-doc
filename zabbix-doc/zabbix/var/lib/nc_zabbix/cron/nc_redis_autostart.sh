#!/bin/bash
##############################
# REDIS auto start
##############################
# ChangeLog:
# 2014-08-13 Initial Creation
##############################

#Binaries
DATE="/bin/date"
BASH="/bin/bash"

# Variables
REDISPORT=6379
PIDFILE=/var/run/redis_${REDISPORT}.pid
DATE_FORMATED=`$DATE "+%y%m%d_%H%M%S"`
DATE_FORMATED_LOG=`$DATE "+%y%m%d"`

if [ -f $PIDFILE ]
then
    echo "$DATE_FORMATED - $PIDFILE exists, process is already running or crashed" >> /var/log/redis/autorestart_$DATE_FORMATED_LOG.log
else
    $BASH /etc/init.d/redis_$REDISPORT start
    echo "$DATE_FORMATED - $PIDFILE can't be found, restarting redis!" >> /var/log/redis/autorestart_$DATE_FORMATED_LOG.log
fi
;;