#!/bin/bash
##################################
# Zabbix monitoring script
#
# squid:
#   - anything available via squid-tool stats
##################################
# Contact:
#  vincent.viallet@gmail.com
##################################
# ChangeLog:
#  20101012    TW    initial creation
#  20110802    DL    wait open file func
##################################

# Zabbix requested parameter
ZBX_REQ_DATA="$1"

# source data file
SOURCE_DATA=/var/lib/nc_zabbix/tmp/squid.return

#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - items need to be of type "float" (allow negative + float)
#
ERROR_NO_DATA_FILE="-0.9900"
ERROR_OLD_DATA="-0.9901"
ERROR_WRONG_PARAM="-0.9902"

if [ ! -f "$SOURCE_DATA" ]; then
  echo $ERROR_NO_DATA_FILE
  exit 1
fi

#
# Old data handling:
#  - in case the cron can not update the data file
#  - in case the data are too old we want to notify the system
# Consider the data as non-valid if older than OLD_DATA minutes
#

OLD_DATA=5

if [ $(stat -c "%Y" $SOURCE_DATA) -lt $(date -d "now -$OLD_DATA min" "+%s" ) ]; then
  echo $ERROR_OLD_DATA
  exit 1
fi

# 
# Grab data from SOURCE_DATA for key ZBX_REQ_DATA
#
case $ZBX_REQ_DATA in
  version)           grep  "Squid Object Cache"                           $SOURCE_DATA | cut -f 2 -d ':' | sed "s/[ \t][ \t]*//g";;
  client_count)      grep  "Number of clients accessing cache"            $SOURCE_DATA | cut -f 2 -d ':' | sed "s/[ \t][ \t]*//g";;
  http_req_rec)      grep  "Number of HTTP requests received"             $SOURCE_DATA | cut -f 2 -d ':' | sed "s/[ \t][ \t]*//g";;
  http_avg_uptime)   grep  "Average HTTP requests per minute since start" $SOURCE_DATA | cut -f 2 -d ':' | sed "s/[ \t][ \t]*//g";;
  hit_req_rate_5)    grep  "Hits as % of all requests"                    $SOURCE_DATA | cut -f 1 -d ',' | awk -F ':' '{print $NF}' | sed "s/[ \t][ \t]*//g" | cut -f 1 -d '%';;
  hit_req_rate_60)   grep  "Hits as % of all requests"                    $SOURCE_DATA | cut -f 2 -d ',' | awk -F ':' '{print $NF}' | sed "s/[ \t][ \t]*//g" | cut -f 1 -d '%';;
  hit_byte_rate_5)   grep  "Hits as % of bytes sent"                      $SOURCE_DATA | cut -f 1 -d ',' | awk -F ':' '{print $NF}' | sed "s/[ \t][ \t]*//g" | cut -f 1 -d '%';;
  hit_byte_rate_60)  grep  "Hits as % of bytes sent"                      $SOURCE_DATA | cut -f 2 -d ',' | awk -F ':' '{print $NF}' | sed "s/[ \t][ \t]*//g" | cut -f 1 -d '%';;
  mem_hit_req_5)     grep  "Memory hits as % of hit requests"             $SOURCE_DATA | cut -f 1 -d ',' | awk -F ':' '{print $NF}' | sed "s/[ \t][ \t]*//g" | cut -f 1 -d '%';;
  mem_hit_req_60)    grep  "Memory hits as % of hit requests"             $SOURCE_DATA | cut -f 2 -d ',' | awk -F ':' '{print $NF}' | sed "s/[ \t][ \t]*//g" | cut -f 1 -d '%';;
  disk_hit_req_5)    grep  "Disk hits as % of hit requests"               $SOURCE_DATA | cut -f 1 -d ',' | awk -F ':' '{print $NF}' | sed "s/[ \t][ \t]*//g" | cut -f 1 -d '%';;
  disk_hit_req_60)   grep  "Disk hits as % of hit requests"               $SOURCE_DATA | cut -f 2 -d ',' | awk -F ':' '{print $NF}' | sed "s/[ \t][ \t]*//g" | cut -f 1 -d '%';;
  file_dec_inuse)    grep  "Number of file desc currently in use"         $SOURCE_DATA | cut -f 2 -d ':' | awk -F ':' '{print $NF}' | sed "s/[ \t][ \t]*//g";;
  file_dec_ava)      grep "Available number of file descriptors"          $SOURCE_DATA | cut -f 2 -d ':' | awk -F ':' '{print $NF}' | sed "s/[ \t][ \t]*//g";;
  num_http_req)      grep "Number of HTTP requests received"              $SOURCE_DATA | cut -f 2 -d ':' | awk -F ':' '{print $NF}' | sed "s/[ \t][ \t]*//g";;
  *) echo $ERROR_WRONG_PARAM; exit 1;;
esac

exit 0


