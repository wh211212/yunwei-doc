#!/bin/bash
##################################
# Zabbix monitoring script for xen check script
##################################
# ChangeLog:
# 2013-11-10  MD  init create

XENTOP_BIN="sudo /usr/sbin/xentop"
FREQUENCY="-b -i 2 -d 10"

# source data file
ZABBIX_BASE_DIR=`readlink -f $( dirname $(dirname $0) )`

DEST_DATA=$ZABBIX_BASE_DIR/tmp/zabbix_xentop
TMP_DATA=$ZABBIX_BASE_DIR/tmp/zabbix_xentop.tmp

SCRIPT_CONF=$ZABBIX_BASE_DIR/conf/nc_xen_check.conf
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

$XENTOP_BIN $FREQUENCY > $TMP_DATA
mv $TMP_DATA $DEST_DATA
