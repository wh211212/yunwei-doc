#!/bin/bash
# Mick.duan    Mick.duan@chinanetcloud.com
# MD    2011-10-31      create the scrpit
# MD    2013-01-23      update

### Error Code ###
# -0.9901 --- /sbin/ipvsadm does not exist or no permission
# -0.9902 --- the file from cron job was not updated
# -0.9903 --- the first argument of this sub script is empty
# -0.9904 --- the second argument of this sub script is not found
# -0.9905 --- the folder permission is not correct
# -0.9906 --- the third argument of this sub script is not found
# -0.9907 --- there is some nodes doesn't work.

# The script is used to monitor the LVS status

version=1.0.0

IPVSADM_BIN="/sbin/ipvsadm"
KEEPALIVED_BIN="/usr/sbin/keepalived"
IP_BIN="/sbin/ip"
KEEPALIVED_FILE="/etc/keepalived/keepalived.conf"
lvs_ipvsadm_list="sudo $IPVSADM_BIN -ln"

# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF=$CURRENT_DIR/../conf/nc_lvs_check.conf
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

### Function ###
check_return(){
  if [ $? -ne 0 ]; then
    echo "$1"
    exit 1
  fi
}

# check if the file from cron job exists
if [ ! -x "$IPVSADM_BIN" -o ! -x "$IP_BIN" -o ! -f "$KEEPALIVED_FILE" ]; then
  echo  "-0.9901"
  exit
fi

version_status() {
  case $1 in
    ""  ) echo "-0.9903";;
    keepalived ) echo -n "$($KEEPALIVED_BIN -v)";;
    ipvsadm ) echo $($IPVSADM_BIN --version |awk '{print $2}');;
    *       ) echo "-0.9904";;
  esac
}



check_stat(){
  FRT_PART=$1
  SED_PART=$2
  if [  -z "$FRT_PART" -o  -z "$SED_PART" ]; then
    echo "-0.9903"
    exit 1
  fi

  CONFIG_REAL_LIST=$(cat $KEEPALIVED_FILE |grep -i 'real_server'|awk '{print $2":"$3}' )
  SYSTEM_REAL_LIST=$(echo "$(sudo $IPVSADM_BIN -ln)" |grep 'Route'|grep "$FRT_PART" )
  
  echo "$SYSTEM_REAL_LIST" |grep "$FRT_PART" >/dev/null
  if [ $? -eq 0 ];then
    LVS_STATUS="up"
  else 
    LVS_STATUS="down"
  fi 

  case $SED_PART in
    ""  ) echo "-0.9903";;
    activeconn  ) echo "$SYSTEM_REAL_LIST" | grep -m1 "$FRT_PART" |awk '{print $4}';;
    inactconn  ) echo "$SYSTEM_REAL_LIST" | grep -m1 "$FRT_PART" |awk '{print $5}';;
    stat  ) echo "$LVS_STATUS";;
    *  ) echo "-0.9904";;
  esac
}


case $1 in
    ""   ) echo "-0.9903";;
    stat ) check_stat $2 $3;;
    version ) version_status $2;;
    *    ) echo "-0.9904";;
esac