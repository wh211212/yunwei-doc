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
SOURCE_DATA=$ZABBIX_BASE_DIR/tmp/zabbix_vmstat

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
  runningprocess)     tail -1 $SOURCE_DATA | awk '{print $1}';;
  blockedprocess)     tail -1 $SOURCE_DATA | awk '{print $2}';;
  swapuse)  tail -1 $SOURCE_DATA | awk '{print $3}';;
  idlemem)  tail -1 $SOURCE_DATA | awk '{print $4}';;
  buffmem)  tail -1 $SOURCE_DATA | awk '{print $5}';;
  cachmem)  tail -1 $SOURCE_DATA | awk '{print $6}';;
  swapin)   tail -1 $SOURCE_DATA | awk '{print $7}';;
  swapout)  tail -1 $SOURCE_DATA | awk '{print $8}';;
  blockin)  tail -1 $SOURCE_DATA | awk '{print $9}';;
  blockout) tail -1 $SOURCE_DATA | awk '{print $10}';;
  interrupt)tail -1 $SOURCE_DATA | awk '{print $11}';;
  contextsw)tail -1 $SOURCE_DATA | awk '{print $12}';;
  usertime) tail -1 $SOURCE_DATA | awk '{print $13}';;
  systime)  tail -1 $SOURCE_DATA | awk '{print $14}';;
  idletime) tail -1 $SOURCE_DATA | awk '{print $15}';;
  waittime) tail -1 $SOURCE_DATA | awk '{print $16}';;
  stealtime)tail -1 $SOURCE_DATA | awk '{print $17}';;
  *) echo $ERROR_WRONG_PARAM; exit 1;;
esac

exit 0
