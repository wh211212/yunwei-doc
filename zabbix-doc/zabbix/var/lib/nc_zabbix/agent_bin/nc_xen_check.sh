#!/bin/bash
##################################
# Zabbix monitoring script
#
# Info:
#  - xen monitor
##################################
# Contact:
#  Mick.Duan@ChinaNetCloud.com
##################################
# ChangeLog:
#  20130721    MD    initial creation
##################################

XM_BIN="/usr/sbin/xm"
OLD_DATA=5

# Zabbix requested parameter
ZBX_REQ_DATA="$1"

# Override defaults from config file
ZABBIX_BASE_DIR=`readlink -f $( dirname $(dirname $0) )`
SOURCE_DATA=$ZABBIX_BASE_DIR/tmp/zabbix_xentop
SCRIPT_CONF="$CURRENT_DIR/../conf/nc_xen_check.conf"
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

# Missing device to get data from
if [ -z "$ZBX_REQ_DATA" ]; then
  echo $ERROR_MISSING_PARAM
  exit 1
fi

# Check source saved file -- from cron job scripts.
if [ ! -f "$SOURCE_DATA" ]; then
  echo $ERROR_NO_DATA_FILE
  exit 1
fi
#
# Make sure the output saved file has been updated
if [ $(stat -c "%Y" $SOURCE_DATA) -lt $(date -d "now -$OLD_DATA min" "+%s" ) ]; then
  echo $ERROR_OLD_DATA
  exit 1
fi

# get output saved file a half line number --get we want lines
need_get_num=$(( $(cat $SOURCE_DATA |wc -l)/2 ))

# get we want get lines, -- exclude the statistics lines since the last time the system was booted
domo_stat=$(tail -n $need_get_num $SOURCE_DATA 2>/dev/null |grep -v ' NAME' |sed 's/no limit/nolimit/g'|grep -v 'grep' )

# use "xm info" command get information
xminfo_check() {
  REQ_PARMT="$1"
  return_val=$(echo "$(sudo $XM_BIN info)" |grep "$REQ_PARMT" |awk -F': ' '{print $2}' |grep -v 'grep' )
  if [ -z "$return_val" ];then
     echo $ERROR_OLD_DATA
     exit 1
  fi
  echo $return_val
}

# get DomO cpu number
cpu_num=$(xminfo_check nr_cpus)

memory_free=$(xminfo_check free_memory)
memory_total=$(xminfo_check total_memory)
mem_free=$(( $memory_free * 1024 * 1024 ))
mem_used=$(( $memory_total * 1024 * 1024 - $mem_free ))
case $ZBX_REQ_DATA in
    # awk the correct 'CPU(%)' column of domo_stat, sum this column. Use `bc` command：get cpu percent.
    cpu_percent)  echo "scale=1; $(echo "$domo_stat" |awk '{sum+=$4} END{print sum}')/$cpu_num" |bc;;

    # awk the correct 'MEM(%)' column of domo_stat, sum this column.
    mem_percent)  echo "$domo_stat" |awk '{sum+=$6} END{print sum}';;

    mem_free)     echo $mem_free;;
    mem_used)     echo $mem_used;;
    *) echo $ERROR_WRONG_PARAM; exit 1;;
esac

exit 0
