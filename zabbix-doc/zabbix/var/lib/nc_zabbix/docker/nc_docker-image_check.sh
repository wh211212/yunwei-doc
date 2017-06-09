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
#  20161116    TZ    initial creation
#####################################################

# Zabbix requested parameter
ZBX_REQ_PARAS="$1"

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
ERROR_WRONG_PARAM="-0.9901"
ERROR_DATA="-0.9902"

run_cmd(){
  CMD="$1"
  result=$(eval $CMD 2>/dev/null)

  if [ $? -ne 0 ]; then
    echo $ERROR_DATA
    exit 1
  elif [ -z "$result" ]; then
    echo "Images list is empty"
  else
    echo "$result"
  fi
}

case $ZBX_REQ_PARAS in
    all)         run_cmd "sudo $DOCKER_BIN images --all" ;;
    normal)      run_cmd "sudo $DOCKER_BIN images --filter \"dangling=false\" | grep -v '^<none>.*<none>'" ;;
    dangling)    run_cmd "sudo $DOCKER_BIN images --filter \"dangling=true\"" ;;
    *)             echo $ERROR_WRONG_PARAM; exit 1;;
esac
