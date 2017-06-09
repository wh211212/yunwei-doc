#!/bin/bash
##################################
# Zabbix monitoring script
#
# Zookeeper
#  - anything available via zookeeper four letter words
#
# Allowed parameters combinaisons:
#  - echo $param | nc listening IP + port
##################################
# Contact:
#  tina.zhang@chinanetcloud.com
##################################
# ChangeLog:
#  20150722    TZ    initial creation
##################################

Version=1.0

# Binaries define
NC="/usr/bin/nc"

# Default Zookeeper IP & Port
ZK_DEFAULT_IPADDR="127.0.0.1"
ZK_DEFAULT_PORT="2181"

# Zabbix requested parameter
ZBX_REQ_DATA="$1"
ZBX_REQ_DATA_SOURCE="$2"
ZK_IPADDR="$3"
ZK_PORT="$4"

# source data file
ZABBIX_BASE_DIR=`readlink -f $( dirname $(dirname $0) )`

# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF=$CURRENT_DIR/../conf/nc_zookeeper_check.conf
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - numeric items need to be of type "float" (allow negative + float)
#
ERROR_DATA="-0.9901"
ERROR_WRONG_PARAM="-0.9902"

# Assign default IP & port if doesn't exist
if [ -z $ZK_IPADDR ]; then
  ZK_IPADDR="$ZK_DEFAULT_IPADDR"
fi

if [ -z $ZK_PORT ]; then
  ZK_PORT="$ZK_DEFAULT_PORT"
fi

# Check if zabbix can execute nc command
TEST=$(echo stat | $NC $ZK_IPADDR $ZK_PORT 2>&1 > /dev/null)
if [ $? != 0 ];then
  echo $ERROR_DATA
  exit 1
fi

check_stat(){
ZBX_REQ_DATA_SOURCE=$1

case $ZBX_REQ_DATA_SOURCE in
  version)      echo stat | $NC $ZK_IPADDR $ZK_PORT | grep version | awk '{ print $2$3 }' | awk -F"," '{ print $1 }' ;;
  mode)         echo stat | $NC $ZK_IPADDR $ZK_PORT | grep Mode | awk '{ print $2 }' ;;
  znode_count)  echo stat | $NC $ZK_IPADDR $ZK_PORT | grep Node | awk '{ print $3 }' ;;
  latency_min)  echo stat | $NC $ZK_IPADDR $ZK_PORT | grep Latency | awk '{ print $3 }' | awk -F"/" '{ print $1 }' ;;
  latency_avg)  echo stat | $NC $ZK_IPADDR $ZK_PORT | grep Latency | awk '{ print $3 }' | awk -F"/" '{ print $2 }' ;;
  latency_max)  echo stat | $NC $ZK_IPADDR $ZK_PORT | grep Latency | awk '{ print $3 }' | awk -F"/" '{ print $3 }' ;;
  packest_received) echo stat | $NC $ZK_IPADDR $ZK_PORT | grep Received | awk '{ print $2 }' ;;
  packest_sent)  echo stat | $NC $ZK_IPADDR $ZK_PORT | grep Sent | awk '{ print $2 }' ;;
  requests_outstandind) echo stat | $NC $ZK_IPADDR $ZK_PORT | grep Outstanding | awk '{ print $2 }' ;;
  *)            echo $ERROR_WRONG_PARAM ;;
esac

}

check_wchs(){
ZBX_REQ_DATA_SOURCE=$1

case $ZBX_REQ_DATA_SOURCE in
  watch_connections)  echo wchs | $NC $ZK_IPADDR $ZK_PORT | grep connections | awk '{ print $1 }' ;;
  watch_paths)        echo wchs | $NC $ZK_IPADDR $ZK_PORT | grep paths | awk '{ print $4 }' ;;
  total_watches)      echo wchs | $NC $ZK_IPADDR $ZK_PORT | grep Total | awk -F":" '{ print $2 }' ;;
  *)                  echo $ERROR_WRONG_PARAM ;;
esac

}

## Main ##
case $ZBX_REQ_DATA in
  ruok)   echo ruok | $NC $ZK_IPADDR $ZK_PORT ;;
  conf)   echo conf | $NC $ZK_IPADDR $ZK_PORT | grep $2 | awk -F"=" '{ print $2 }' ;;
  mntr)   echo mntr | $NC $ZK_IPADDR $ZK_PORT | grep $2 | awk '{ print $2 }' ;;
  stat)   check_stat $2 ;;
  wchs)   check_wchs $2 ;;
  *)      echo $ERROR_WRONG_PARAM ;;
esac
