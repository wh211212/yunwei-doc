#!/bin/bash
###########################################
# Zabbix monitoring script     
#
# mountedfs:
#  - Checking current mounted filesystem 
#
###########################################
# Contact:
#  cecil.han@chinanetcloud.com
###########################################
# ChangeLog:
#  20110212    CH    Format to NC standard
###########################################

# Zabbix requested parameter
#ZBX_REQ_DATA="$1"  # NULL for this script, just comment

# mountedfs defaults
MOUNT_BIN="/bin/mount"

#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - items need to be of type "float" (allow negative + float)
#
ERROR_NO_ACCESS_FILE="-0.9900"
ERROR_NO_ACCESS="-0.9901"
ERROR_WRONG_PARAM="-0.9902"
ERROR_DATA="-0.9903" # either can not connect / bad host / bad port

# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF=$CURRENT_DIR/../conf/nc_mountedfs_check.conf
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

# save the mountedfs stats in a variable for future parsing
MOUNTEDFS_STATUS=$($MOUNT_BIN | grep -E '^/' | grep -E '[\(|,]rw[,|\)$]' | grep -vi snapshot | awk '{printf $3":"}')

echo "$MOUNTEDFS_STATUS"

exit 0
