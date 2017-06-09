#!/bin/bash
### Error Code ###
# -0.9903 --- the first argument of this sub script is empty
# -0.9904 --- the first argument of this sub script is not found
# -0.9905 --- the folder permission is not correct

MONGO=/usr/bin/mongo
serverstatus="/var/lib/nc_zabbix/tmp/mongodb-replica.status"
serverstatusjs="/var/lib/nc_zabbix/bin/mongo_Replica.js"
tmp_folder="/var/lib/nc_zabbix/tmp"
monogstat_bin="/usr/bin/mongostat"
mongo_user=""
mongo_pwd=""
mongo_port=27017

# if no user is provided, don't use authentication
if [ -z "$mongo_user" ]; then
    $MONGO admin --port $mongo_port $serverstatusjs > $serverstatus
else
    $MONGO -u $mongo_user -p$mongo_pwd admin --port 10100 $serverstatusjs > $serverstatus
fi

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
    keyword=`echo $1 |  sed 's/^ *//;s/ *$//'`
    #check the argument is empty or not
    if [ -z "$keyword" ]; then
        echo "-0.9903"
        exit 1
    else
        #check the argument is exist or not preretval=$(grep -i $1' ' "$mysql_extended_file")
        if [ -z "$preretval" ]; then
            echo "-0.9904"
            exit 1
        else
            #check the argument's value is empty or not. if it is empty, give it "0"
            retval=$(echo "$preretval"|  awk '{ print $4 }' | sed 's/^ *//;s/ *$//')
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


case $1 in
    oplog_first     ) grep first  "$serverstatus" | awk -F 'time:' '{ print $2 }'|sed 's/ *$//g'|sed 's/^ *//g';;
    oplog_last      ) grep last   "$serverstatus" | awk -F 'time:' '{ print $2 }'|sed 's/ *$//g'|sed 's/^ *//g';;
    oplog_size      ) grep size   "$serverstatus" | awk -F':' '{print $2}'|sed 's/ *$//g'|sed 's/^ *//g';;
    oplog_length    ) grep length "$serverstatus" | awk -F':' '{print $2}'|awk -F'secs' '{print $1}'| sed 's/ *$//g' | sed 's/^ *//g';;
    synced_time     ) grep -A2  $(/sbin/ifconfig eth0|grep inet |awk '{print $2}'| awk -F'addr:' '{print $2}'|sed 's/ *$//g'|sed 's/^ *//g'):$mongo_port "$serverstatus" |grep '=' |awk -F '=' '{print $2}'|awk -F'secs' '{print $1}'|sed 's/ *$//g'|sed 's/^ *//g';;
    *               ) check "$1";;
esac
