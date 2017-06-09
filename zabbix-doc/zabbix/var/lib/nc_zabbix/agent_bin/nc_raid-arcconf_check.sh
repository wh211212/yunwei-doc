#!/bin/bash
##################################
# Zabbix monitoring script
#
# #!/bin/bash
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
#    Cmnd_Alias ZABBIX = /opt/cmdline/arcconf
#    zabbix ALL = NOPASSWD: ZABBIX
##################################
# ChangeLog:
#  20120628    MD    initial creation
##################################
VERSION=1.0

# Arcconf defaults
ARRCONF_BIN="/opt/cmdline/arcconf"

# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF="$CURRENT_DIR/../conf/nc_raid-arcconf_check.conf"
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
if [ ! -x $ARRCONF_BIN ]; then
    echo "-0.9901"
    exit 1
fi

# save the megcli stats in a variable for future parsing
VIRT_DISKS_STATS=$(sudo $ARRCONF_BIN GETCONFIG 1 LD)
PHYS_DISKS_STATS=$(sudo $ARRCONF_BIN GETCONFIG 1 PD)
RAID_STATS=$(sudo $ARRCONF_BIN GETCONFIG 1)

raid_check() {
    SEC_PARAM=$1
    PRODUCT_NAME=$(echo "$RAID_STATS" | grep -i 'Controller Model' | awk -F': ' '{print $2}')
    FW_VERSION=$(echo "$RAID_STATS" | grep -i 'Firmware' | head -n 1 | awk -F': ' '{print $2}')
    RAID_CACHE=$(echo "$RAID_STATS" | grep 'Write-cache status' | awk -F': ' '{print $2}')
    COUNT_OPTIMAL=$( echo "$RAID_STATS" | grep -c "Segment")
    READ_AHEAD=$(echo "$VIRT_DISKS_STATS" | grep -m1 'Current Cache Policy' | awk -F', ' '{print $2}')
    COUNT_RAID=$( echo "$RAID_STATS" | grep -Ec "State[[:space:]]*:[[:space:]]*Online" )

    if [ $COUNT_RAID -eq 0 -o $COUNT_OPTIMAL -eq 0 ];then
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
        *              ) echo "-0.9904";;
    esac
}

disk_check() {
    SEC_PARAM=$1
    DISK_CACHE=$(echo "$VIRT_DISKS_STATS" | grep -i 'Status of logical device' | awk -F': ' '{print $2}')

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

