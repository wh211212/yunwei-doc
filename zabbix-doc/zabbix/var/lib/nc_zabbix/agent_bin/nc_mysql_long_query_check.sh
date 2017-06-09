##########################################
# MySQL real time monitoring for long query
##########################################
# Contact :
#  vincent.viallet@chinanetcloud.com
##########################################
###### Changed AH 2014-11-04 --skip-column to --skip-column-names ######
# Zabbix requested parameter - used as threshold for GOOD / BAD
# Integer - in seconds (10s by default)
ZBX_DATA_THRESHOLD="$1"
MYSQL_PORT="$2"
ZBX_DATA_THRESHOLD_DEFAULT=10
MYSQL_DEFAULT_PORT="3306"


# MySQL details
CURRENT_DIR=$(readlink -f $(dirname $0))
MYSQL_ACCESS="$CURRENT_DIR/../conf/mysql_credentials"
MYSQL_BIN="/usr/bin/mysql"


# Override defaults from config file
SCRIPT_CONF=$CURRENT_DIR/../conf/nc_mysql_long_query_check.conf
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - items need to be of type "float" (allow negative + float)
#
ERROR_NO_ACCESS_FILE="-0.9900"
ERROR_NO_ACCESS="-0.9901"
ERROR_WRONG_PARAM="-0.9902"

#
# Pre-pend text to the returned text
#  - GOOD
#  - BAD
PREP_RETURN_GOOD="GOOD"
PREP_RETURN_BAD="BAD"

# Assign default port if doesn't exist
if [ -z $MYSQL_PORT ]; then
  MYSQL_PORT="$MYSQL_DEFAULT_PORT"
fi

# No mysql access file to read login info from
MYSQL="$MYSQL_BIN --defaults-extra-file=$MYSQL_ACCESS -P $MYSQL_PORT --skip-column-names"
if [ ! -f "$MYSQL_ACCESS" ]; then
  echo $ERROR_NO_ACCESS_FILE
  exit 1
fi

# Check MySQL access 
echo "" | $MYSQL 2>&1 > /dev/null
if [ $? -ne 0 ]; then
  echo $ERROR_NO_ACCESS
  exit 1
fi

# Check if the threshold is a valid number
if [ ! -z "$ZBX_DATA_THRESHOLD" -a -z "$(echo $ZBX_DATA_THRESHOLD | grep -E '^[0-9]+$')" ]; then
  echo $ERROR_WRONG_PARAM
  exit 1
fi
# apply defaults if value is empty
if [ -z "$ZBX_DATA_THRESHOLD" ]; then
  ZBX_DATA_THRESHOLD=$ZBX_DATA_THRESHOLD_DEFAULT
fi

# This SQL is used to get the current running queries on the server
LONG_SQL="SELECT CONCAT(id, ' - ', user, ' - ', time, ' - ', left(ifnull(state,''), 25), ' - ', left(ifnull(info,''), 50)) as zabbix_long_query
     FROM information_schema.processlist 
    WHERE command <> 'Sleep' AND command <> 'Binlog Dump' AND state NOT LIKE 'Waiting for master to send event' AND state NOT LIKE 'Has read all relay log%' AND info NOT LIKE 'SELECT CONCAT%'
    ORDER BY time DESC limit 1;"
    
LONGEST_QUERY=$(echo $LONG_SQL | $MYSQL)

if [ "$LONGEST_QUERY" == '' ]; then
  echo $PREP_RETURN_GOOD
  exit 0
else
  # There is a result returned by the SQL - need to define if good or bad
  # Query time
  QUERY_TIME=$(echo $LONGEST_QUERY | cut -f3 -d'-')
  if [ $((QUERY_TIME)) -le $((ZBX_DATA_THRESHOLD)) ]; then
    echo $PREP_RETURN_GOOD" - "$LONGEST_QUERY
    exit 0
  else
    echo $PREP_RETURN_BAD" - "$LONGEST_QUERY
    exit 0
  fi
fi
