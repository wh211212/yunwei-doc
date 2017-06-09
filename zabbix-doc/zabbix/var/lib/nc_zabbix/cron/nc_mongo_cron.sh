#!/bin/bash
##################################
# Zabbix monitoring script
#
# Info:
#  - cron job to check if mongo is still alive
##################################
# Contact:
#  cjtoolseram@gmail.com
##################################
# ChangeLog:
#  20130311    CJ      modified from existing
#  20160612    TZ      Commeted out sed sections
##################################
# source data file
#ZABBIX_BASE_DIR=`readlink -f $( dirname $(dirname $0) )`
ZABBIX_BASE_DIR="/var/lib/nc_zabbix"

# scripts variables
MONGO_BIN="/usr/bin/mongo"
MONGOSTAT_BIN="/usr/bin/mongostat"

SERVERSTATUS=$ZABBIX_BASE_DIR"/tmp/mongodb.status"
SERVERSTATUS_TMP=$ZABBIX_BASE_DIR"/tmp/mongodb.status.tmp"
SERVERSTATUSJS=$ZABBIX_BASE_DIR"/bin/nc_mongo_serverstatus.js"

MONGOSTAT_TMP=$ZABBIX_BASE_DIR"/tmp/mongostat.tmp"
MONGO_HOST="localhost"
MONGO_PORT="27017"
MONGO_USER=""
MONGO_PWD=""

# grep config
SCRIPT_CONF=$ZABBIX_BASE_DIR"/conf/nc_mongo_check.conf"
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

# if no user is provided, don't use authentication
if [ -z "$MONGO_USER" ]; then
    $MONGO_BIN admin --host $MONGO_HOST --port $MONGO_PORT $SERVERSTATUSJS > $SERVERSTATUS_TMP
else
    $MONGO_BIN -u $MONGO_USER -p$MONGO_PWD admin --host $MONGO_HOST --port $MONGO_PORT $SERVERSTATUSJS > $SERVERSTATUS_TMP
fi

$MONGOSTAT_BIN --host $MONGO_HOST --port $MONGO_PORT 5 -n 1 > $MONGOSTAT_TMP

# Commented out by Tina as use "JSON.stringify" to output tightly compact string form
# section1: remould the data section of the data file
#sed -i '/ISO/s/"//3; /ISO/s/"//3' $SERVERSTATUS_TMP
#sed -i 's/ISODate/"ISODate/g; s/)/)"/g' $SERVERSTATUS_TMP

# section2: added in to sed the numbers to numberlong
#sed -i 's/ NumberLong("\([0-9][0-9]*\)")"/ \1/' $SERVERSTATUS_TMP
#sed -i 's/NumberLong/"NumberLong/g; s/)/)/g' $SERVERSTATUS_TMP

mv $SERVERSTATUS_TMP $SERVERSTATUS
