#!/bin/bash
######################
# DNS checking
#
# Check the entries of the /etc/resolv.conf
# and ensure the DNS are valid and able to answer
#
# Checks are performed either by dig
#
######################

# Apply defaults
DIG=dig
DEFAULT_DOMAIN=baidu.com

DOMAIN="$1"

# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF=$CURRENT_DIR/../conf/nc_resolvconf_check.conf
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

# Check either custom domain, or use config file, or use default... 
if [ -z "$DOMAIN" -o "$DOMAIN" == 'default' ]; then
    DOMAIN=$DEFAULT_DOMAIN
fi

DNS_HOSTS=$(grep -vE '^.*#' /etc/resolv.conf | grep nameserver | cut -f2 -d' ')
ERRORS=

# Ensure we have dig available
$DIG -v > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "ERROR: dig unavailable"
    exit 1
fi

# Process each host available in the host list
for h in $DNS_HOSTS
do
    # echo "Processing $h"
    $DIG +time=1 @$h $DOMAIN > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        ERRORS="$ERRORS $h"
    fi
done

if [ ! -z "$ERRORS" ]; then
    # We have errors in at least one of the DNS records
    echo "ERROR:$ERRORS"
else
    echo "OK"
fi