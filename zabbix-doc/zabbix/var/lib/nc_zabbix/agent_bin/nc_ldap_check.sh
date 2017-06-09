#!/bin/bash
##################################
# Zabbix monitoring script
#
# ldap:
#  - anything available via check_ldap_slurpd_status.pl
#
# https://ltb-project.org/svn/nagios-plugins/trunk/check_ldap_slurpd_status.pl
#
# info: 
#  - require sudo enabled for check_ldap_slurpd_status
#
##################################
# Contact:
#  vincent.viallet@chinanetcloud.com
##################################
# ChangeLog:
#  20110212    VV    review
##################################

version=1.0.0

# Zabbix requested parameter
ZBX_REQ_DATA="$1"
ZBX_REQ_DATA_URL="$2"

# define PATH for slurpd status perl script
LDAP_STATUS_BIN=/usr/local/sbin/check_ldap_slurpd_status.pl

HOST=srv-nc-ldap2.chinanetcloud.com
PORT=389

# Source configuration file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF=$CURRENT_DIR/../conf/nc_ldap_check.conf
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF


##############################################3
# Normal Output
# 0 entries in transition, 0 entries rejected, 0 entries waiting


#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - items need to be of type "float" (allow negative + float)
#
ERROR_NO_ACCESS_FILE="-0.9900"
ERROR_NO_ACCESS="-0.9901"
ERROR_WRONG_PARAM="-0.9902"
ERROR_BAD_CONFIG="-0.9903"
ERROR_DATA="-0.9904" # either can not connect /    bad host / bad port


# perform check
if [ -z "$HOST" -o -z "$PORT" ]; then
    echo $ERROR_BAD_CONFIG;
    exit 1
fi

# get status
LDAP_STATUS=$(sudo $LDAP_STATUS_BIN -w 100,5,30 -c 200,10,60 -h $HOST -p $PORT)

# error during retrieve
if [ $? -ne 0 -o -z "$LDAP_STATUS" ]; then
  echo $ERROR_DATA
  exit 1
fi

# 
# Extract data from ldap_status
#
case $ZBX_REQ_DATA in                
    transition) echo $LDAP_STATUS | awk '{print $1}';;
    rejected)   echo $LDAP_STATUS | awk '{print $5}';;
    waiting)    echo $LDAP_STATUS | awk '{print $8}';;
    *)          echo $ERROR_WRONG_PARAM; exit 1;;
esac

exit 0

