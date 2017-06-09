#!/bin/bash
##################################
# Zabbix monitoring script
#
# php-fpm :
#  - anything available via php-fpm status page
#
##################################
# Contact:
#  vincent.viallet@gmail.com
##################################
# ChangeLog:
#  20110124    VV    template creation
#  20110126    TW      set php-fpm status
#  20150512    TZ        Add monitoring with Apace
#  20150901    DX          Optimize environment check
#                            use 81 port for php-fpm status URL
#  20151010    DX              Check both apache+fpm and nginx_fpm status
##################################

# Zabbix requested parameter
ZBX_REQ_DATA="$1"
ZBX_REQ_DATA_URL="$2"

# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF="$CURRENT_DIR/../conf/nc_php-fpm_check.conf"
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
ERROR_STATS="-0.9904" # the value retrieved is invalid / can not be converted


# Handle host and port if non-default
url_check () {

if [ ! -z "$ZBX_REQ_DATA_URL" ]; then
  URL="$ZBX_REQ_DATA_URL"
else
  URL="$FPM_STATUS_DEFAULT_URL"
fi

}

#Check fpm status if running nginx+fpm
nginx_fpm_check () {

  FPM_STATUS_DEFAULT_URL="http://localhost:81/nc_fpm_status"
  CURL_BIN=$(which curl)
  url_check
  FPM_STATS=$($CURL_BIN $URL 2> /dev/null)

}

#Checking fpm status if running apache+fpm
apache_fpm_check () {
  
  FPM_STATUS_DEFAULT_URL="/tmp/php-fpm.sock"
  SCRIPT_NAME=/nc_fpm_status
  SCRIPT_FILENAME=/nc_fpm_status
  FCGI_BIN="/usr/bin/cgi-fcgi"

  if [ ! -e $FCGI_BIN ]; then
    echo $ERROR_WRONG_PARAM
    exit 1
  fi

  url_check

  FPM_STATS=$(SCRIPT_NAME=$SCRIPT_NAME SCRIPT_FILENAME=$SCRIPT_FILENAME REQUEST_METHOD=GET $FCGI_BIN -bind -connect $FPM_STATUS_DEFAULT_URL 2>/dev/null | sed 1,4d)

}

#Here we start to check fpm status,
#  first of all, we check the nginx_fpm status, 
#    if fails, then we check apache; if success, then pass.
#      if apache_fpm status check also failed, then exit with ERROR_DATA

nginx_fpm_check

if [ $? -ne 0 -o -z "$FPM_STATS" ]; then

  apache_fpm_check

  if [ $? -ne 0 -o -z "$FPM_STATS" ]; then
    echo $ERROR_DATA
    exit 1
  fi

fi

# 
# Extract data from php-fpm stats
#
case $ZBX_REQ_DATA in
  accepted_conn)     echo "$FPM_STATS" | grep 'accepted conn'    | head -1    | awk '{print $3}';;
  pool)              echo "$FPM_STATS" | grep 'pool'             | head -1    | awk '{print $2}';;
  process_manager)   echo "$FPM_STATS" | grep 'process manager'  | head -1    | awk '{print $3}';;
  idle_processes)    echo "$FPM_STATS" | grep 'idle processes'   | head -1    | awk '{print $3}';;
  active_processes)  echo "$FPM_STATS" | grep 'active processes' | head -1    | awk '{print $3}';;
  total_processes)   echo "$FPM_STATS" | grep 'total processes'  | head -1    | awk '{print $3}';;
  *) echo $ERROR_WRONG_PARAM; exit 1;;
esac

exit 0

