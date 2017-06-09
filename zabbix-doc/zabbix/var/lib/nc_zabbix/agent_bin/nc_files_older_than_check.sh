#!/bin/bash
##################################
# Zabbix monitoring script
#
# filesolderthan:
#  - monitor, if a FOLDER has a FILE (not directory) older than TIME
#  - Syntax: filesolderthan[FOLDER,TIMEinMINUTES]
#  - returns number of files older than TIME
#
##################################
# Contact:
#  lukas.helebrandt@chinanetcloud.com
##################################
# ChangeLog:
#  20140410    LH      initial creation
##################################
VERSION=1.0

# Error handling:
ERROR_NOACCESS="-0.9901" # Folder doesn't exist or is not accessible
ERROR_ARGUMENTS="-0.9902" # wrong arguments to script (wrong amount of them)

# Get arguments
FOLDER="$1"
TIME="$2"

#Check number of arguments given
if [ $# -ne 2 ] ; then
	echo $ERROR_ARGUMENTS
	exit 1
fi

#Find files modified longer than $TIME ago
#First check if $FOLDER exists and is readable for us
if [ -e "$FOLDER" -a -r "$FOLDER" ]; then
	echo $(find "$FOLDER" -maxdepth 1 -mmin +"$TIME" -type f | wc -l)
else
	echo "$ERROR_NOACCESS"
	exit 1
fi

exit 0
