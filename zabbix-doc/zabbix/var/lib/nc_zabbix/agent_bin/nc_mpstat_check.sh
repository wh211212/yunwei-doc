#!/bin/bash
##################################
# Zabbix monitoring script
#
# mpstat:
#  - stats per CPU
#  - 1st param, top / avg -- capture either the avg over all CPU or the top value of all CPU
#  - 2nd param, item (either one of usr, nice, sys, iowait, irq, soft, steal, guest, idle)
#
# Info:
#  - mpstat data are gathered via cron job
##################################
# Contact:
#  vincent.viallet@gmail.com
##################################
# ChangeLog:
#  20130204    VV    initial creation
##################################
VERSION=1.0

# Zabbix requested parameter
ZBX_REQ_TYPE="$1"
ZBX_REQ_DATA="$2"

# source data file
ZABBIX_BASE_DIR=`readlink -f $( dirname $(dirname $0) )`
SOURCE_DATA=$ZABBIX_BASE_DIR/tmp/zabbix_mpstat

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

if [ -z "ZBX_REQ_TYPE" -o -z "ZBX_REQ_DATA" ]; then
    echo $ERROR_WRONG_PARAM
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
if [ $ZBX_REQ_TYPE == 'avg' ]; then
    # Fetch data from CPU avg (1st line)
    case $ZBX_REQ_DATA in
        usr)      head -1 $SOURCE_DATA | awk '{print $3}';;
        nice)     head -1 $SOURCE_DATA | awk '{print $4}';;
        sys)      head -1 $SOURCE_DATA | awk '{print $5}';;
        iowait)   head -1 $SOURCE_DATA | awk '{print $6}';;
        irq)      head -1 $SOURCE_DATA | awk '{print $7}';;
        soft)     head -1 $SOURCE_DATA | awk '{print $8}';;
        steal)    head -1 $SOURCE_DATA | awk '{print $9}';;
        guest)    head -1 $SOURCE_DATA | awk '{print $10}';;
        idle)     head -1 $SOURCE_DATA | awk '{print $11}';;
        *) echo $ERROR_WRONG_PARAM; exit 1;;
    esac
else 
    # Fetch data from the CPU specific lines, min or max define the sort order
    case $ZBX_REQ_TYPE in
        max) SORT='head -1';;
        min) SORT='tail -1';;
        *) echo $ERROR_WRONG_PARAM; exit 1;;
    esac
    
    case $ZBX_REQ_DATA in
        usr)      cat $SOURCE_DATA | sed -e '1d' | awk '{print $3}' | sort -nr | $SORT;;
        nice)     cat $SOURCE_DATA | sed -e '1d' | awk '{print $4}' | sort -nr | $SORT;;
        sys)      cat $SOURCE_DATA | sed -e '1d' | awk '{print $5}' | sort -nr | $SORT;;
        iowait)   cat $SOURCE_DATA | sed -e '1d' | awk '{print $6}' | sort -nr | $SORT;;
        irq)      cat $SOURCE_DATA | sed -e '1d' | awk '{print $7}' | sort -nr | $SORT;;
        soft)     cat $SOURCE_DATA | sed -e '1d' | awk '{print $8}' | sort -nr | $SORT;;
        steal)    cat $SOURCE_DATA | sed -e '1d' | awk '{print $9}' | sort -nr | $SORT;;
        guest)    cat $SOURCE_DATA | sed -e '1d' | awk '{print $10}' | sort -nr | $SORT;;
        idle)     cat $SOURCE_DATA | sed -e '1d' | awk '{print $11}' | sort -nr | $SORT;;
        *) echo $ERROR_WRONG_PARAM; exit 1;;
    esac
fi

exit 0
