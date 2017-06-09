#!/bin/bash
#####################################################
# Zabbix monitoring script
#
# nc rsync script:
#  - Check status of NC rsync script
#
#####################################################
# Contact:
#  mick.duan@chinanetcloud.com
#####################################################
# MD    2012-03-01      create the scrpit #
# TW    2012-04-01      optimize the main function
### Error Code ###
# -0.9901 --- the log file is too old
# -0.9902 --- wrong parameters 
# -0.9903 --- wrong log file defination

# Zabbix requested parameter
ZBX_REQ_DATA=$1
RSYNC_LOG=$2

ERROR_OLD_DATA="-0.9901"
ERROR_PARAMERTER="-0.9902"
ERROR_LOG_FILE="-0.9903"
OLD_DATA=13


# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF="$CURRENT_DIR/../conf/nc_rsync_check.conf"
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

## log file check
[ ! -e $RSYNC_LOG ] && echo "$ERROR_LOG_FILE" && exit 1

# Old data handling:
#  - in case the cron can not update the data file
#  - in case the data are too old we want to notify the system
# Consider the data as non-valid if older than OLD_DATA minutes
#
run_check(){

if [ $(stat -c "%Y" $RSYNC_LOG) -lt $(date -d "now -$OLD_DATA min" "+%s" ) ]; then
    echo $ERROR_OLD_DATA
    exit 1
  else
    echo 0
fi
}

stat_check(){
STATUS=`tail -n 1 $RSYNC_LOG |awk '{print $2}'`
echo $STATUS
}

case $ZBX_REQ_DATA in
   run)    run_check;;
   stat)    stat_check;;
   *)       echo "$ERROR_PARAMERTER";;
esac
