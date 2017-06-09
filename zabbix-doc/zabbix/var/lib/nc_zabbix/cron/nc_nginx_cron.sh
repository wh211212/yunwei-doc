#!/bin/bash
CURL=$(which curl)
URL="http://127.0.0.1:81/nginx_status"

DEST_FOLDER=/var/lib/nc_zabbix/tmp
TMP_FILE=nginx.status
DEST_FILE=$DEST_FOLDER/$TMP_FILE

# check for existing folder - creates it
if [ ! -d $DEST_FOLDER ]; then
  mkdir -p $DEST_FOLDER 2> /dev/null
  [ $? -ne 0 ] && (echo "ERROR: Can NOT create destination folder: $DEST_FOLDER - check permissions"; exit 2)
fi

# check if file can be written / created
echo > $DEST_FILE
if [ $? -ne 0 ]; then
  echo "$DEST_FILE can NOT be created / updated - check permissions"
  exit 2
fi
$CURL $URL -o $DEST_FILE
/usr/sbin/nginx -v 2>&1 | awk -F / '{print "version:" $2}' | head -1 >> $DEST_FILE

