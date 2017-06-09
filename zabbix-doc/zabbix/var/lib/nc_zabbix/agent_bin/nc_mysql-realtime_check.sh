#!/bin/bash
##################################
# Zabbix monitoring script
#
# mysql:
#  - MySQL variables
#  - MySQL status
#  - MySQL master / slave status
#
# Info:
#  - mysql data are gathered real-time
##################################
# Contact:
#  vincent.viallet@gmail.com
##################################
# ChangeLog:
#  20100922	VV	initial creation
#  20110819	VV	remove qps / ping, merge innodb / status / master / slave
#  20110829	VV	add innodb-status file read
#  20120213	CZ      add config file for override defaults
#  20121227	TW	add system ram check for innodb_buffer_pool_size monitoring 
#  20150411     TZ      change --skip-column to --skip-column-names
#  20160706     TZ      Add Port for multi MySQL instances
#  20160707     TZ      Add new function to output data to temp file
#  20160719     TZ      Add new function run_sql to get result from specify sql
##################################

# Zabbix requested parameter
ZBX_REQ_DATA="$1"
ZBX_REQ_DATA_SOURCE="$2"
MYSQL_PORT="$3"
ZBX_REQ_DATA2="$4"
ZBX_REQ_DATA3="$5"
ZBX_REQ_DATA4="$6"

# MySQL details
CURRENT_DIR=$(readlink -f $(dirname $0))
ZABBIX_BASE_DIR=`readlink -f $( dirname $(dirname $0) )`
MYSQL_ACCESS="$CURRENT_DIR/../conf/mysql_credentials"
MYSQL_BIN="/usr/bin/mysql"
MYSQL_DEFAULT_PORT="3306"
OLD_DATA=5

# Override defaults from config file
SCRIPT_CONF="$CURRENT_DIR/../conf/nc_mysql-realtime_check.conf"
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - numeric items need to be of type "float" (allow negative + float)
#
ERROR_NO_ACCESS_FILE="-0.9900"
ERROR_NO_ACCESS="-0.9901"
ERROR_WRONG_PARAM="-0.9902"
ERROR_GENERIC="-0.9903"
ERROR_RUN_COMMAND="-0.9904"

# No mysql access file to read login info from
if [ ! -f "$MYSQL_ACCESS" ]; then
  echo $ERROR_NO_ACCESS_FILE
  exit 1
fi

# Assign default port if doesn't exist
if [ -z $MYSQL_PORT ]; then
  MYSQL_PORT="$MYSQL_DEFAULT_PORT"
fi

# Check MySQL access
MYSQL="$MYSQL_BIN --defaults-extra-file=$MYSQL_ACCESS -P $MYSQL_PORT"
echo "" | $MYSQL 2>/dev/null
if [ $? -ne 0 ]; then
  echo $ERROR_NO_ACCESS
  exit 1
fi

# Only ZBX_REQ_DATA is mandatory
# If ZBX_REQ_DATA_SOURCE is not specified, get from mysql global status
if [ -z "$ZBX_REQ_DATA" ]; then
  echo $ERROR_WRONG_PARAM
  exit 1
fi

if [ -z "$ZBX_REQ_DATA_SOURCE" ]; then
  ZBX_REQ_DATA_SOURCE='status'
fi

#############
# Data retrieve methods
#############
# Output the data to temp file
get_source_data(){
  COMMAND="$1"
  SOURCE_DATA="$ZABBIX_BASE_DIR/tmp/mysql_$MYSQL_PORT.$ZBX_REQ_DATA_SOURCE.tmp"
  if [ -f "$SOURCE_DATA" ];then
    if [ $(stat -c "%Y" $SOURCE_DATA) -gt $(date -d "now -$OLD_DATA min" "+%s" ) ];then
      return
    fi
  fi
  
  # Execute command to get newest data
  eval $COMMAND 2>/dev/null > $SOURCE_DATA
}

get_from_status(){
  param=$1
  COMMAND="echo 'show global status' | $MYSQL --skip-column-names"
  get_source_data "$COMMAND" 
  value=$(grep -Ei "^$param[[:space:]]" "$SOURCE_DATA" 2>/dev/null | awk '{print $2}')
  [ -z "$value" ] && echo $ERROR_WRONG_PARAM || echo $value
}

get_from_variables(){
  param=$1
  COMMAND="echo 'show global variables;' | $MYSQL --skip-column-names"
  get_source_data "$COMMAND"
  value=$(grep -Ei "^$param[[:space:]]" "$SOURCE_DATA" 2>/dev/null | awk '{print $2}')
  [ -z "$value" ] && echo $ERROR_WRONG_PARAM || echo $value
}

