#!/bin/bash
#####################################################
# Zabbix monitoring script
#
#
#####################################################
# Contact:
#  tina.zhang@chinanetcloud.com
#####################################################
# ChangeLog:
#  20160320    TZ    initial creation
#####################################################

# Zabbix requested parameter
CONTAINER_NAME="$1"
ZBX_REQ_DATA="$2"
ZBX_REQ_DATA_SOURCE="$3"

# Nginx defaults
DOCKER_BIN=$(which docker)

# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF="$CURRENT_DIR/../conf/nc_docker_check.conf"
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - items need to be of type "float" (allow negative + float)
#
ERROR_NO_ACCESS_FILE="-0.9900"
ERROR_NO_ACCESS="-0.9901"
ERROR_WRONG_PARAM="-0.9902"
ERROR_DATA="-0.9903" 

SPACE_STATUS=$(sudo $DOCKER_BIN exec -t $CONTAINER_NAME df -h | grep '^/dev' | tr -d '\r' | grep "$ZBX_REQ_DATA$")
INODE_STATUS=$(sudo $DOCKER_BIN exec -t $CONTAINER_NAME df -i | grep '^/dev' | tr -d '\r' | grep "$ZBX_REQ_DATA$")

if [ $? -ne 0 -o -z "$SPACE_STATUS" ]; then
    echo $ERROR_DATA
    exit 1
fi

case $ZBX_REQ_DATA_SOURCE in
    pused)         echo "$SPACE_STATUS" | awk '{ print $5 }' | tr -d '%' ;; 
    total_size)    echo "$SPACE_STATUS" | awk '{ print $2 }' ;; 
    inode_pused)   echo "$INODE_STATUS" | awk '{ print $5 }' ;; 
    *)             echo $ERROR_WRONG_PARAM; exit 1;;
esac
