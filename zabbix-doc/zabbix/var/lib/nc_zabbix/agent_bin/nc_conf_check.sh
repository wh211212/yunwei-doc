#!/bin/bash
##################################
# Zabbix monitoring script
#
# track config:
#  - sudo diff config file version
#
# Info:
#  - backup and sudo diff config file we care
# ###############################
# Requirement : sudo
# Cmnd_Alias ZABBIX = /usr/bin/find, /bin/cp, /usr/bin/diff
##################################
# Contact:
#  tracy.wang@chinanetcloud.com
##################################
# ChangeLog:
#  20110601     TW      Initial
##################################

VERSION=1.0

# Zabbix requested parameter
ZBX_REQ_DATA="$1"

# Source Data File
ZABBIX_BASE_DIR=`readlink -f $( dirname $(dirname $0) )`
SOURCE_DATA_DIR=$ZABBIX_BASE_DIR/tmp/config

# Binary Define
DIFF_BIN="/usr/bin/diff"

# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF="$CURRENT_DIR/../conf/nc_conf_check.conf"
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - items need to be of type "float" (allow negative + float)
#
ERROR_NO_SUCH_CONFIG_LIST="-0.9900"
ERROR_OLD_DATA="-0.9901"
ERROR_WRONG_PARAM="-0.9902"


# config folder define
CONFIG_LIST=("/etc" "")

# source config file
#CONFIG_FILES=("$(find $CONFIG_FOLDER -name *.conf | tr '\n' ' ')")

# check if the folder exists
for I in ${CONFIG_LIST[*]}
do
    if [ ! -d "$I" ] && [ ! -f "$I" ]; then
          echo "-0.9900"
          exit 1
    fi
done

if [ ! -d "$SOURCE_DATA_DIR" ]; then
  mkdir -p "$SOURCE_DATA_DIR"
fi

# do a loop check if any config-file has been changed
STR=""
STATS=0
for I in ${CONFIG_LIST[*]}
do
    if [ -d $I ]; then
        CONFIG_FILES=("$(sudo find $I \( -name *.conf -o -name *.cnf \)  | tr '\n' ' ')")
    #        CONFIG_FILES=$CONFIG_FILES'("$(find $I -name *.cnf | tr '\n' ' ')")'
        for J in ${CONFIG_FILES[*]}
        do
            BAK_ID1="$(echo $J | tr '/' '_')"
            if [ ! -f "$SOURCE_DATA_DIR"/"$BAK_ID1".tmp ]; then
                sudo cp "$J" "$SOURCE_DATA_DIR"/"$BAK_ID1".tmp
            fi

            if sudo $DIFF_BIN "$J" "$SOURCE_DATA_DIR"/"$BAK_ID1".tmp > /dev/null; then 
                :
            else
                STR="$J, $STR"
                sudo cp "$SOURCE_DATA_DIR"/"$BAK_ID1".tmp{,.$(date +%Y%m%d-%H%M)}
                sudo cp "$J" "$SOURCE_DATA_DIR"/"$BAK_ID1".tmp
            fi
        done
    else
        BAK_ID2="$(echo $I | tr '/' '_')"
        if [ ! -f "$SOURCE_DATA_DIR"/"$BAK_ID2".tmp ]; then
            sudo cp "$I" "$SOURCE_DATA_DIR"/"$BAK_ID2".tmp
        fi

        if sudo $DIFF_BIN "$I" "$SOURCE_DATA_DIR"/"$BAK_ID2".tmp > /dev/null; then
                :
        else
        STR="$I, $STR"
        sudo cp "$SOURCE_DATA_DIR"/"$BAK_ID2".tmp{,.$(date +%Y%m%d-%H%M)}
        sudo cp "$I" "$SOURCE_DATA_DIR"/"$BAK_ID2".tmp
        fi
    fi
done

if [ -z $STR ]; then
    echo "No Changes"
else
    echo "$STR"
fi

