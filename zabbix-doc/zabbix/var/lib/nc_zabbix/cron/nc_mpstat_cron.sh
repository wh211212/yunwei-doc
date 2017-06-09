#!/bin/bash
##################################
# Zabbix monitoring script
#
# Info:
#  - cron job to gather mpstat data
#  - can not do real time as mpstat data gathering will exceed 
#    Zabbix agent timeout
##################################
# Contact:
#  vincent.viallet@gmail.com
##################################
# ChangeLog:
#  20130204    VV    initial creation
##################################
 
MPSTAT_BIN="/usr/bin/mpstat"
MPSTAT_OPT="-P ALL"
FREQUENCY="5 2"
 
# source data file
ZABBIX_BASE_DIR=`readlink -f $( dirname $(dirname $0) )`
 
DEST_DATA=$ZABBIX_BASE_DIR/tmp/zabbix_mpstat
TMP_DATA=$ZABBIX_BASE_DIR/tmp/zabbix_mpstat.tmp
 
SCRIPT_CONF=$ZABBIX_BASE_DIR/conf/nc_mpstat_check.conf
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF


#
# gather data in temp file first, then move to final location
# it avoids zabbix-agent to gather data from a half written source file
#
# mpstat -P ALL 10 1 - will display 1 set of stats :
#  - 1st line: statistics of avg for all CPU
#  - 2nd+: statistics over the last 10 sec per CPU
#
$MPSTAT_BIN $MPSTAT_OPT $FREQUENCY | grep -E '^Average' | sed -e '1d' > $TMP_DATA
mv $TMP_DATA $DEST_DATA


