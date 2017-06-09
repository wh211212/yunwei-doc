#!/bin/bash

###############################
# Zabbix log monitoring
###############################
# Contact :
#  vincent.viallet@gmail.com
###############################
# Limitations :
#      Currently resume reading from previously read offset
#      If inode is different -> new file, re-read from 0
#      Do not handle rotated logs (yet)
###############################
# Usage :
#   arg1 : log file name
#   arg2 : matching pattern
#   arg3 : matching type (raw / web / more in the future)
#   arg4 : data type (count / sum) - count is easier for trigger
#          sum is better for delta in Zabbix
#
# Special matching type :
#   web : matching arg can be set to  2xx 3xx 4xx 5xx
#          this pattern will then be changed to be 2[0-9]{2} / etc.
#   raw : base regexp match on the log file
###############################
# Security :
#   Due to some limitation in the ownership of some log files
#   it is necessary to provide zabbix user with some extra privileges
#
#   To sudo configuration add the following binaries to the list of allowed
#   binary to be run as admin by zabbix user :
#
# Cmnd_Alias ZABBIX = ..........., /usr/bin/stat, /usr/bin/tail, /usr/bin/test
###############################
# Define configuration / stat file
# Format :
#     file_name:return_code:inode:offset:count
##################################
# ChangeLog:
#  20150403    TZ    Add cron script
##################################
CURRENT_DIR=$(readlink -f $(dirname $0))
STAT_FILE="$CURRENT_DIR/../tmp/log.stat"
CRON_FILE="$CURRENT_DIR/../cron/nc_log-match_cron.sh"

DATE="/bin/date"
STAT="/usr/bin/stat"

# Arguments
#  Log_file_name -- full path 
#  log match -- the matching pattern we want to retrieve a count for
LOG_FILE_NAME="$1"
LOG_MATCH="$2"
LOG_MATCH_TYPE="$3"
LOG_RESULT_TYPE="$4"

# Error codes
ERROR_NO_STAT_FILE="-0.9901"
ERROR_NOT_UPDATE_FILE="-0.9902"
ERROR_NOT_CRON_FILE="-0.9903"

# Override defaults from config file
SCRIPT_CONF=$CURRENT_DIR/../conf/nc_log-match_check.conf
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

# Check if stat file exist
if [ ! -e $STAT_FILE ];then
  echo $ERROR_NO_STAT_FILE
  exit 1
fi

# Check log status file
LASTCHANGE_TIME=$($STAT -c "%Y" $STAT_FILE)
CURRENT_TIME=$($DATE +%s)
MINUS_TIME=$[ $CURRENT_TIME - $LASTCHANGE_TIME ]
if [ $MINUS_TIME -gt 1800 ];then
  logger "The $STAT_FILE file has not been updated with half hour"
  echo $ERROR_NOT_UPDATE_FILE
  exit 1
fi

match_web_return_code() {
    # Handle 2xx / 3xx / 4xx / 5xx -- other remain unchanged
    COUNT=$(grep -E "^$LOG_FILE_NAME:$LOG_MATCH:" $STAT_FILE | cut -f 5 -d':' )
    echo $COUNT
}

# Match raw patterns
match_raw() {

   # Check if the cron file exist
    if [ ! -e $CRON_FILE ];then
      echo $ERROR_NOT_CRON_FILE
      exit 1
    fi

    bash $CRON_FILE $LOG_FILE_NAME $LOG_MATCH raw
    COUNT=$(grep -E "^$LOG_FILE_NAME:$LOG_MATCH:" $STAT_FILE | cut -f 5 -d':' ) 
    echo $COUNT
}

main() {
    case $LOG_MATCH_TYPE in
      web) match_web_return_code;;
      raw) match_raw;;
      *) match_raw;;
    esac
}

main
