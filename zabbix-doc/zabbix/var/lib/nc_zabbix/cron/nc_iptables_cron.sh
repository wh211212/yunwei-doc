#!/bin/bash
##########################################
# iptables-save cron for zabbix 
##########################################
#
# 2010-06-04    CH    Init create
# 2010-07-08    JS    Add keep iptables history function fix cron job time bug.
##########################################

## The save file and major command we need in this
## script, zabbix use md5sum to check the file
IPTABLES_SAVE_FILE="/var/lib/nc_zabbix/tmp/iptables-save"
IPTABLES_TEMP_FILE="$IPTABLES_SAVE_FILE.tmp"
HISTORY_FOLDER="/var/lib/nc_zabbix/tmp/iptables_history"
HISTORY_FILE="$HISTORY_FOLDER/iptables_history.$(date +%y%m%d%H%M)"
CMD="/sbin/iptables-save"

## Test user zabbix's permission for sudo the CMD
SUDO_LIST=$(sudo -l | grep NOPASSWD | awk -F ':' '{print $2}' | tr -d ' ')
if [ "$SUDO_LIST" != "ALL" ] && [ $(echo "$SUDO_LIST" | grep -c "/sbin/iptables-save") -lt 1 ];then
    logger "sudo: sorry, user $USER is not allowed to execute '/sbin/iptables-save' as root on $(hostname -s)."
    exit 2
fi
## Test the save file exist or not, if it doesn't
## exist, then create it and change the permission to 600
if [ ! -e $IPTABLES_SAVE_FILE ];then
    sudo $CMD | grep '^-' > $IPTABLES_SAVE_FILE;
    chmod 600 $IPTABLES_SAVE_FILE;
    exit 0 
fi
## Check iptables history folder exist or not, if it doesn't 
## exist, then create it 
[ ! -d $HISTORY_FOLDER ] && mkdir $HISTORY_FOLDER;

## Test the writable permission for the save file
if [ ! -w $IPTABLES_SAVE_FILE ];then
    logger "mkdir: cannot create directory $IPTABLES_SAVE_FILE: Permission denied";
exit 1 

elif [ ! -w $HISTORY_FOLDER ];then
    logger "mkdir: cannot create directory $HISTORY_FOLDER: Permission denied";
exit 1;
fi

## Save the current iptables rules to the save file
sudo $CMD | grep '^-' > $IPTABLES_TEMP_FILE;

## If iptables save is not sucess then exit and record log to the system 
#if [ $? != 0 ];then
#    logger "The iptables save is not success!"
#    exit 1
#fi
#Define md5 file variables
MD5_TEMP_FILE="$(md5sum $IPTABLES_TEMP_FILE | awk '{print $1}')"
MD5_SAVE_FILE="$(md5sum $IPTABLES_SAVE_FILE | awk '{print $1}')"

# Check md5 whether the same 
if [ $MD5_TEMP_FILE == $MD5_SAVE_FILE ];then 

    # If they are the same, clean the temp file and exit
    mv -f $IPTABLES_TEMP_FILE $IPTABLES_SAVE_FILE;
    exit 0
else 

    # If they are not the same,backup iptables save file to the history folder 
    # and replace monitored file 
    mv $IPTABLES_SAVE_FILE $HISTORY_FILE && mv $IPTABLES_TEMP_FILE $IPTABLES_SAVE_FILE;
fi

