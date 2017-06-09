#!/bin/bash
##################################
# Zabbix monitoring script
#
# drbd:
#   - anything available via /proc/drbd stats
##################################
# ChangeLog:
#  20110617    AS    initial creation
##################################

# Zabbix requested parameter
ZBX_REQ_DATA="$1"

# source data file
SOURCE_DATA=/proc/drbd

# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF="$CURRENT_DIR/../conf/nc_drbd_check.conf"
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

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
  version)grep  "version" $SOURCE_DATA | cut -f2 -d ":" | awk '{print $1}' |sed "s/[ \t][ \t]*//g";;
  cs)     grep  "cs"      $SOURCE_DATA | cut -f3 -d ":" | awk '{print $1}' |sed "s/[ \t][ \t]*//g";;
  ro)     grep  "cs"      $SOURCE_DATA | cut -f4 -d ":" | awk '{print $1}' |sed "s/[ \t][ \t]*//g";;
  ds)     grep  "cs"      $SOURCE_DATA | cut -f5 -d ":" | awk '{print $1}' |sed "s/[ \t][ \t]*//g";;
  ns)     grep  "ns"      $SOURCE_DATA | cut -f2 -d ":" | awk '{print $1}' |sed "s/[ \t][ \t]*//g";;
  nr)     grep  "ns"      $SOURCE_DATA | cut -f3 -d ":" | awk '{print $1}' |sed "s/[ \t][ \t]*//g";;
  dw)     grep  "ns"      $SOURCE_DATA | cut -f4 -d ":" | awk '{print $1}' |sed "s/[ \t][ \t]*//g";;
  dr)     grep  "ns"      $SOURCE_DATA | cut -f5 -d ":" | awk '{print $1}' |sed "s/[ \t][ \t]*//g";;
  al)     grep  "ns"      $SOURCE_DATA | cut -f6 -d ":" | awk '{print $1}' |sed "s/[ \t][ \t]*//g";;
  bm)     grep  "ns"      $SOURCE_DATA | cut -f7 -d ":" | awk '{print $1}' |sed "s/[ \t][ \t]*//g";;
  lo)     grep  "ns"      $SOURCE_DATA | cut -f8 -d ":" | awk '{print $1}' |sed "s/[ \t][ \t]*//g";;
  pe)     grep  "ns"      $SOURCE_DATA | cut -f9 -d ":" | awk '{print $1}' |sed "s/[ \t][ \t]*//g";;
  ua)     grep  "ns"      $SOURCE_DATA | cut -f10 -d ":" | awk '{print $1}' |sed "s/[ \t][ \t]*//g";;
  ap)     grep  "ns"      $SOURCE_DATA | cut -f11 -d ":" | awk '{print $1}' |sed "s/[ \t][ \t]*//g";;
  ep)     grep  "ns"      $SOURCE_DATA | cut -f12 -d ":" | awk '{print $1}' |sed "s/[ \t][ \t]*//g";;
  wo)     grep  "ns"      $SOURCE_DATA | cut -f13 -d ":" | awk '{print $1}' |sed "s/[ \t][ \t]*//g";;
  oos)    grep  "ns"      $SOURCE_DATA | cut -f14 -d ":" | awk '{print $1}' |sed "s/[ \t][ \t]*//g";;
  *) echo $ERROR_WRONG_PARAM; exit 1;;
esac

exit 0
