#!/bin/bash
##################################
# Zabbix monitoring script
#
# iostat:
#  - IO
#  - running / blocked processes
#  - swap in / out
#  - block in / out
#
# Info:
#  - vmstat data are gathered via cron job
##################################
# Contact:
#  vincent.viallet@gmail.com
##################################
# ChangeLog:
#  20100922    VV    initial creation
#  20110212    DL    change data file path
#  20110830    TW    fix awk bug with diffecet version of iostat
#  20120730    FC    fix cciss/c0d0 device check error
##################################

# Zabbix requested parameter
ZBX_REQ_DATA="$2"
ZBX_REQ_DATA_DEV="$1"

# source data file
ZABBIX_BASE_DIR=`readlink -f $( dirname $(dirname $0) )`
SOURCE_DATA=$ZABBIX_BASE_DIR/tmp/zabbix_iostat

# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF="$CURRENT_DIR/../conf/nc_iostat_check.conf"
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - items need to be of type "float" (allow negative + float)
#
ERROR_NO_DATA_FILE="-0.9900"
ERROR_OLD_DATA="-0.9901"
ERROR_WRONG_PARAM="-0.9902"
ERROR_MISSING_PARAM="-0.9903"

# No data file to read from
if [ ! -f "$SOURCE_DATA" ]; then
  echo $ERROR_NO_DATA_FILE
  exit 1
fi

# Missing device to get data from
if [ -z "$ZBX_REQ_DATA_DEV" ]; then
  echo $ERROR_MISSING_PARAM
  exit 1
fi

# Update DEV if starts with X (Xda matches hda, sda, xvda)
if [ ${ZBX_REQ_DATA_DEV:0:1} == 'X' ]; then
  ZBX_REQ_DATA_DEV=".*${ZBX_REQ_DATA_DEV:1}"
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
# 1st check the device exists and gets data gathered by cron job
device_count=$(grep -Ec "$ZBX_REQ_DATA_DEV " $SOURCE_DATA)
if [ $device_count -eq 0 ]; then
  echo $ERROR_WRONG_PARAM
  exit 1
fi


# 2nd grab the data from the source file, awk the correct column of the key
case $ZBX_REQ_DATA in
  rrqm/s)     grep -E "$ZBX_REQ_DATA_DEV " $SOURCE_DATA | tail -1 | awk "{print \$$(grep -i device $SOURCE_DATA | sed 's/rrqm\/s.*/rrqm\/s/g'   | tail -1 | wc -w)}";;
  wrqm/s)     grep -E "$ZBX_REQ_DATA_DEV " $SOURCE_DATA | tail -1 | awk "{print \$$(grep -i device $SOURCE_DATA | sed 's/wrqm\/s.*/wrqm\/s/g'   | tail -1 | wc -w)}";;
  r/s)        grep -E "$ZBX_REQ_DATA_DEV " $SOURCE_DATA | tail -1 | awk "{print \$$(grep -i device $SOURCE_DATA | sed 's/r\/s.*/r\/s/g'         | tail -1 | wc -w)}";;
  w/s)        grep -E "$ZBX_REQ_DATA_DEV " $SOURCE_DATA | tail -1 | awk "{print \$$(grep -i device $SOURCE_DATA | sed 's/w\/s.*/w\/s/g'         | tail -1 | wc -w)}";;
  rkB/s)      grep -E "$ZBX_REQ_DATA_DEV " $SOURCE_DATA | tail -1 | awk "{print \$$(grep -i device $SOURCE_DATA | sed 's/rkB\/s.*/rkB\/s/g'     | tail -1 | wc -w)}";;
  wkB/s)      grep -E "$ZBX_REQ_DATA_DEV " $SOURCE_DATA | tail -1 | awk "{print \$$(grep -i device $SOURCE_DATA | sed 's/wkB\/s.*/wkB\/s/g'     | tail -1 | wc -w)}";;
  avgrq-sz)   grep -E "$ZBX_REQ_DATA_DEV " $SOURCE_DATA | tail -1 | awk "{print \$$(grep -i device $SOURCE_DATA | sed 's/avgrq-sz.*/avgrq-sz/g' | tail -1 | wc -w)}";;
  avgqu-sz)   grep -E "$ZBX_REQ_DATA_DEV " $SOURCE_DATA | tail -1 | awk "{print \$$(grep -i device $SOURCE_DATA | sed 's/avgqu-sz.*/avgqu-sz/g' | tail -1 | wc -w)}";;
  await)      grep -E "$ZBX_REQ_DATA_DEV " $SOURCE_DATA | tail -1 | awk "{print \$$(grep -i device $SOURCE_DATA | sed 's/await.*/await/g'       | tail -1 | wc -w)}";;
  svctm)      grep -E "$ZBX_REQ_DATA_DEV " $SOURCE_DATA | tail -1 | awk "{print \$$(grep -i device $SOURCE_DATA | sed 's/svctm.*/svctm/g'       | tail -1 | wc -w)}";;
  %util)      grep -E "$ZBX_REQ_DATA_DEV " $SOURCE_DATA | tail -1 | awk "{print \$$(grep -i device $SOURCE_DATA | sed 's/%util.*/%util/g'       | tail -1 | wc -w)}";;
  *) echo $ERROR_WRONG_PARAM; exit 1;;
esac

exit 0
