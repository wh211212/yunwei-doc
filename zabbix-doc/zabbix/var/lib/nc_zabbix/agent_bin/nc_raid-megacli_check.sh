#!/bin/bash
##################################
# Zabbix monitoring script
#
# megacli-status:
#  - something important via megacli (For Perc 5+)
#
###################################
# Permission: Need sudo to run the hpacucli, add the following line with "visudo"
#    # zabbix user do not have a shell ??? command are initated by the agent
#    Defaults:zabbix !requiretty
#    Cmnd_Alias ZABBIX = /opt/MegaRAID/MegaCli/MegaCli64
#    zabbix ALL = NOPASSWD: ZABBIX
##################################
# ChangeLog:
#  20120628    MD    initial creation
#  20131227    MD    fixed raid State bug
#  20140113    MD    comment out unuse lines
##################################
VERSION=1.0

# Megcli defaults
MEGACLI_BIN="/opt/MegaRAID/MegaCli/MegaCli64"
LSPCI_BIN="/sbin/lspci"

# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF="$CURRENT_DIR/../conf/nc_raid-megacli_check.conf"
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - items need to be of type "float" (allow negative + float)
#
# -0.9901 --- Missing binary or bad permission
# -0.9902 --- Cannot get the value
# -0.9903 --- the first argument of this sub script is empty
# -0.9904 --- the second argument of this sub script is not found
# -0.9905 --- the first argument  is wrong

# check if binary exists and executable
if [ ! -x $MEGACLI_BIN ]; then
    echo "-0.9901"
    exit 1
fi

# save the megcli stats in a variable for future parsing
VIRTUAL_DISKS_STATS=$(sudo $MEGACLI_BIN -LDinfo -lall -aall -nolog)
RAID_STATS=$(sudo $MEGACLI_BIN -AdpAllInfo -aAll -nolog)

raid_check() {
    SEC_PARAM=$1
    # PRODUCT_NAME=$(echo "$RAID_STATS" | grep -i 'Product Name' | awk -F: '{print $2}')
    PRODUCT_NAME=$($LSPCI_BIN -m | grep -i "bus controller" | awk -F'"' '{print $10}')
    FW_VERSION=$(echo "$RAID_STATS" | grep -i 'FW Version' | awk -F': ' '{print $2}')
    RAID_CACHE=$(echo "$RAID_STATS" | grep -i 'Disk Cache Policy' | awk -F': ' '{print $2}')
    COUNT_RAID=$(echo "$VIRTUAL_DISKS_STATS" | grep -iEc "State[[:space:]]*:")
    COUNT_OPTIMAL=$(echo "$VIRTUAL_DISKS_STATS" | grep -iEc "State[[:space:]]*:[[:space:]]*Optimal")

    READ_AHEAD=$(echo "$VIRTUAL_DISKS_STATS" | grep -i 'Current Cache Policy' | awk -F', ' '{print $2}')
    # We may have several virtual disks - need to merge them all into 1 line
    if [ $(echo "$READ_AHEAD" | wc -l) -gt 1 ]; then
        OLD_IFS=$IFS 
        IFS=$'\n'
        MERGED_READ_AHEAD=
        for i in $READ_AHEAD
        do
            [ -z "$MERGED_READ_AHEAD" ] && MERGED_READ_AHEAD="$i" || MERGED_READ_AHEAD="$MERGED_READ_AHEAD,$i"
        done
        READ_AHEAD="$MERGED_READ_AHEAD"
        IFS=$OLD_IFS
    fi
    BATTERY_STATUS=$(echo "$VIRTUAL_DISKS_STATS" | grep -i 'Current Cache Policy' | awk -F', ' '{print $4}')
    # We may have several virtual disks - need to merge them all into 1 line
    if [ $(echo "$BATTERY_STATUS" | wc -l) -gt 1 ]; then
        OLD_IFS=$IFS 
        IFS=$'\n'
        MERGED_BATTERY_STATUS=
        for i in $BATTERY_STATUS
        do
            [ -z "$MERGED_BATTERY_STATUS" ] && MERGED_BATTERY_STATUS="$i" || MERGED_BATTERY_STATUS="$MERGED_BATTERY_STATUS,$i"
        done
        BATTERY_STATUS="$MERGED_BATTERY_STATUS"
        IFS=$OLD_IFS
    fi

    if [ $COUNT_OPTIMAL -eq 0 -o $COUNT_RAID -eq 0 ];then
        echo "-0.9902"
        exit 1
    fi

    if [ $COUNT_OPTIMAL -ne $COUNT_RAID ]; then
        RAID_STATUS="RAID_ERROR"
    else
        RAID_STATUS="RAID_OK"
    fi

    case $SEC_PARAM in
        product_name   ) echo "$PRODUCT_NAME";;
        status         ) echo "$RAID_STATUS";;
        fw_version     ) echo "$FW_VERSION";;
        cache          ) echo "$RAID_CACHE";;
        readahead      ) echo "$READ_AHEAD";;
        battery        ) echo "$BATTERY_STATUS";;
        *              ) echo "-0.9904";;
    esac
}

disk_check() {
    SEC_PARAM=$1
    DISK_CACHE=$(echo "$VIRTUAL_DISKS_STATS" | grep -i 'Disk Cache Policy' | awk -F': ' '{print $2}')
    # We may have several virtual disks - need to merge them all into 1 line
    if [ $(echo "$DISK_CACHE" | wc -l) -gt 1 ]; then
        OLD_IFS=$IFS 
        IFS=$'\n'
        MERGED_DISK_CACHE=
        for i in $DISK_CACHE
        do
            [ -z "$MERGED_DISK_CACHE" ] && MERGED_DISK_CACHE="$i" || MERGED_DISK_CACHE="$MERGED_DISK_CACHE,$i"
        done
        DISK_CACHE="$MERGED_DISK_CACHE"
        IFS=$OLD_IFS
    fi

    case $SEC_PARAM in
        cache          ) echo "$DISK_CACHE";;
        *              ) echo "-0.9904";;
    esac
}

case $1 in
    ""    ) echo "-0.9903";;
    raid  ) raid_check $2;;
    disk  ) disk_check $2;;
    *     ) echo "-0.9905";;
esac
