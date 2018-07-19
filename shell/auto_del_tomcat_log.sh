#!/bin/bash
################################################
# Functions: auto delete tomcats log
#          -- aniu-nkm-task
# ChangeLog:
# 2018-02-01  hwang@aniu.tv  initial create
################################################
# set -x
# define varibales
DATE=`date +%F_%T`
TOMCAT_DIR=/data/tomcats
PORTLIST=(8081 8082 8083)
#PORTLIST=(8084)
LOG=$TOMCAT_DIR/delete_log_records

function delete() {
    #
    for port in ${PORTLIST[@]}
    do 
    TOMCAT_NAME=tomcat-$port
    PROJECT_DIR=$TOMCAT_DIR/$TOMCAT_NAME
    if [ -d $PROJECT_DIR ];then
       echo "Delete logs 30 days ago!"
       LOGS_DIR=$TOMCAT_DIR/$TOMCAT_NAME/logs 
       find $LOGS_DIR/ -mtime +30 -exec rm -rf {} \;
       [ $? -eq 0 ] && echo "*** $DATE Auto Delete $TOMCAT_NAME Logs Succeed!***" >> $LOG
    else
       echo "*** $DATE $PROJECT_DIR not exist!***"
       echo "*** $DATE $PROJECT_DIR not exist!***" >> $LOG
       exit 1
    fi
    done
}

function main(){
    # call del functions
    delete
}

main
