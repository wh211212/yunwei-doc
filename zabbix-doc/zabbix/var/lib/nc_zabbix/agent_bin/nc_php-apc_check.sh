#!/bin/bash
##################################
# Zabbix monitoring script
#
# php-apc :
#  - anything available via apc.php page
#
##################################
# Contact:
#  vincent.viallet@gmail.com
##################################
# ChangeLog:
#  20110124    VV    initial creation
#  20110916     Eason.tao
#  20111103    VV    Make it semi-realtime - rely on existing temp file
##################################

# Zabbix requested parameter
ZBX_REQ_DATA="$1"
ZBX_REQ_DATA_URL="$2"

# APC defaults
APC_STATUS_DEFAULT_URL=""
LINKS_BIN="/usr/bin/links"
# apc.php is CPU intensive - need to use a temp file - Max-Age in minutes
MAX_AGE=5
MAX_AGE_EPOCH=$(($(date "+%s")-$(($MAX_AGE*60))))
APC_STATUS_FILE="/tmp/nc_apc_output.dump"

# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF="$CURRENT_DIR/../conf/nc_php-apc_check.conf"
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
if [ ! -z "$ZBX_REQ_DATA_URL" ]; then
  URL="$ZBX_REQ_DATA_URL"
else
  URL="$APC_STATUS_DEFAULT_URL"
fi

# save the php-apc stats in a variable for future parsing
if [ ! -f "$APC_STATUS_FILE" ]; then 
  $LINKS_BIN $URL -dump > $APC_STATUS_FILE 2> /dev/null    
elif [ -f "$APC_STATUS_FILE" -a $(stat -c "%Z" "$APC_STATUS_FILE") -lt $MAX_AGE_EPOCH ]; then
  $LINKS_BIN $URL -dump > $APC_STATUS_FILE.tmp 2> /dev/null
  if [ $? -eq 0 ]; then
    mv $APC_STATUS_FILE.tmp $APC_STATUS_FILE
  else
    # Error while running the fetch
    echo $ERROR_DATA
    exit 1
  fi
fi

APC_STATS=$(cat $APC_STATUS_FILE)

# error during retrieve
if [ $? -ne 0 -o -z "$APC_STATS" ]; then
  echo $ERROR_DATA
  exit 1
fi

# convert GBytes / MBytes / KBytes to bytes
# Based on the 2nd field (unit)
convert_from_size() {
  value=$1
  unit=$2

  # validate the value is a number (not perfect but ...)
  echo $value | grep -E '^[0-9.]+$' 2>&1 > /dev/null
  if [ $? -ne 0 ]; then
    echo $ERROR_STATS
    exit 1
  fi

  case $unit in
    Bytes | B | b)  echo "$value";;
    KBytes | K | k) echo "$value * 1024" | bc | cut -f1 -d. ;;
    MBytes | M | m) echo "$value * 1024 * 1024" | bc | cut -f1 -d. ;;
    GBytes | G | g) echo "$value * 1024 * 1024 * 1024" | bc | cut -f1 -d. ;;
  esac
}

# 
# Extract data from nginx stats
#
case $ZBX_REQ_DATA in
  version)             echo "$APC_STATS" | grep 'APC Version'    | head -1             | awk '{print $3}';;
  cached_files_count)  echo "$APC_STATS" | grep 'Cached Files'   | head -1             | awk '{print $3}';;
  cached_files_size)   convert_from_size $(echo "$APC_STATS"     | grep 'Cached Files' | head -1 | awk '{print $5 " " $6}' | sed -e 's/(//' -e 's/)//');;
  hits)                echo "$APC_STATS" | grep 'Hits'           | head -1             | awk '{print $2}';;
  hits%)               echo "$APC_STATS" | grep 'Hits:'          | awk '{print $7}'    | sed -e 's/(//' -e 's/)//';;
  misses)              echo "$APC_STATS" | grep 'Misses'         | head -1             | awk '{print $2}';;
  request_rate)        echo "$APC_STATS" | grep 'Request Rate'   | head -1             | awk '{print $5}';;
  hit_rate)            echo "$APC_STATS" | grep 'Hit Rate'       | head -1             | awk '{print $3}';;
  miss_rate)           echo "$APC_STATS" | grep 'Miss Rate'      | head -1             | awk '{print $3}';;
  insert_rate)         echo "$APC_STATS" | grep 'Insert Rate'    | head -1             | awk '{print $3}';;
  shm_size)            convert_from_size $(echo "$APC_STATS"     | grep 'apc.shm_size'   | head -1 | awk '{print $2}' | sed -e 's/\([0-9]*\)\([a-zA-Z]\)/\1 \2/');;
  mem_free)            convert_from_size $(echo "$APC_STATS"     | grep 'Free' | head -1 | awk '{print $2 " " $3}' | sed -e 's/(//' -e 's/)//');;
  mem_used)            convert_from_size $(echo "$APC_STATS"     | grep 'Used' | head -1 | awk '{print $2 " " $3}' | sed -e 's/(//' -e 's/)//');;
  fragmentation)       echo "$APC_STATS" | grep 'Fragmentation:' | head -1         | awk '{print $2}' | sed -e 's/%//';;
  *) echo $ERROR_WRONG_PARAM; exit 1;;
esac

exit 0
