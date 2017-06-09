#!/bin/bash
##################################
# Zabbix monitoring script
#
# haproxy:
#  - Haproxy info
#  - Haproxy info
#  - Haproxy info
#
# Info:
#  - haproxy data are gathered real-time
##################################
# ChangeLog:
#  20100526     CH      Init create
#  20111221    DL    Organize
#  20120726    AS    Bug fixes - get wrong info about version and uptime_sec
#  20160906    TZ    Output stat to tmp file
##################################

# Zabbix requested parameter
ZBX_REQ_DATA="$1"

# HaProxy details
SOCAT_BIN="/usr/bin/socat"
CKSUM_BIN="/usr/bin/cksum"
SOCKET_FILE="/tmp/haproxy"
OLD_DATA=5

# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF=$CURRENT_DIR/../conf/nc_haproxy_check.conf
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

SOURCE_DATA=$CURRENT_DIR/../tmp/haproxy_stat.tmp

#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - numeric items need to be of type "float" (allow negative + float)
#
ERROR_NO_SOCKET_FILE="-0.9900"
ERROR_NO_BIN="-0.9901"
ERROR_WRONG_PARAM="-0.9902"
ERROR_GENERIC="-0.9903"

# No haproxy socket file to read info from
if [ ! -S "$SOCKET_FILE" ]; then
  echo $ERROR_NO_SOCKET_FILE
  exit 1
fi

# Check SOCAT BIN
if [ ! -x "$SOCAT_BIN" -o ! -x "$CKSUM_BIN" ]; then
  echo $ERROR_NO_BIN
  exit 1
fi

# Only ZBX_REQ_DATA is mandatory
# If ZBX_REQ_DATA is not specified, get from mysql global status
if [ -z "$ZBX_REQ_DATA" ]; then
  echo $ERROR_WRONG_PARAM
  exit 1
fi


if [ $? -ne 0 ]; then
  echo $ERROR_GENERIC
  exit 1
fi

## SUB-FUNCTION
# check info from haproxy socket file
check_info(){
    INFO_KEYWORD=$1
    echo 'show info' | sudo $SOCAT_BIN unix-connect:$SOCKET_FILE stdio | grep -i "$INFO_KEYWORD:" | awk -F ": " '{print $2}'
}

# check error from haproxy socket file, but just return checksum for zabbix to make trigger
check_errors(){
    SHOW_ERRORS="$(echo 'show errors' | sudo $SOCAT_BIN unix-connect:$SOCKET_FILE stdio)"
    echo -e "$SHOW_ERRORS" | $CKSUM_BIN | awk '{print $1}'
}

# function to get node hostname, both work for the id_num and hostname
get_server() {
    POOL_NAME=$1
    IS_NODE_NAME=$2
    
    # check if the given argument is id_name, or hostname, and define the NODE_NAME properly
    if grep -E "^$POOL_NAME,$IS_NODE_NAME," $SOURCE_DATA >&/dev/null; then
        NODE_NAME=$2
     else 
        NODE_ID=$2
        NODE_NAME=$(grep -vE 'BACKEND|FRONTEND' $SOURCE_DATA | grep $POOL_NAME | awk -F"," '{print $2}' | sed -n "$NODE_ID"p 2>/dev/null)
    fi

    # print the proper NODE_NAME
    if [ -z "$NODE_NAME" ]; then
        echo "$ERROR_WRONG_PARAM"    
        exit 1
    else
        echo $NODE_NAME
    fi
}

check_stat(){
    STAT_KEYWORD=$1
    PXNAME=$2
    IS_SVNAME=$3

    # check if the given arguments count is right
    if [ -z "$PXNAME" -o -z "$IS_SVNAME" -o -z "$STAT_KEYWORD" ]; then
        echo "$ERROR_WRONG_PARAM"
        exit 1
    fi

	if [ ! -f "$SOURCE_DATA" ] || [ $(stat -c "%Y" $SOURCE_DATA) -lt $(date -d "now -$OLD_DATA min" "+%s") ]; then
        echo 'show stat' | sudo $SOCAT_BIN unix-connect:$SOCKET_FILE stdio > $SOURCE_DATA
    fi
    

    # check if zabbix want to get the node name or running status
    if [ "$STAT_KEYWORD" == "name" ]; then
        get_server $PXNAME $IS_SVNAME
    else 
        # if the given argument is not fontend or backend, try to get the real SVNAME
        if echo "$IS_SVNAME" | grep -Ei "frontend|backend" >/dev/null;then
            SVNAME=$IS_SVNAME
        else
            SVNAME=$(get_server $PXNAME $IS_SVNAME)
            
            # exit if the get_server function fail
            if [ $? -ne 0 ]; then
                echo $SVNAME
                exit 1
            fi
         fi

        # get the key word location
        KEY_LOCATION=$(cat $SOURCE_DATA | head -1 | sed "s/$STAT_KEYWORD.*/$STAT_KEYWORD/g" | awk -F',' '{print NF}')
        
        # get the status of the key word
        KEY_STATUS=$(grep -i "$PXNAME,$SVNAME" $SOURCE_DATA | awk -v a="$KEY_LOCATION" -F ',' '{print $a}')
        if [ -z "$KEY_STATUS" ]; then
            echo "NULL"
        else
            echo $KEY_STATUS
        fi
    fi
}


## Main ##
case $ZBX_REQ_DATA in
    ""       ) echo "$ERROR_WRONG_PARAM";;
        info     ) check_info $2;;
        errors   ) check_errors;;
        stat     ) check_stat $2 $3 $4;;
        *        ) echo "$ERROR_WRONG_PARAM";;
esac

