#!/bin/bash
##################################
# Zabbix monitoring script
#
# ping:
#  - ping an IP address from monitored node
#  - script sends out 8 pings in 0.2s interval
#  - timeout (ping -W, time to wait for a response) is set to 1 (zabbix custom script timeout supposed to be 3s, we send out 8 pings in 1.4s, so the last one times out in 2.4s)
#
#  - Syntax:nc_ping[IP]
#
#  - Return values:
#  	- Positive: average response time ONLY IF there were no lost packets
#  	- Negative values: Percentage of packet lost
#
##################################
# Contact:
#  lukas.helebrandt@chinanetcloud.com
##################################
# ChangeLog:
#  20140428    LH      initial creation
##################################
VERSION=1.0

# Hardcoded settings
TIMEOUT="1" 
COUNT="8" #So the script finishes before zabbix timeout (3s) (8 pings in 0.2s intervals, first is sent out at t=0, so sending finishes after 1.4s, timeout is 1s, so 2.4s we should be finished
INTERVAL="0.2" #Smallest that non-root can set

# Error handling:
ERROR_ARGUMENTS="-0.9901" # wrong arguments to script (wrong amount of them)

# Get arguments
IP="$1"

#Check number of arguments given
if [ $# -ne 1 ] ; then
        echo $ERROR_ARGUMENTS
        exit 1
fi

#Let the ping begin
# -q is for quiet output

PING=$(ping -c "$COUNT" -i "$INTERVAL" -W $TIMEOUT -q "$IP" )
PACKETLOSS=$(echo $PING | awk '{print $18}' | sed 's/%//')

if [ "$PACKETLOSS" -ne 0 ]; then
	echo "-$PACKETLOSS"
else
	AVERAGE=$(echo $PING | awk -F "/" '{print $5}')
	echo "$AVERAGE"
fi

exit 0

