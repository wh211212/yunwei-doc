#!/bin/bash
##################################
# Zabbix monitoring script
#
##################################
# Zabbix monitoring script
#
# sas2ircu:
#  - something important via sas2ircu
#
##################################
# Contact:
#  tracy.wang@chinanetcloud.com
##################################
# ChangeLog:
#  20110906    TW    initial creation
#  2012-02-13   CZ      add config file for override defaults
##################################
VERSION=1.0

# Sas2ircu Default
SAS2IRCU_BIN="/usr/sbin/sas2ircu"

# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF="$CURRENT_DIR/../conf/nc_raid-sas2ircu_check.conf"
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - items need to be of type "float" (allow negative + float)
#
ERROR_BIN="-0.9901" # Missing binary or bad permission
ERROR_DATA="-0.9902" # Cannot get the value

# check if binary exists and executable
if [ ! -x $SAS2IRCU_BIN ]; then
    echo $ERROR_BIN
    exit 1
fi

# save the sas2ircu stats in a variable for future parsing
SAS2IRCU_STATS="sudo $SAS2IRCU_BIN 0 DISPLAY"

# error during retrieve
if [ $? -ne 0 -o -z "$SAS2IRCU_STATS" ]; then
    echo $ERROR_DATA
    exit 1
fi

# main
if grep -q 'Okay' "$SAS2IRCU_STATS";  then
    echo "RAID_OK"
else
    echo "RAID_ERROR"
fi

exit 0