get_from_master(){
  param=$1
  COMMAND="echo 'show master status \G' | $MYSQL"
  get_source_data "$COMMAND"
  value=$(grep -Ei "^[ ]*$param:" "$SOURCE_DATA" 2>/dev/null | awk '{print $2}')
  [ -z "$value" ] && echo $ERROR_WRONG_PARAM || echo $value
}

get_from_slave(){
  param=$1
  COMMAND="echo 'show slave status \G' | $MYSQL"
  get_source_data "$COMMAND"
  value=$(grep -Ei "^[ ]*$param:" "$SOURCE_DATA" 2>/dev/null | awk '{print $2}')
  [ -z "$value" ] && echo $ERROR_WRONG_PARAM || echo $value
}

get_from_innodb_file(){
  param=$1
  COMMAND="$MYSQL --skip-column-names --silent -e 'show global variables;'"
  get_source_data "$COMMAND"
  datadir=$(grep -Ei '^datadir[[:space:]]' "$SOURCE_DATA" 2>/dev/null | awk '{print $2}')
    if [ -z "$datadir" -o ! -e "$datadir" ]; then echo $ERROR_GENERIC; exit 1; fi
  pid_file=$(grep -Ei '^pid_file[[:space:]]' "$SOURCE_DATA" 2>/dev/null| awk '{print $2}')
    if [ -z "$pid_file" -o ! -e "$pid_file" ]; then echo $ERROR_GENERIC; exit 1; fi
  innodb_file=$datadir/innodb_status.$(sudo cat $pid_file)
    if [ "$innodb_file" == "$datadir/innodb_status." ]; then echo $ERROR_GENERIC; exit 1; fi
	innodb_file_content=$(sudo cat $innodb_file)
	  if [ -z "$innodb_file_content" ]; then echo $ERROR_GENERIC; exit 1; fi
	
	case $param in
	  innodb_row_queries) echo "$innodb_file_content" | grep 'queries inside InnoDB' | awk '{print $1}';;
	  innodb_row_queue)   echo "$innodb_file_content" | grep 'queries inside InnoDB' | awk '{print $5}';;
      history_list_length)   echo "$innodb_file_content" | grep 'History list length' | awk '{print $4}';;
	  *) echo $ERROR_WRONG_PARAM; exit 1;;
  esac
}

get_system_ram(){
  param=$1
  value=$(free -b | grep Mem | awk '{print $2}')
  [ -z "$value" ] && echo $ERROR_WRONG_PARAM || echo $value
}
 
run_sql(){
  param=$1

  if [ $param == "run" ];then
    table="$2"
    order_column="$3"
    order_mode="$4"
    if [ -z $order_column ];then
      echo "SELECT * from $table limit 20;" | $MYSQL
    else
      echo "SELECT * from $table ORDER BY $order_column $order_mode limit 20;" | $MYSQL
    fi
  elif [ $param == "processlist" ];then
    VERSION=$(get_from_variables "version_comment")
    if [ $VERSION == "Percona" ];then
      PROCESSLIST_SQL="SELECT id, user, host, db, time, state, command, info, rows_examined, rows_sent
      FROM information_schema.processlist
      WHERE command <> 'Sleep'
      AND user <> 'system user'
      AND user <> 'repl'
      ORDER BY time DESC;"
    else
      PROCESSLIST_SQL="SELECT id, user, host, db, time, state, command, info
      FROM information_schema.processlist
      WHERE command <> 'Sleep'
      AND user <> 'system user'
      AND user <> 'repl'
      ORDER BY time DESC;"
    fi
    echo $PROCESSLIST_SQL | $MYSQL
  else
    echo $ERROR_WRONG_PARAM 
  fi
}

# 
# Grab data from mysql for key ZBX_REQ_DATA
#
case $ZBX_REQ_DATA_SOURCE in
  slave)	get_from_slave		"$ZBX_REQ_DATA";;
  master)	get_from_master		"$ZBX_REQ_DATA";;
  status)	get_from_status		"$ZBX_REQ_DATA";;
  variables)	get_from_variables	"$ZBX_REQ_DATA";;
  innodb_file) 	get_from_innodb_file "$ZBX_REQ_DATA";;
  system)    get_system_ram "$ZBX_REQ_DATA";;
  sql)    run_sql "$ZBX_REQ_DATA" "$ZBX_REQ_DATA2" "$ZBX_REQ_DATA3" "$ZBX_REQ_DATA4";;
  *) echo $ERROR_WRONG_PARAM; exit 1;;
esac

exit 0
