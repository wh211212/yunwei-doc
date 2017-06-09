#!/bin/bash
# MD    2012-02-08      create the scrpit

### Error Code ###
# -0.9901 --- DNS is not work.
# -0.9902 --- dig command is not work.
#     0   --- DNS's status is ok.

#Binaries
DIG="/usr/bin/dig"
DOMAIN1="baidu.com"
DOMAIN2="google.com"

# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF="$CURRENT_DIR/../conf/nc_dns_check.conf"
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

###########
#check the dig command
###########
if [ ! -f "$DIG" -o ! -x "$DIG" ];then
   echo "-0.9902"
   exit 1
fi

BAIDU_COUNT=$($DIG $DOMAIN1  +short +time=1 | grep ^[0-9] |wc -l)
GOOGLE_COUNT=$($DIG $DOMAIN2  +short +time=1 | grep ^[0-9] | wc -l)

###########
#check the DNS status
###########
if [ "$BAIDU_COUNT" -gt 1 -a "$GOOGLE_COUNT" -gt 1 ]; then
   DNS_STAT="0"
 else
   DNS_STAT="-0.9901"
fi
case $1 in
 stat) echo $DNS_STAT;;
 *)  echo "-0.9903";;
esac