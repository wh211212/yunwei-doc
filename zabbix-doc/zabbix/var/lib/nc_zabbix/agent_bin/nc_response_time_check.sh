#!/bin/bash
#######################################################
# Zabbix monitoring script
#
# Description:
#  - Get response time for URL
#
#######################################################
# Contact:
#   support@chinanetcloud.com
#######################################################
# Change log:
# 2010-05-28    AS      Initial creation
# 2011-02-12    CH      Format to NC stardard
#  2012-02-13   CZ      add config file for override defaults
#######################################################

# Zabbix requested parameter
ZBX_REQ_DATA_URL="$1"
#echo $ZBX_REQ_DATA_URL| awk -F "/" '{print $1}' | awk -F ":" '{print $2}'
#    if [ -z $? ]
#        then 
#fi        
# Default binary
TIME_BIN="/usr/bin/time"
WGET_BIN=$(which wget)

# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF="$CURRENT_DIR/../conf/nc_response_time_check.conf"
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#
ERROR_NO_ACCESS_FILE="-0.9900"
ERROR_NO_ACCESS="-0.9901"
ERROR_WRONG_PARAM="-0.9902"
ERROR_DATA="-0.9903" # either can not connect / bad host / bad port


# Handle the resource data to the result
REQ_HOST=$(echo "$ZBX_REQ_DATA_URL" | awk -F: '{print $1}')
URL_WITHOUT_HOST=$(echo "$ZBX_REQ_DATA_URL" | awk -F: '{print $2}')
PORT=$(echo $ZBX_REQ_DATA_URL| awk -F "/" '{print $1}' | awk -F ":" '{print $2}')

if [ -z $PORT ]; then
  REQ_HOST_PORT=$(echo "$ZBX_REQ_DATA_URL" | sed 's/\//:80\//' | awk -F: '{print $1}')
  URL_WITH_PORT=$(echo "$ZBX_REQ_DATA_URL" | sed 's/\//:80\//' | awk -F: '{print $2}')
    RESPONSE_TIME=$($TIME_BIN -p $WGET_BIN -q --timeout 1 --tries 1 -O /dev/null --header="Host: $REQ_HOST_PORT" http://localhost:$URL_WITH_PORT 2>&1 | grep "real" | awk '{print $2}')
else
    RESPONSE_TIME=$($TIME_BIN -p $WGET_BIN -q --timeout 1 --tries 1 -O /dev/null --header="Host: $REQ_HOST" http://localhost:$URL_WITHOUT_HOST 2>&1 | grep "real" | awk '{print $2}')
fi

if [ $? -ne 0 ]; then
    echo $ERROR_DATA
    exit 1
else
    echo $RESPONSE_TIME
fi

