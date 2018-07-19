#!/bin/bash
######################################
# Usage: tomcat project status monitor
#
# Changelog:
# 2018-05-10 wanghui initial
######################################
#
TOMCAT_NAME=$1
status=$2

TOMCAT_PID=`ps -ef | grep "$TOMCAT_NAME" | grep "[o]rg.apache.catalina.startup.Bootstrap start" | grep -v grep | awk '{print $2}'`

jstack=$(which jstack)

case $status in
     thread.num)
     $jstack $TOMCAT_PID | grep http | grep -v grep | wc -l
     ;;

     *)
     echo "Usage: $0 {TOMCAT_NAME status[thread.num]}"
     exit 1
     ;;
esac
