#!/bin/bash
##################################
# Zabbix monitoring script
#
# #!/bin/bash
##################################
# Zabbix monitoring script
#
# mpt-status:
#  - something important via mpt-status monitor SAS 6i/R
#
###################################
# Permission: Need sudo to run the hpacucli, add the following line with "visudo"
#    # zabbix user do not have a shell ??? command are initated by the agent
#    Defaults:zabbix !requiretty
#    Cmnd_Alias ZABBIX = /usr/bin/mpt-status
#    zabbix ALL = NOPASSWD: ZABBIX
###################################
##################################
# ChangeLog:
#  20120628    MD    initial creation
#  20120806    FC    correct the bin path
#  20140110    MD    fix count vg/vd/optimal/noline bugs
##################################
VERSION=1.0

# Megcli defaults
MPT_STATUS_BIN="/usr/bin/mpt-status"
LSPCI_BIN="/sbin/lspci"

# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF="$CURRENT_DIR/../conf/nc_raid-mptstatus_check.conf"
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
#if [ ! -x $MPT_STATUS_BIN -o ! -x $LSPCI_BIN ]; then
#    echo "-0.9901"
#    exit 1
#fi

# Load the module
sudo $MPT_STATUS_BIN --autoload > /dev/null 2>&1

# Get the various SCSI ids to query the RAID card on 
IDS=$(grep -B1 VIRTUAL /proc/scsi/scsi | grep Host | awk '{print $6}')
MPTSTATUS=
for id in $IDS
do
    ID_STATUS=$(sudo $MPT_STATUS_BIN -i $id)
    [ -z "$MPTSTATUS" ] && MPTSTATUS="$ID_STATUS" || MPTSTATUS="$MPTSTATUS"$'\n'"$ID_STATUS"
done

raid_check() {
    SEC_PARAM=$1
    # PRODUCT_NAME=$($LSPCI_BIN -v | grep -Ei -A1 '^[0-9]{2}:[0-9]{2}\.[0-9](.*)raid' | grep 'Subsystem' | awk -F': ' '{print $2}')
    PRODUCT_NAME=$($LSPCI_BIN -m | grep -i "bus controller" | awk -F'"' '{print $10}')
    COUNT_VG=$(echo "$MPTSTATUS" | grep -ic "vol_id")    #get vitrual group total number
    COUNT_VD=$(echo "$MPTSTATUS" | grep -iv "vol_id" | wc -l)     # get vitrual disks total number
    COUNT_OPTIMAL=$(echo "$MPTSTATUS" | grep -i "vol_id" | grep -Eic "state[[:space:]]*OPTIMAL")   # get vg 'optimal' status number
    COUNT_ONLINE=$(echo "$MPTSTATUS" | grep -iv "vol_id" | grep -Eic "state[[:space:]]*ONLINE")   # get vd 'online' status number

    # make sure can get value.
    if [ $COUNT_OPTIMAL -eq 0 -o $COUNT_ONLINE -eq 0 ];then
        echo "-0.9902"
        exit 1
    fi

    #check raid..
    if [ $COUNT_OPTIMAL -ne $COUNT_VG -o $COUNT_ONLINE -ne $COUNT_VD ]; then
        RAID_STATUS="RAID_ERROR";
    else
        RAID_STATUS="RAID_OK";
    fi

    case $SEC_PARAM in
        product_name   ) echo "$PRODUCT_NAME";;
        status         ) echo "$RAID_STATUS";;
        *              ) echo "-0.9904";;
    esac
}

case $1 in
    ""    ) echo "-0.9903";;
    raid  ) raid_check $2;;
    *     ) echo "-0.9905";;
esac
