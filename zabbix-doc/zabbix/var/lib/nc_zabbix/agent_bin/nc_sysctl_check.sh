#/bin/bash
##################################
# Zabbix monitoring script
#
# kernel VS sysctl value :
#  - Monitoring if the running kernel value is different with sysctl in config
#
##################################
# Contact:
#  tina.zhang@chinanetcloud.com
##################################
# ChangeLog:
#  20150411     TZ      initial creation
##################################
# Configuration file
CURRENT_DIR=$(readlink -f $(dirname $0))
SYSCONF="/etc/sysctl.conf"

# Binary
SYSCTL="/sbin/sysctl"
SORT="/bin/sort"
CUT="/bin/cut"
UNIQ="/usr/bin/uniq"
CAT="/bin/cat"

# Temporary files
TMP_LIST="$CURRENT_DIR/../tmp/tmp.list"
SORT_TMP_LIST="$CURRENT_DIR/../tmp/sort.tmp.list"

# Override defaults from config file
SCRIPT_CONF=$CURRENT_DIR/../conf/nc_kernel-sys_check.conf
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - numeric items need to be of type "float" (allow negative + float)
#
ERROR_NO_CONFIG_FILE="-0.9901"
ERROR_NO_ACCESS="-0.9902"
ERROR_NO_CMD_PERMISSIOM="-0.9903"

# Check for sysctl config
if [ ! -f $SYSCONF ]; then
  echo $ERROR_NO_CONFIG_FILE
  exit 1
fi

# Check if configuration file is readable
if [ ! -r "$SYSCONF" ];then
  CAT="sudo $CAT"
  if [ $(sudo $TEST -r "SYSCONF") ];then
    echo $ERROR_NO_ACCESS
    exit 1
  fi
fi

## Test user zabbix's permission for sudo the CMD
SUDO_LIST=$(sudo -l | grep NOPASSWD | awk -F ':' '{print $2}' | tr -d ' ')
if [ "$SUDO_LIST" != "ALL" ] && [ $(echo "$SUDO_LIST" | grep -c "$SYSCTL") -lt 1 ];then
    echo $ERROR_NO_CMD_PERMISSIOM
    exit 1
fi

# Get the list of current kernel value and sys config
sudo $SYSCTL -a > $TMP_LIST
$CAT $SYSCONF | grep -v ^# | sed '/^[[:space:]]*$/d' | sed 's/ //g' | sed 's/\=/ = /g' >> $TMP_LIST

# Sort the paratemeters
$SORT $TMP_LIST > $SORT_TMP_LIST
 
# Get the number for same paratemeters name
NUMBER1=$($CUT -d ' ' -f 1 $SORT_TMP_LIST | $UNIQ -d | wc -l)
# Get the number for same paratemeter name and value
NUMBER2=$($CAT $SORT_TMP_LIST | $UNIQ -d | wc -l)

# Output the different value
D_VALUE=$(($NUMBER1 - $NUMBER2))
echo $D_VALUE
