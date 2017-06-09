#!/bin/bash
##################################
# Zabbix monitoring script
#
# vmstat:
#  - IO
#  - running / blocked processes
#  - swap in / out
#  - block in / out
#
# Info:
#  - vmstat data are gathered via cron job
#  - soon OUTDATED - can use mostly system.stat[resource,<type>] from 
#    Zabbix-1.8.1 - need to update Template
##################################
# Contact:
#  vincent.viallet@gmail.com
##################################
# ChangeLog:
#  20100922    VV    initial creation
#  20110212    DL    change data path, add st
#  20110402    DL    change param to meet our template
##################################
VERSION=1.0

# Zabbix requested parameter
ZBX_REQ_DATA="$1"

# source data file
ZABBIX_BASE_DIR=`readlink -f $( dirname $(dirname $0) )`
SOURCE_DATA=$ZABBIX_BASE_DIR/tmp/mongostat.tmp

#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - items need to be of type "float" (allow negative + float)
#
ERROR_NO_DATA_FILE="-0.9900"
ERROR_OLD_DATA="-0.9901"
ERROR_WRONG_PARAM="-0.9902"

# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF=$CURRENT_DIR/../conf/nc_mongo_check.conf
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF


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
  # "globalLock.ratio"    ) tail -1 $SOURCE_DATA  | awk '{print $12}';;
  *            ) /var/lib/nc_zabbix/bin/nc_mongo_check.py $ZBX_REQ_DATA;;
esac

exit 0
