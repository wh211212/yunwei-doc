#!/bin/bash
#---------------------------------------------------------------------
# Function: delete tomcat logs
#---------------------------------------------------------------------
# ChangeLog:
# 2018-01-22    wanghui    initial create
#---------------------------------------------------------------------
#set -x

# define variables
DATE=`date +%F_%T`
LOG=/var/log/log-delete-record.txt

TOMCAT_HOME=/data/tomcats
#PORTLIST=(8080 8081 8082 8083)
PORTLIST=(8083)

# define function

function delete() {
    for port in ${PORTLIST[@]};
    do
    TOMCAT_NAEME=tomcat-$port
    LOGDIR=$TOMCAT_HOME/$TOMCAT_NAEME/logs
    if [ ! -d $LOGDIR ];then
        echo "${LOGDIR} not exist!"
      else
        echo "Delete 30 days ago logs!"
        find $LOGDIR/ -mtime +30 -exec rm -rf {} \;
    fi
    done
}

delete
