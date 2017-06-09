#!/bin/bash
#####################################################
# Zabbix monitoring script
#
# Docker contianer process status:
#  - Get the process via command 'docker exec -i {$container_name}'
#  - Get the PID via command 'pidof'
#  - Get the process status via command 'ps'
#
#####################################################
# Contact:
#  tina.zhang@chinanetcloud.com
#####################################################
# ChangeLog:
#  20160419    TZ    initial creation
#####################################################

# Zabbix requested parameter
ZBX_REQ_CONTAINER_NAME="$1"
ZBX_REQ_PRO_NAME="$2"
ZBX_REQ_PRO_USER_NAME="$3"
ZBX_REQ_PRO_CMDLINE="$4"

DOCKER_BIN=$(which docker)

DOCKER_COMMAND="sudo $DOCKER_BIN exec -i $ZBX_REQ_CONTAINER_NAME "

# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF="$CURRENT_DIR/../conf/nc_docker_container-process_check.conf"
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - items need to be of type "float" (allow negative + float)
#
ERROR_DATA="-0.9901"

# Test if can execute caommand in container
TEST=$($DOCKER_COMMAND ps -e 2>&1> /dev/null)

if [ $? -ne 0 ];then
  echo "$ERROR_DATA"
  exit 1
fi

# Default output total processes of container if there are no parameters
if [ -z "$ZBX_REQ_PRO_NAME" -a -z "$ZBX_REQ_PRO_USER_NAME" -a -z "$ZBX_REQ_PRO_CMDLINE" ]; then
  TOTAL_NUM_PRO=$($DOCKER_COMMAND ps -e | wc -l)
  echo "$TOTAL_NUM_PRO"
  exit 0
fi

# If parameter of service name is not NULL  
if [ ! -z "$ZBX_REQ_PRO_NAME" ];then 

  # Get the PID according to service name
  PID_PRO=$($DOCKER_COMMAND pidof "$ZBX_REQ_PRO_NAME" 2> /dev/null)

  # If only parameter of service name, then directly return number of it
  if [ -z "$ZBX_REQ_PRO_USER_NAME" -a -z "$ZBX_REQ_PRO_CMDLINE" ]; then
    NUM_PRO=$(echo $PID_PRO | wc -w)
    echo "$NUM_PRO"
    exit 0

  # If parameter of serice name is not empty and parameter of user is empty
  elif [ -z "$ZBX_REQ_PRO_USER_NAME" ];then
    NUM_PRO=0
    
    # Calculate the number of process match with service name + command line
    for i in $PID_PRO;do
      NUM_PRO_TMP=$($DOCKER_COMMAND ps -o command $i | grep -v "^COMMAND" | grep -ic "$ZBX_REQ_PRO_CMDLINE" )
      NUM_PRO=$(($NUM_PRO+$NUM_PRO_TMP))
    done
    echo $NUM_PRO
    exit 0
  # Calculate the number of process match with service name + user name + [command line]
  else
    NUM_PRO=0
    for i in $PID_PRO;do
      NUM_PRO_TMP=$($DOCKER_COMMAND ps -o user,command $i | grep -v "^USER " | grep "^$ZBX_REQ_PRO_USER_NAME " |  grep -ic "$ZBX_REQ_PRO_CMDLINE" )
      NUM_PRO=$(($NUM_PRO+$NUM_PRO_TMP))
    done
    echo $NUM_PRO
    exit 0
  fi

# Calculate the number of process without parameter of service name
else
  NUM_PRO=$($DOCKER_COMMAND ps -e -o user,command | grep -v '^USER' | grep "^$ZBX_REQ_PRO_USER_NAME" | grep -i "$ZBX_REQ_PRO_CMDLINE" | wc -l)
  echo $NUM_PRO
  exit 0
fi
