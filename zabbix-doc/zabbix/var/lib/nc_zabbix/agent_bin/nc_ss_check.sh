#!/bin/bash
##################################
# Zabbix monitoring script
#
# ss:
#   -TCP
#   -UDP
# Info:
    
##################################
##################################
# ChangeLog:
#  20160904    MZ    create this script
##################################
VERSION=1.0
# Zabbix requested parameter
ZBX_REQ_PRITOCOL="$1"
ZBX_REQ_STATE="$2"
# Source requested file
ZABBIX_BASE_DIR=`readlink -f $( dirname $(dirname $0) )`
FILE_TCP=$ZABBIX_BASE_DIR/tmp/file-tcp
FILE_UDP=$ZABBIX_BASE_DIR/tmp/file-udp

#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - items need to be of type "float" (allow negative + float)
#
ERROR_NO_COMMAND="-0.9900" 
ERROR_NO_PEOTOCOL="-0.9901"
ERROR_NO_STATE="-0.9902"
ERROR_WRONG_PROTOCOL="-0.9903"
ERROR_MISSING_FILE="-0.9904" 
ERROR_FAILED_FILTER="-0.9905"

# check if the folder exists
if [ ! -d "$ZABBIX_BASE_DIR/tmp" ]; then
  mkdir -p "$ZABBIX_BASE_DIR/tmp"
fi

#check if the command exist
SS=$(which ss 2>/dev/null)

if [ $? -ne 0 ];then
  echo $ERROR_NO_COMMAND
  exit 1
fi

#Override defaults from config file
SCRIPT_CONF=$ZABBIX_BASE_DIR/conf/nc_ss_check.conf
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF


#check if protocol is specied
if [ -z "$ZBX_REQ_PRITOCOL" ];then
  echo $ERROR_NO_PEOTOCOL && exit 1
fi
#check if stat is specied
if [ -z "$ZBX_REQ_STATE" ];then
  echo $ERROR_NO_STATE && exit 1
fi

OLD_DATE=2
#tcp functio
tcp() {
    if [ ! -f "$FILE_TCP" ] || [ $(stat -c "%Y" $FILE_TCP ) -lt $(date -d "now -$OLD_DATE min" "+%s" ) ];then
     $SS -nat|awk '{++s[$1]} END {for(k in s) print k,s[k]}' > $FILE_TCP 2>/dev/null
                if [ $? -ne 0 ];then
                  echo "$ERROR_MISSING_FILE" && exit 1
                fi
    fi
    NUM_T=$(cat $FILE_TCP | grep "^$ZBX_REQ_STATE [0-999999]" |awk '{print $2}') 2>/dev/null
            if [ $? -ne 0 ];then
             echo "$ERROR_FAILED_FILTER" && exit 1
            fi
            if [ -z "$NUM_T" ];then
             NUM_T=0
            fi
     echo "$NUM_T" && exit 0
}
#udp functio
udp() {
        if [ ! -f "$FILE_UDP" ] || [ $(stat -c "%Y" $FILE_UDP ) -le $(date -d "now -$OLD_DATE min" "+%s" ) ];then
         $SS -nau|awk '{++s[$1]} END {for(k in s) print k,s[k]}' > $FILE_UDP 2>/dev/null
                if [ $? -ne 0 ];then
                  echo "$ERROR_MISSING_FILE" && exit 1
                fi
        fi
        NUM_U=$(cat $FILE_UDP | grep "^$ZBX_REQ_STATE [0-999999]" |awk '{print $2}') 2>/dev/null
                if [ $? -ne 0 ];then
                 echo "$ERROR_FAILED_FILTER" && exit 1
                fi
                if [ -z "$NUM_U" ];then
                 NUM_T=0
                fi
        echo "$NUM_U" && exit 0
}
#MAIN FUNCTION
case "$1" in
 TCP|tcp)
 tcp 
 ;;
 UDP|udp)
 udp
 ;;
 *)
 echo "$ERROR_WRONG_PROTOCOL" && exit 1
 ;;
esac
