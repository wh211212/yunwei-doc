#!/bin/bash
###################################################
# Function: monitor redis status from zabbix
# Connect: hwang@aniu.tv
# Changelog:
# 2017-03-29  shaonbean    initial
###################################################

REDIS_IP=127.0.0.1
REDIS_PORT=6379
REDIS_CLI="/usr/bin/redis-cli"
ZABBIX_REQ="$1"
ZABBIX_REQ_PORT="$2"
# Temp file to store data
REDIS_TMP="/var/lib/nc_zabbix/tmp/redis.status_$ZABBIX_REQ_PORT"

# ERROR CODE
ERROR_DATA="-0.9901"
ERROR_PERMISSION="-0.9902"
INVALID_ITEM="-0.9903"
INVALID_REDIS_CLI="-0.9904"

CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF=$CURRENT_DIR/../conf/nc_redis_check.conf
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

if [ ! -x "$REDIS_CLI" ]; then
    echo "$INVALID_REDIS_CLI"
    exit 1
fi

if [ -z "$ZABBIX_REQ" ]; then
    echo "$ERROR_DATA"
    exit 1
fi

# Assign default port if doesn't exist
if [ ! -z $ZABBIX_REQ_PORT ]; then
  REDIS_PORT="$ZABBIX_REQ_PORT"
fi

# create redis status file.
status_generate() {
#    REDIS_STATS=$($REDIS_CLI -h $REDIS_IP -p $REDIS_PORT INFO)
     REDIS_STATS=$($REDIS_CLI -h $REDIS_IP -p $REDIS_PORT 2> /dev/null<< EOF
auth $REDIS_PASSWD
INFO
CONFIG GET maxmemory
EOF
)
    if [ $? -ne 0 -o -z "$REDIS_STATS" ]; then
        echo $ERROR_DATA
        exit 1
    fi

    echo "$REDIS_STATS" > $REDIS_TMP
    if [ $? -ne 0 ]; then
        echo "$ERROR_PERMISSION"
        exit 1
    fi
}

read_value() {
    ITEM="$1"
    if grep -q "^$ITEM:" $REDIS_TMP; then
        awk -F: '/'$ITEM:'/ {print $2}' $REDIS_TMP
    else
        case "$1" in
            version) awk -F':' '/redis_version/ {print $2}' $REDIS_TMP ;;
            connected_slave) awk -F':' '/connected_slaves/ {print $2}' $REDIS_TMP ;;
            db*_keys) awk -F':|,|=' '/'${ZABBIX_REQ/_/:}'/ {print $3}' $REDIS_TMP ;;
            db*_expires) awk -F':|,|=' '/'${ZABBIX_REQ/_/.*}'/ {print $NF}' $REDIS_TMP ;;
            connections_per_sec) awk -F: '/total_connections_received/ {print $2}' $REDIS_TMP;;
	    last_save_time) awk -F: '/rdb_last_save_time/ {print $2}' $REDIS_TMP;;
            maxmemory)      grep -A1 '^maxmemory' $REDIS_TMP | tail -n1;;
            *               ) echo "$INVALID_ITEM"; exit 1;;
        esac
    fi
}

# get data from status file, unless the status file is old
if [ ! -f "$REDIS_TMP" ]; then
    status_generate
	read_value "$ZABBIX_REQ"
else
    NOW=$(date +%s)
    LAST_CTIME=$(stat -c %Y $REDIS_TMP)

    if [ $((NOW - LAST_CTIME)) -lt 30 ]; then
	read_value "$ZABBIX_REQ"
    else
        status_generate
	read_value "$ZABBIX_REQ"
    fi
fi
exit 0
