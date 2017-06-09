#!/bin/bash
#######################################################
# Zabbix monitoring script
# 
# nginx backend check via nginx_upstream_check_module
# 
#######################################################
# Contact:
#  vince.zhang@chinanetcloud.com
#######################################################
# Changelog:
# Apr 7, 2014  VZ      Initial create
#######################################################

# Zabbix required parameter
ZBX_REQ=$1
URL=$4

# Set default healthcheck url
#DEFAULT_URL="http://127.0.0.1:81/status"
DEFAULT_URL="http://127.0.0.1/status"
CURL_BIN=$(which curl)

# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF=$CURRENT_DIR/../conf/nc_nginx_healthcheck.conf
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - items need to be of type "float" (allow negative + float)
#
ERROR_NO_ACCESS_FILE="-0.9900"
ERROR_NO_ACCESS="-0.9901"
ERROR_WRONG_PARAM="-0.9902"
ERROR_DATA="-0.9903" # either can not connect /    bad host / bad port

# Check if zabbix provides a url
if [ -z $URL ]; then
  URL=$DEFAULT_URL
fi

RAW_DATA=$($CURL_BIN $URL 2> /dev/null)
#NODE_NUM=$(echo $RAW_DATA | grep number | awk -F[:,] '{print $2}')
STATUS=$(echo "$RAW_DATA" | grep td | sed -n "s/<[^>]*>//g"p)

if [ $? -ne 0 -o -z $STATUS ]; then
  echo $ERROR_DATA
  exit 1
fi

get_status() {
  NODE_NAME=$1
  KEY_STATUS=$2

  if [ -z $NODE_NAME -o -z $KEY_STATUS ]; then
    echo ""
    exit 1
  fi

  case $KEY_STATUS in
    stat)  echo "$STATUS" | grep -A1 "$NODE_NAME" | tail -1 ;;
    rise)  echo "$STATUS" | grep -A2 "$NODE_NAME" | tail -1 ;;
    fall)  echo "$STATUS" | grep -A3 "$NODE_NAME" | tail -1 ;;
    type)  echo "$STATUS" | grep -A4 "$NODE_NAME" | tail -1 ;;
    *)     echo "" ;;
  esac
}

# Main

case $ZBX_REQ in
  status)	get_status $2 $3 ;;
  *     )	echo $ERROR_WRONG_PARAM; exit 1;;
esac

exit 0

