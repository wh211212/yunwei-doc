#!/bin/bash
#---------------------------------------------------------------------
# Function: backup redis rdb
#---------------------------------------------------------------------
# ChangeLog:
# 2018-01-22    wanghui    initial create
#---------------------------------------------------------------------
# define varibales
DATE=`date +%F_%T`
BACKDIR=/backup/redis
REDIS_PORT=6379
REDIS_PASSWORD=Aniuredis123
REDIS_DATADIR=`/usr/bin/redis-cli -p $REDIS_PORT -a "$REDIS_PASSWORD" config get dir | egrep -v 'dir'`
REDIS_RDB=`/usr/bin/redis-cli -p $REDIS_PORT -a "$REDIS_PASSWORD" config get dbfilename | egrep -v 'dbfilename'`
#REDIS_AOF=`/usr/bin/redis-cli -p $REDIS_PORT -a "$REDIS_PASSWORD" config get appendfilename | egrep -v 'appendfilename'`

LOG=/var/log/backup_redis.log
# debug
# set -x

if [ ! -d $BACKDIR ];then
       mkdir -p $BACKDIR
   else
       echo "$BACKDIR is exist!"
fi

# execute backup
/usr/bin/redis-cli -p $REDIS_PORT -a "$REDIS_PASSWORD" bgsave

sleep 10

\cp $REDIS_DATADIR/$REDIS_RDB  $BACKDIR/${DATE}-$REDIS_RDB


if [ $? -eq 0 ];then
     echo "$DATE Backup Redis Data Done!" >> $LOG
   else 
     echo "$DATE Backup Redis Data Error!" >> $LOG
fi

# delete redis data 30 days ago

find $BACKDIR -mtime +30 -name "*.rdb" -exec rm -rf {} \;
