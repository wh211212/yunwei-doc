#!/bin/bash
##################################
# Zabbix monitoring script
#
# memcacheq:
#  - anything available via memcached-tool stats
#
# Allowed parameters combinaisons:
#  - param 
#  - param + listening IP
#  - param + listening IP + port
##################################
# Contact:
#  vincent.viallet@gmail.com
##################################
# ChangeLog:
#  20100922    VV    initial creation
##################################

# Zabbix requested parameter
ZBX_REQ_DATA="$1"
ZBX_REQ_DATA_HOST="$2"
ZBX_REQ_DATA_PORT="$3"

# Memcached defaults
MEMCACHEQ_DEFAULT_HOST="127.0.0.1"
MEMCACHEQ_DEFAULT_PORT="22201"
MEMCACHED_TOOL_BIN="/usr/bin/memcached-tool"

#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - items need to be of type "float" (allow negative + float)
#
ERROR_NO_ACCESS_FILE="-0.9900"
ERROR_NO_ACCESS="-0.9901"
ERROR_WRONG_PARAM="-0.9902"
ERROR_DATA="-0.9903" # either can not connect /    bad host / bad port

# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF=$CURRENT_DIR/../conf/nc_memcacheq_check.conf
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

# Handle host and port if non-default
# Allowed parameters combinaisons:
#  - param 
#  - param + listening IP
#  - param + listening IP + port
if [ ! -z "$ZBX_REQ_DATA_HOST" ]; then
  HOST="$ZBX_REQ_DATA_HOST"
  if [ ! -z "$ZBX_REQ_DATA_PORT" ]; then
    PORT="$ZBX_REQ_DATA_PORT"
  else
    PORT="$MEMCACHEQ_DEFAULT_PORT"
  fi
else
  HOST="$MEMCACHEQ_DEFAULT_HOST"
  PORT="$MEMCACHEQ_DEFAULT_PORT"
fi

# save the memcacheq stats in a variable for future parsing
MEMCACHEQ_STATS=$($MEMCACHED_TOOL_BIN $HOST:$PORT stats 2> /dev/null )

# error during retrieve
if [ $? -ne 0 ]; then
  echo $ERROR_DATA
  exit 1
fi

# 
# Extract data from memcacheq stats
#
MEMCACHEQ_VALUE=$(echo "$MEMCACHEQ_STATS" | grep -E "^ .* $ZBX_REQ_DATA " | awk '{print $2}')

if [ ! -z "$MEMCACHEQ_VALUE" ]; then
  echo $MEMCACHEQ_VALUE
else
  echo $ERROR_WRONG_PARAM
  exit 1
fi

exit 0
