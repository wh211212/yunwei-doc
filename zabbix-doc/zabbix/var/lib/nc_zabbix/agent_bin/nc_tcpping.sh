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
#  ops_senior@chinanetcloud.com
#  Original writer lukas.helebrandt@chinanetcloud.com (Now left company)
##################################
# ChangeLog:
#  20140428    LH      initial creation
#  20151028    IE	tcpping version
##################################
VERSION=1.0t

# Hardcoded settings
TIMEOUT="1" 
COUNT="8" #So the script finishes before zabbix timeout (3s) (8 pings in 0.2s intervals, first is sent out at t=0, so sending finishes after 1.4s, timeout is 1s, so 2.4s we should be finished
INTERVAL="0.2" #Smallest that non-root can set

# Error handling:
ERROR_ARGUMENTS="-0.9901" # wrong arguments to script (wrong amount of them)

# Get arguments
IP="$1"
PORT="$2"

#Check number of arguments given
if [ $# -ne 2 ] ; then
        echo $ERROR_ARGUMENTS
        exit 1
fi

PING=$(/opt/ncscripts/tcpping -x "$COUNT" -r "$INTERVAL" -w $TIMEOUT "$IP" "$PORT")

TIMEOUTS=$(echo "$PING" | grep -c timeout)

if [ $TIMEOUTS -ne 0 ]
then
	PERCENT_PACKETLOSS=$(echo "scale=2; ($TIMEOUTS/$COUNT)*100" |bc )
	echo "-$PERCENT_PACKETLOSS"
else
RESPONSE_TIMES=$(echo "$PING" |awk '{print $9}')
TOTAL=0
	for RESPONSE_TIME in $RESPONSE_TIMES
	do
		TOTAL=$(echo "scale=2; $TOTAL+$RESPONSE_TIME" |bc)
	done
AVERAGE=$(echo "scale=2; $TOTAL/$COUNT" |bc)
echo "$AVERAGE"
fi

exit 0
