#!/bin/bash
##################################
# Zabbix monitoring script
#
# Info:
#  - cron job to gather haproxy log data
##################################
# Contact:
#  vincent.viallet@gmail.com
##################################
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
#         this pattern will then be changed to be 2[0-9]{2} / etc.
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
STAT_FILE=$CURRENT_DIR/../tmp/log.stat

# The default Log file as below.
# If you want to specify new files,please change it at conf/nc_log-match_check.conf
LOG_FILE_2XX="/var/log/haproxy/haproxy_access.log"
LOG_FILE_3XX="/var/log/haproxy/haproxy_access.log"
LOG_FILE_4XX="/var/log/haproxy/haproxy_err.log"
LOG_FILE_5XX="/var/log/haproxy/haproxy_err.log"

# Binary definition
STAT="/usr/bin/stat"
TAIL="/usr/bin/tail"
TEST="/usr/bin/test"

# Get the paratemeters for "raw" type
LOG_FILE_NAME="$1"
LOG_MATCH="$2"
LOG_MATCH_TYPE="$3"

# Override defaults from config file
SCRIPT_CONF=$CURRENT_DIR/../conf/nc_log-match_check.conf
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

# Create stat if not existing
if [ ! -e "$STAT_FILE" ]; then
    cat > "$STAT_FILE" << EOF
#############################################################
# Log file : match pattern : log inode : log offset : count #
#############################################################
EOF
    if [ $? -ne 0 ]; then
        logger "Sorry, failed to creat $STAT_FILE"
        exit 1
    fi
fi

check_log_file() {
# Test if log is readable by normal user - if not try with sudo
# exit if log file is not readable
if [ ! -r "$LOG_FILE_NAME" ]; then
    STAT="sudo $STAT"
    TAIL="sudo $TAIL"
  # test if even with sudo we can not read
    if [ $(sudo $TEST -r "$LOG_FILE_NAME") ]; then
      logger "Sorry, can't read the log file $LOG_FILE_NAME"
      exit 1
  fi
fi
}

get_current_stat() {
    LOG_INODE=$($STAT -c "%i" $LOG_FILE_NAME)
    LOG_SIZE=$($STAT -c "%s" $LOG_FILE_NAME)
    LOG_OFFSET=$LOG_SIZE
}

# Retrieve offset from stat file
# If absent - OFFSET=0 - will then be added in the stat for next check
get_offset() {
    INODE=$(grep -E "^$LOG_FILE_NAME:$LOG_MATCH:" $STAT_FILE | cut -f 3 -d':' )

    # file not defined in stat file
    #    OFFSET set to 0
    #    COUNT set to 0 (first check)
    if [ -z "$INODE" ]; then
        OFFSET=0
        COUNT=0
        return
    fi

    OFFSET=$(grep -E "^$LOG_FILE_NAME:$LOG_MATCH:" $STAT_FILE | cut -f 4 -d':' )
    COUNT=$(grep -E "^$LOG_FILE_NAME:$LOG_MATCH:" $STAT_FILE | cut -f 5 -d':' )

    # Saved inode is different from current file
    #    OFFSET back to 0
    if [ $((INODE)) -ne $((LOG_INODE)) ]; then
        OFFSET=0
    fi

    # Saved file size (offset) is larger than actual size
    # suggests erase of file content (ie. echo > LOG_FILE)
    #    OFFSET back to 0
    if [ $((OFFSET)) -gt $((LOG_SIZE)) ]; then
        OFFSET=0
    fi

    return
}

# Count web return code
# Rely on the base log format :
#    xxxxxxxxxx RETURN_CODE RESPONSE_SIZE xxxxxxxxxxx
match_web_return_code() {
    # Handle 2xx / 3xx / 4xx / 5xx -- other remain unchanged
    LOG_MATCH="$1"
    case $LOG_MATCH in
        2xx) PATTERN='2[0-9]{2}';;
        3xx) PATTERN='3[0-9]{2}';;
        4xx) PATTERN='4[0-9]{2}';;
        5xx) PATTERN='5[0-9][0,2-9]';;
        *) PATTERN="$LOG_MATCH"
    esac

   NEW_COUNT=$($TAIL -c +$OFFSET $LOG_FILE_NAME | grep -cE " $PATTERN [0-9]")
   COUNT=$((COUNT+NEW_COUNT))
}

match_raw() {
  case $LOG_MATCH in
    GET) PATTERN="GET[ \t]+[^ \t\n]+[.]";;
    static) PATTERN="GET[ \t]+[^ \t\n]+\S+[.](jpg|png|pdf|js|map|gif|css|ico|txt|swf|jpeg|woff|eot|svg|ttf|dae|html|htm)\s";;
    POST) PATTERN="POST[ \t]+[^ \t\n]+[.]";;
    *) PATTERN="$LOG_MATCH"
  esac
  NEW_COUNT=$($TAIL -c +$OFFSET $LOG_FILE_NAME | grep -cE "$PATTERN")
  COUNT=$((COUNT+NEW_COUNT))
}

update_stat() {
    if [ $(grep -cE "^$LOG_FILE_NAME:$LOG_MATCH:" $STAT_FILE) -ne 0 ]; then
        # Protect slash for sed
        STAT_FILE_MATCH=$(echo "$LOG_FILE_NAME:$LOG_MATCH" | sed -e 's/\//\\\//g')
        # Update INODE
        sed -i "/^$STAT_FILE_MATCH:/ s/:[^:]*/:$LOG_INODE/2" $STAT_FILE
        # Update OFFSET
        sed -i "/^$STAT_FILE_MATCH:/ s/:[^:]*/:$LOG_OFFSET/3" $STAT_FILE
        # Update COUNT
        sed -i "/^$STAT_FILE_MATCH:/ s/:[^:]*/:$COUNT/4" $STAT_FILE
    else
        echo "$LOG_FILE_NAME:$LOG_MATCH:$LOG_INODE:$LOG_OFFSET:$COUNT" >> $STAT_FILE
    fi
}

main() {
    # Check if type is "raw"
    if [ "$LOG_MATCH_TYPE" = "raw" ];then
        check_log_file
        get_current_stat
   	get_offset
	match_raw
   	update_stat
    else
   	for i in {2,3,4,5} 
   	do
       	# Binary definition
       	STAT="/usr/bin/stat"
       	TAIL="/usr/bin/tail"
       	TEST="/usr/bin/test"

       	# Get Haproxy files name
       	eval  LOG_FILE_NAME=$(echo \$$"LOG_FILE_""$i""XX")
       	LOG_MATCH="$i"xx

       	check_log_file
       	get_current_stat
       	get_offset
       	match_web_return_code "$i"xx
       	update_stat
   	done
     fi
}

main
