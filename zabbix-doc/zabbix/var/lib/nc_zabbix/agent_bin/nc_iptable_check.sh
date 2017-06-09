#!/bin/bash
#####################################################

# Zabbix requested parameter
ZBX_REQ_DATA="$1"

# Iptable-save bin and Tmp history
IPTABLE_SAVE_BIN="/sbin/iptables-save"
IPTABLES_SAVE_FILE="/var/lib/nc_zabbix/tmp/iptables-save"
IPTABLE_HISTORY="/etc/sysconfig/iptables"

#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - items need to be of type "float" (allow negative + float)
#
ERROR_NO_ACCESS_FILE="-0.9900"
ERROR_NO_ACCESS="-0.9901"
ERROR_WRONG_PARAM="-0.9902"
ERROR_DATA="-0.9903" # either can not connect /    bad host / bad port

# check for existing tmp history - creates it
if [ ! -f $IPTABLES_SAVE_FILE ]; then
   $IPTABLE_SAVE_BIN > $IPTABLES_SAVE_FILE
fi

Sub_Check=`diff $IPTABLES_SAVE_FILE $IPTABLE_HISTORY | grep "< \-A\|< \-I"|wc -l`
echo $Sub_Check
