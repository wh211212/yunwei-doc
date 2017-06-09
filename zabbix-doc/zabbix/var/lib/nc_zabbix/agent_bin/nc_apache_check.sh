#!/bin/bash
##################################
# Zabbix monitoring script
#
# apache:
#  - anything available via apache server-status module
#
##################################
# Contact:
#  daniel.lin@chinanetcloud.com
##################################
# ChangeLog:
#  20090527     DL      initial creation
#  20090909     AZ      change the function of check()
#  20110212     DL      restructure the script, add binary check and data check
#  20110413     DL      Convert from cron
#  20111110     VV      Change structure, perform retrieve check immediately after curl
##################################
VERSION=1.0

# Zabbix requested parameter
ZBX_REQ_DATA="$1"
ZBX_REQ_DATA_URL="$2"

# Apache defaults
APACHE_STATUS_DEFAULT_URL="http://127.0.0.2:80/server-status?auto"
# Default for binaries - use the PATH - override in the config file if PATH chaneg required
CURL_BIN=$(which curl)
HTTPD_BIN=$(which httpd)

# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF=$CURRENT_DIR/../conf/nc_apache_check.conf
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - items need to be of type "float" (allow negative + float)
#
ERROR_NO_ACCESS_FILE="-0.9900"
ERROR_NO_ACCESS="-0.9901"
ERROR_WRONG_PARAM="-0.9902"
ERROR_DATA="-0.9903" # either can not connect / bad host / bad port

# Handle host and port if non-default
if [ ! -z "$ZBX_REQ_DATA_URL" ]; then
  URL="$ZBX_REQ_DATA_URL"
else
  URL="$APACHE_STATUS_DEFAULT_URL"
fi

# Save the apache stats in a variable for future parsing
# Need to check retrieve status immediately after the curl
APACHE_STATUS=$($CURL_BIN $URL 2> /dev/null)
if [ $? -ne 0 -o -z "$APACHE_STATUS" ]; then
  echo $ERROR_DATA
  exit 1
fi

# Get scoreboard for monitoring split
TMPSCOREBOARD=$(echo $APACHE_STATUS | grep -i scoreboard | sed 's/Scoreboard://')

# 
# Extract data from apache stats
#
case $ZBX_REQ_DATA in
  version)              $HTTPD_BIN -v | awk -F / '{print $2}' | head -1;;
  total_kbytes)         echo "$APACHE_STATUS" | grep 'Total kBytes' | awk -F':' '{print $2}';;
  total_accesses)       echo "$APACHE_STATUS" | grep 'Total Accesses' | awk -F':' '{print $2}';;
  scoreboard_waiting)   echo "$TMPSCOREBOARD" | grep -o . | grep -c "\_";;
  scoreboard_starting)  echo "$TMPSCOREBOARD" | grep -o . | grep -c "S";;
  scoreboard_sending)   echo "$TMPSCOREBOARD" | grep -o . | grep -c "R";;
  scoreboard_reading)   echo "$TMPSCOREBOARD" | grep -o . | grep -c "W";;
  scoreboard_no-process)echo "$TMPSCOREBOARD" | grep -o . | grep -c "\.";;
  scoreboard_logging)   echo "$TMPSCOREBOARD" | grep -o . | grep -c "L";;
  scoreboard_keepalive) echo "$TMPSCOREBOARD" | grep -o . | grep -c "K";;
  scoreboard_idle-cleanup-of-worker)    echo "$TMPSCOREBOARD" | grep -o . | grep -c "I";;
  scoreboard_gracefully-finishing)      echo "$TMPSCOREBOARD" | grep -o . | grep -c "G";;
  scoreboard_dns-lookup)echo "$TMPSCOREBOARD" | grep -o . | grep -c "D";;
  scoreboard_closing)   echo "$TMPSCOREBOARD" | grep -o . | grep -c "C";;
  scoreboard)           echo "$APACHE_STATUS" | grep 'Scoreboard' | awk -F':' '{print $2}';;
  reqpersec)            echo "$APACHE_STATUS" | grep 'ReqPerSec' | awk -F':' '{print $2}';;
  idleworkers)          echo "$APACHE_STATUS" | grep 'IdleWorkers' | awk -F':' '{print $2}';;
  cpuload)              echo "$APACHE_STATUS" | grep 'CPULoad' | awk -F':' '{print $2}';;
  bytespersec)          echo "$APACHE_STATUS" | grep 'BytesPerSec' | awk -F':' '{print $2}';;
  bytesperreq)          echo "$APACHE_STATUS" | grep 'BytesPerReq' | awk -F':' '{print $2}';;
  busyworkers)          echo "$APACHE_STATUS" | grep 'BusyWorkers' | awk -F':' '{print $2}';;
  *)                    echo $ERROR_WRONG_PARAM; exit 1;;
esac

exit 0
