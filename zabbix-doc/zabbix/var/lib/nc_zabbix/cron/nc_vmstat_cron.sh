#!/bin/bash
##################################
# Zabbix monitoring script
#
# Info:
#  - cron job to gather vmstat data
#  - can not do real time as vmstat data gathering will exceed 
#    Zabbix agent timeout
##################################
# Contact:
#  vincent.viallet@gmail.com
##################################
# ChangeLog:
#  20100922    VV    initial creation
#  20110212    DL    change tmp path
##################################
 
VMSTAT_BIN="/usr/bin/vmstat"
FREQUENCY="10 2"
 
# source data file
ZABBIX_BASE_DIR=`readlink -f $( dirname $(dirname $0) )`
 
DEST_DATA=$ZABBIX_BASE_DIR/tmp/zabbix_vmstat
TMP_DATA=$ZABBIX_BASE_DIR/tmp/zabbix_vmstat.tmp
 
SCRIPT_CONF=$ZABBIX_BASE_DIR/conf/nc_vmstat_check.conf
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF


#
# gather data in temp file first, then move to final location
# it avoids zabbix-agent to gather data from a half written source file
#
# vmstat 10 2 - will display 2 lines :
#  - 1st: statistics since boot -- useless
#  - 2nd: statistics over the last 10 sec
#
$VMSTAT_BIN $FREQUENCY > $TMP_DATA
mv $TMP_DATA $DEST_DATA


