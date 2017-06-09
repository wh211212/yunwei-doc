#!/bin/bash
#####################################################
# Zabbix monitoring script
#
# nginx:
#  - anything available via nginx stub-status module
#
#####################################################
# Contact:
#  vincent.viallet@gmail.com
#####################################################
# ChangeLog:
#  20100922    VV    initial creation
#  20110212     CH    Add version check part
#            Ignore case for the initials
#####################################################

# Zabbix requested parameter
ZBX_REQ_DATA="$1"
ZBX_REQ_DATA_URL="$2"

# Nginx defaults
NGINX_STATUS_DEFAULT_URL="http://localhost:81/nginx_status"
CURL_BIN=$(which curl)
NGINX_BIN=$(which nginx)

# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF="$CURRENT_DIR/../conf/nc_nginx_check.conf"
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - items need to be of type "float" (allow negative + float)
#
ERROR_NO_ACCESS_FILE="-0.9900"
ERROR_NO_ACCESS="-0.9901"
ERROR_WRONG_PARAM="-0.9902"
ERROR_DATA="-0.9903" # either can not connect /    bad host / bad port

# Handle host and port if non-default
if [ ! -z "$ZBX_REQ_DATA_URL" ]; then
  URL="$ZBX_REQ_DATA_URL"
else
  URL="$NGINX_STATUS_DEFAULT_URL"
fi

# save the nginx stats in a variable for future parsing
NGINX_STATS=$($CURL_BIN $URL 2> /dev/null)
NGINX_VERSION=$($NGINX_BIN -v 2>&1 | awk -F '/' '{print $2}')

# error during retrieve
if [ $? -ne 0 -o -z "$NGINX_STATS" ]; then
  echo $ERROR_DATA
  exit 1
fi

# 
# Extract data from nginx stats
#
case $ZBX_REQ_DATA in
  [aA]ctive_connections)    echo "$NGINX_STATS" | head -1             | cut -f3 -d' ';;
  [aA]ccepts)               echo "$NGINX_STATS" | grep -Ev '[a-zA-Z]' | cut -f2 -d' ';;
  [hH]andled)               echo "$NGINX_STATS" | grep -Ev '[a-zA-Z]' | cut -f3 -d' ';;
  [rR]equests)              echo "$NGINX_STATS" | grep -Ev '[a-zA-Z]' | cut -f4 -d' ';;
  [rR]eading)               echo "$NGINX_STATS" | tail -1             | cut -f2 -d' ';;
  [wW]riting)               echo "$NGINX_STATS" | tail -1             | cut -f4 -d' ';;
  [wW]aiting)               echo "$NGINX_STATS" | tail -1             | cut -f6 -d' ';;
  [vV]ersion)               echo "$NGINX_VERSION";;
  *) echo $ERROR_WRONG_PARAM; exit 1;;
esac

exit 0
