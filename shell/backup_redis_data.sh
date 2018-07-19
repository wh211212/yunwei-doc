#!/bin/bash
#---------------------------------------------------------------------
# Function: backup redis rdb
#---------------------------------------------------------------------
# ChangeLog:
# 2018-01-22    wanghui    initial create
#---------------------------------------------------------------------
# set -x

# define varibales
DATE=`date +%F_%T`
LOG=/var/log/backup_redis.log

#PORT_LIST=(9000 16379)
PORT_LIST=(16379)

function backup() {

    for REDIS_PORT in ${PORT_LIST[@]}
    do
    BACKDIR=/data/backup/redis/$REDIS_PORT
    #REDIS_PORT=6379
    REDIS_PASSWORD=Aniuredis123
    REDIS_DATADIR=`/usr/bin/redis-cli -p $REDIS_PORT -a "$REDIS_PASSWORD" config get dir | egrep -v 'dir'`
    REDIS_RDB=`/usr/bin/redis-cli -p $REDIS_PORT -a "$REDIS_PASSWORD" config get dbfilename | egrep -v 'dbfilename'`
    # redis not config aof
    # REDIS_AOF=`/usr/bin/redis-cli -p $REDIS_PORT -a "$REDIS_PASSWORD" config get appendfilename | egrep -v 'appendfilename'`

    [ -d $BACKDIR ] || mkdir -p $BACKDIR


    # execute backup
    /usr/bin/redis-cli -p $REDIS_PORT -a "$REDIS_PASSWORD" bgsave

    sleep 10

    \cp $REDIS_DATADIR/$REDIS_RDB  $BACKDIR/${DATE}-$REDIS_RDB


    if [ $? -eq 0 ];then
         echo "$DATE Backup Redis Data Done!" >> $LOG
       else 
         echo "$DATE Backup Redis Data Error!" >> $LOG
    fi

    # delete redis data 7 days ago

    find $BACKDIR -mtime +7 -name "*.rdb" -exec rm -rf {} \;
    done
}

backup
