#!/bin/bash
# nc_proc_limits.sh - show the limits of a given process
# AUTHOR : mason.liu <mason.liu@chinanetcloud.com>
# CHANGELOG :
# 20100917    ML    first version of the script

### Error Code ###
# -0.9901 --- the process you give is not exist
# -0.9902 --- the limit type you give is not exist

#the $1 should be the limit type you want get,such as open files ,etc
#the $2 should be the process name,you can use regex expression,such as ".*/xend.*"
LIMIT_TYPE="$1"
PROCESS_COMMANDLINE_REGEX="$2"
PROCESS_PID=$(ps -e -o pid,command |grep -E "$PROCESS_COMMANDLINE_REGEX" |grep -v 'grep' |grep -v $(basename $0) |head -1 |awk '{print $1}')

if [ -z "$PROCESS_PID" ];then
        echo 0.9901
        exit 1
fi

#print the soft limit of the process
LIMIT_VALUE=$(sudo grep "$LIMIT_TYPE" /proc/$PROCESS_PID/limits |awk 'N=NF-2 {print $N}')
if [ -z "$LIMIT_VALUE" ];then
        echo 0.9902
        exit 1
fi

echo "$LIMIT_VALUE"

