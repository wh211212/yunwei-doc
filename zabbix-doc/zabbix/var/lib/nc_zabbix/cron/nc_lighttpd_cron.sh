#!/bin/bash
CURL=$(which curl)
URL="http://127.0.0.1/server-status?auto"

DEST_FOLDER=/var/lib/nc_zabbix/tmp
TMP_FILE=lighttpd.status
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
/usr/local/lighttpd/sbin/lighttpd -v | awk -F / '{print $2}' | awk '{print "version:" $1}' | head -1 >> $DEST_FILE
#/usr/sbin/lighttpd -v | awk -F - '{print $2}' | awk '{print "version:" $1}' | head -1 >> $DEST_FILE
#########################################################
# scoreboard key                                        #
#########################################################
#  "_" Waiting for Connection
#  "S" Starting up
#  "R" Reading Request
#  "W" Sending Reply
#  "K" Keepalive (read)
#  "D" DNS Lookup
#  "C" Closing connection
#  "L" Logging
#  "G" Gracefully finishing
#  "I" Idle cleanup of worker
#  "." Open slot with no current process
tmpscoreboard=$(grep -i scoreboard $DEST_FILE)
echo -n "scoreboard waiting:" >> $DEST_FILE; echo  $(echo $tmpscoreboard | grep -o . | grep -c "\_") >> $DEST_FILE
echo -n "scoreboard starting:" >> $DEST_FILE; echo  $(echo $tmpscoreboard | grep -o . | grep -c "S") >> $DEST_FILE
echo -n "scoreboard sending:" >> $DEST_FILE; echo  $(echo $tmpscoreboard | grep -o . | grep -c "R") >> $DEST_FILE
echo -n "scoreboard reading:" >> $DEST_FILE; echo  $(echo $tmpscoreboard | grep -o . | grep -c "W") >> $DEST_FILE
echo -n "scoreboard keepalive:" >> $DEST_FILE; echo  $(echo $tmpscoreboard | grep -o . | grep -c "K") >> $DEST_FILE
echo -n "scoreboard dns-lookup:" >> $DEST_FILE; echo  $(echo $tmpscoreboard | grep -o . | grep -c "D") >> $DEST_FILE
echo -n "scoreboard closing:" >> $DEST_FILE; echo  $(echo $tmpscoreboard | grep -o . | grep -c "C") >> $DEST_FILE
echo -n "scoreboard logging:" >> $DEST_FILE; echo  $(echo $tmpscoreboard | grep -o . | grep -c "L") >> $DEST_FILE
echo -n "scoreboard gracefully-finishing:" >> $DEST_FILE; echo  $(echo $tmpscoreboard | grep -o . | grep -c "G") >> $DEST_FILE
echo -n "scoreboard idle-cleanup-of-worker:" >> $DEST_FILE; echo  $(echo $tmpscoreboard | grep -o . | grep -c "I") >> $DEST_FILE
echo -n "scoreboard no-process:" >> $DEST_FILE; echo  $(echo $tmpscoreboard| grep -o . | grep -c "\.") >> $DEST_FILE
