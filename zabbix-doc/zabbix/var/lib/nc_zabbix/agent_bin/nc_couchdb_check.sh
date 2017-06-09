#!/bin/bash
##################################
# Zabbix monitoring script
#
# apache:
#  - anything available via apache server-status module
#
##################################
# Contact:
#  tracy.wang@chinanetcloud.com
##################################
# ChangeLog:
#  20120426     TW      INITIAL CREATION
##################################
VERSION=1.0

# Zabbix requested parameter
ZBX_REQ_DATA1="$1"
ZBX_REQ_DATA2="$2"
ZBX_REQ_DATA_URL="$3"
# CouchDB defaults
COUCHDB_STATUS_DEFAULT_URL="http://localhost:5984/_stats"
CURL_BIN=$(which curl)

#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - items need to be of type "float" (allow negative + float)
#
ERROR_NO_ACCESS_FILE="-0.9900"
ERROR_NO_ACCESS="-0.9901"
ERROR_WRONG_PARAM="-0.9902"
ERROR_DATA="-0.9903" # either can not connect / bad host / bad port

# Handle host and port if non-default
if [ ! -z "$ZBX_REQ_DATA_URL" ]; then
  URL="$ZBX_REQ_DATA_URL"
else
  URL="$COUCHDB_STATUS_DEFAULT_URL"
fi

# save the apache stats in a variable for future parsing
COUCHDB_STATUS=$($CURL_BIN $URL 2> /dev/null)
TMPSCOREBOARD=$(echo $COUCHDB_STATUS | sed -e 's/[{}]/''/g' | sed -e 's/\"couchdb\"\://g' | sed -e 's/"//g'| awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed -e 's/null/0/g')

# error during retrieve
if [ $? -ne 0 -o -z "$COUCHDB_STATUS" ]; then
  echo $ERROR_DATA
  exit 1
fi

# 
# Extract data from couch stats
#
case $ZBX_REQ_DATA2 in
  current) echo "$TMPSCOREBOARD" | grep $ZBX_REQ_DATA1 -A 1 | tail -1 | awk -F : '{print $2}';;
  sum)     echo "$TMPSCOREBOARD" | grep $ZBX_REQ_DATA1 -A 2 | tail -1 | awk -F : '{print $2}';;
  mean)    echo "$TMPSCOREBOARD" | grep $ZBX_REQ_DATA1 -A 3 | tail -1 | awk -F : '{print $2}';;
  stddev)  echo "$TMPSCOREBOARD" | grep $ZBX_REQ_DATA1 -A 4 | tail -1 | awk -F : '{print $2}';;
  min)     echo "$TMPSCOREBOARD" | grep $ZBX_REQ_DATA1 -A 5 | tail -1 | awk -F : '{print $2}';;
  max)     echo "$TMPSCOREBOARD" | grep $ZBX_REQ_DATA1 -A 6 | tail -1 | awk -F : '{print $2}';;
  *)                    echo $ERROR_WRONG_PARAM; exit 1;;
esac

exit 0
