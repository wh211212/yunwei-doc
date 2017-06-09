#!/bin/bash
###################################
# Simple script to analyze Raid Status on LSI Raid Card
# THe logic has to be implemented locally and be failure proof !!
# The OUTPUT is what the zabbix_agent will return to the server
###################################
# Permission: Need sudo to run the hpacucli, add the following line with "visudo"
#    # zabbix user do not have a shell ??? command are initated by the agent
#    Defaults:zabbix !requiretty
#    Cmnd_Alias ZABBIX = /usr/sbin/hpacucli
#    zabbix ALL = NOPASSWD: ZABBIX
###################################
# Version: 1.0
# 20120701 MD  initial creation
# 20140217 MD  add raid status more check opts and optmize status funcions.

# -0.9901 --- Missing binary or bad permission
# -0.9902 --- Cannot get the value
# -0.9903 --- the first argument of this sub script is empty
# -0.9904 --- the second argument of this sub script is not found
# -0.9905 --- the first argument  is wrong


HPACUCLI_BIN="/usr/sbin/hpacucli"
LSPCI_BIN="/sbin/lspci"

# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF="$CURRENT_DIR/../conf/nc_raid-hpacucli_check.conf"
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

# check if binary exists and executable
if [ ! -x $HPACUCLI_BIN ]; then
    echo "-0.9901"
    exit 1
fi

############################SLOT_NUMBER
# save the hpacucli stats in a variable for future parsing
################
RAID_STATS=$(sudo $HPACUCLI_BIN ctrl all show config)
COUNT_DRIVE=$(echo "$RAID_STATS" | grep -ic "physicaldrive")
COUNT_DRIVE_OK=$(echo "$RAID_STATS" | grep -i "physicaldrive" | grep -ic " OK")
COUNT_VG=$(echo "$RAID_STATS" | grep -ic 'raid ')
COUNT_VG_OK=$(echo "$RAID_STATS" | grep -i 'raid ' | grep -ic " OK")

# error during retrieve
if [ $COUNT_DRIVE_OK -eq 0 -o $COUNT_VG_OK -eq 0 ]; then
    echo "-0.9902"
    exit 1
fi

stat_check() {
    # Return status
    if [ $COUNT_DRIVE -ne $COUNT_DRIVE_OK -o $COUNT_VG -ne $COUNT_VG_OK ]; then
        IS_REBUILDING=$(echo "$RAID_STATS" | grep -c "Rebuilding")
        if [ $IS_REBUILDING -gt 0 ]; then
            RAID_STATUS="RAID_REBUILDING"
        else
            RAID_STATUS="RAID_ERROR"
        fi
    else
        RAID_STATUS="RAID_OK"
    fi

    echo $RAID_STATUS
}

raid_check() {
    SEC_PARAM=$1
    if [ $SEC_PARAM == 'status' ];then
        stat_check
        exit
    fi

    RAID_DETAIL_STATS=$(sudo $HPACUCLI_BIN ctrl all show config detail)
    # PRODUCT_NAME=$(echo "$RAID_DETAIL_STATS" | grep -im1 'Interface Type' | awk -F': ' '{print $2}')
    PRODUCT_NAME=$($LSPCI_BIN -m | grep -i "bus controller" | awk -F'"' '{print $10}')
    FW_VERSION=$(echo "$RAID_DETAIL_STATS" | grep -im1 'Firmware Version' | awk -F': ' '{print $2}')
    RAID_CACHE=$(echo "$RAID_DETAIL_STATS" | grep -i 'Cache Status' | awk -F': ' '{print $2}')
    RAID_AHEAD=$(echo "$RAID_DETAIL_STATS" | grep -i 'Accelerator Ratio' | awk -F': ' '{print $2}')
    BATTERY_STATUS=$(echo "$RAID_DETAIL_STATS" | grep -i 'No-Battery Write Cache' | awk -F': ' '{print $2}')

    case $SEC_PARAM in
        product_name   ) echo "HP - $PRODUCT_NAME";;
        fw_version     ) echo "$FW_VERSION";;
        cache          ) echo "$RAID_CACHE";;
        readahead      ) echo "$RAID_AHEAD";;
        battery        ) echo "$BATTERY_STATUS";;
        *              ) echo "-0.9904";;
    esac
}

disk_check() {
    SEC_PARAM=$1
    RAID_DETAIL_STATS=$(sudo $HPACUCLI_BIN ctrl all show config detail)
    DISK_CACHE=$(echo "$RAID_DETAIL_STATS" | grep 'Drive Write Cache' | awk -F: '{print $2}')

    case $SEC_PARAM in
        cache  ) echo "$DISK_CACHE";;
        *      ) echo "-0.9904";;
    esac
}

case $1 in
    ""    ) echo "-0.9903";;
    raid  ) raid_check $2;;
    disk  ) disk_check $2;;
    *     ) echo "-0.9905";;
esac
