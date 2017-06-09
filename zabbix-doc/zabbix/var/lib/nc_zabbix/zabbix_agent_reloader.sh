#!/bin/bash
###############################
# Name: Zabbix_agent_reloader bash script
# Purpose: Restart zabbix_agentd service
# 
# Origin: zabbix_agent sometimes get stuck with everlasting established TCP connections
#         the host doesn't reply to any server's request and appears unreachable
#         bad network connection might be a cause of this behavior
#         relaunching the agent kills the connection and the host is reachable again
#
# Version: 0.2
#
# Changes: 
#   20090209 -- script creation
#   20090227 -- add email alert
#   20090302 -- add agent counts
#   20090805 -- restart agent only if number of stuck agent greated than total-2 agents started
#   20090808 -- repair script -3 agents instead of total-2 agents started
#
# Contact: vincent.viallet@chinanetcloud.com
###############################
# Detection: netstat zabbix ESTABLISHED connections that last forever
#            

NETSTAT=/bin/netstat
SENDMAIL=/usr/sbin/sendmail
DATE=/bin/date 

date=`$DATE "+%Y%m%d-%H%M%S"`
host=$(hostname -s)
destination_email="alerts_a1@chinanetcloud.com"

ZABBIX="zabbix"
ZABBIX_AGENT="/etc/init.d/nc-zabbix-agent"
ZABBIX_CONF="/etc/nc_zabbix/nc_zabbix_agentd.conf"

zabbix_agent_count=`grep StartAgents $ZABBIX_CONF | cut -f2 -d'='`

# filenames of the files we will use to store the status a t=h1, h2 and h3
TMP_CONNECTION_H1=/tmp/zabbix_agentd_reloader_h1
TMP_CONNECTION_H2=/tmp/zabbix_agentd_reloader_h2
TMP_CONNECTION_H3=/tmp/zabbix_agentd_reloader_h3

# file to hold the email content
EMAIL_FILE=/tmp/zabbix_agentd_reloader_email

# check for user ID
if [ $UID != 0 ]; then
  echo 'You need to run this script as ROOT user'
  exit
fi

if [ ! -x "$NETSTAT" ]; then
  echo "$NETSTAT" ' is not executable, check path and permissions'
  exit
fi

if [ ! -x "$ZABBIX_AGENT" ]; then
  echo "$ZABBIX_AGENT" ' is not executable, check path and permissions'
  exit
fi

# if TMP_CONNECTION files does not exist - create one
if [ ! -w "$TMP_CONNECTION_H1" ]; then
  touch "$TMP_CONNECTION_H1"
fi
if [ ! -w "$TMP_CONNECTION_H2" ]; then
  touch "$TMP_CONNECTION_H2"
fi
if [ ! -w "$TMP_CONNECTION_H3" ]; then
  touch "$TMP_CONNECTION_H3"
fi

# we reset the email file every new check
echo > "$EMAIL_FILE"


# rotate connection status files (TMP_CONNECTION) and clean initial H1 file
mv -f "$TMP_CONNECTION_H2" "$TMP_CONNECTION_H3"
mv -f "$TMP_CONNECTION_H1" "$TMP_CONNECTION_H2"
echo > "$TMP_CONNECTION_H1"

# check if their is any established Zabbix connection, clear the extra spaces
# extract and sort the IP address and source port number of the zabbix server
$NETSTAT -nap | grep -i "$ZABBIX" | grep -i established | sed -e 's/  */ /g' | cut -f5 -d' ' | sort > "$TMP_CONNECTION_H1"


########################################
# check whether we have stuck connection for more than 2 period (H1 and H3)
# which means same IP addresses and source port numer
########################################
# first check whether any of the file to be compared are empty
# exit if so, since no operation needs to be performed
if [ ! -s "$TMP_CONNECTION_H1" ]; then
  # no ESTABLISHED connections
  exit
fi
if [ ! -s "$TMP_CONNECTION_H3" ]; then
  # no ESTABLISHED connections
  exit
fi

COMPARE=`diff -q "$TMP_CONNECTION_H1" "$TMP_CONNECTION_H3"`
COUNT_STUCK=`wc -l $TMP_CONNECTION_H1 | cut -f1 -d' '`

# if equal we are facing stuck connections
# force zabbix agent restart
if [ -z "$COMPARE" ]; then
  # if the number of connection stuck is greater than the number of zabbix-agent
  # started at the beginnig (-2 -- to ensure there is always more than needed)
  if [ $((COUNT_STUCK)) -gt $((zabbix_agent_count-3)) ]; then
    $ZABBIX_AGENT stop
    sleep 5
    $ZABBIX_AGENT start

    # send alerts to all channels: log + email
    logger "$date - zabbix_agents restarted - $COUNT_STUCK stuck network connections - by `basename $0`"
    cat > "$EMAIL_FILE" << EOF
Subject: [Zabbix agentd reloaded] $date -- $host
Zabbix agentd has been reloaded due to $COUNT_STUCK stuck network connections
between the zabbix server and the host, on a total of $zabbix_agent_count agents
started.
.
EOF
    cat "$EMAIL_FILE" | "$SENDMAIL" "$destination_email"
  fi
fi


