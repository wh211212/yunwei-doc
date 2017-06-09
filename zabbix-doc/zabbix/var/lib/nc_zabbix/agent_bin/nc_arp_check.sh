#!/bin/bash
##################################
# Zabbix monitoring script
#
# arp:
#  - monitor default gw arp
#
##################################
# Contact:
#  daniel.lin@chinanetcloud.com
##################################
# ChangeLog:
#  20100831    DL      initial creation
#  20110212    DL    restructure the script, add binary check and data check
##################################
VERSION=1.0

# Zabbix requested parameter
ZBX_REQ_DATA="$1"

# ARP,IP defaults
ARP_BIN="/sbin/arp"
IP_BIN="/sbin/ip"

# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF="$CURRENT_DIR/../conf/nc_arp_check.conf"
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF
#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - items need to be of type "float" (allow negative + float)
#
ERROR_GW_IP="-0.9901" # error when retrieving the gw ip
ERROR_WRONG_PARAM="-0.9902"
ERROR_PING="-0.9903"  # error when flush arp cache
ERROR_MAC_GW="-0.9904"  # error when retrieving the gw mac

# retrieve the gw ip
GW_IP=$( $IP_BIN route | awk '/^default/ {print $3}' )

# error during retrieve
if [ $? -ne 0 -o -z "$GW_IP" ]; then
  echo $ERROR_GW_IP
  exit 1
fi

# flush arp cache
ping -c3 $GW_IP >&/dev/null

# error during flush
if [ $? -ne 0 ]; then
  echo $ERROR_PING
  exit 1
fi

# retrive the gw mac
MAC_GW=$( $ARP_BIN -a $GW_IP | awk '{print $4}' )

# error during retrieve
if [ $? -ne 0 ]; then
  echo $ERROR_MAC_GW
  exit 1
fi

# rewrite gw mac to num oct
MAC_GW_CHK=$( echo "ibase=16;obase=A;${MAC_GW//:/}" | bc )

case "$ZBX_REQ_DATA" in                
    gw_chksum) echo $MAC_GW_CHK;;
    gw     ) echo "$MAC_GW";;
    *     )  echo $ERROR_WRONG_PARAM; exit 1;;
esac

exit 0
