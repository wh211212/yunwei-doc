#!/bin/bash
# Allen.Zhang    allen.zhang@chinanetcloud.com
# AZ    2009-10-29      create the scrpit #
# AZ    2009-10-29    change the error code from -990? to -0.990?

### Error Code ###
# -0.9901 --- the file from cron job does not exist
# -0.9902 --- the file from cron job was not updated
# -0.9903 --- the first argument of this sub script is empty
# -0.9904 --- the first argument of this sub script is not found
# -0.9905 --- the folder permission is not correct

version=1

### Cron Job ###
# cron job script for lighttpd
# lighttpd_cron_script="/var/lib/nc_zabbix/agent_bin/nc_lighttpd_cron.sh"
# */$frequence * * * * bash /var/lib/nc_zabbix/agent_bin/nc_lighttpd_cron.sh
# lighttpd status file from cron job
frequence=5

CURRENT_DIR=$(readlink -f $(dirname $0))
tmp_folder="$CURRENT_DIR/../tmp"
lighttpd_status_file="$tmp_folder/lighttpd.status"

# Override defaults from config file
SCRIPT_CONF=$CURRENT_DIR/../conf/nc_lighttpd_check.conf
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

### Function ###
check_return(){
if [ $? -ne 0 ]
  then
     echo "$1"
     exit 1
  else
     :
fi
}

check(){
    keyword=`echo $1 | tr "_" " " | sed 's/^ *//;s/ *$//'`
    #check the argument is empty or not
    if [ -z "$keyword" ]; then
        echo "-0.9903"
        exit 1
    else
        #check the argument is exist or not
        preretval=$(grep -i "$keyword" "$lighttpd_status_file")
        if [ -z "$preretval" ]; then
            echo "-0.9904"
            exit 1
        else
            #check the argument's value is empty or not. if it is empty, give it "0"
            retval=$(echo "$preretval"| cut -f2 -d: | sed 's/^ *//;s/ *$//')
            if [ -z "$retval" ]; then
                echo 0
                exit 0
            else
                echo $retval
                exit 0
            fi
        fi
    fi
}

# Check the folder
[ -d "$tmp_folder" -a -r "$tmp_folder" -a -w  "$tmp_folder" -a -x "$tmp_folder" ] 
check_return "-0.9905"

# check if the file from cron job exists
[ -f "$lighttpd_status_file" ] 
check_return "-0.9901"

# check if the file from cron job was updated 
touch -d "$((frequence*2)) minutes ago" "$tmp_folder/timestamp_lighttpd"
[ "$lighttpd_status_file" -nt "$tmp_folder/timestamp_lighttpd" ] 
check_return "-0.9902"

####main######
case $1 in                
    *             ) check "$1";;
esac


