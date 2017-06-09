#!/bin/bash

SQUID="/usr/local/squid/bin/squidclient"
DATA="/var/lib/nc_zabbix/tmp/squid.return"
TMP_DATA="/var/lib/nc_zabbix/tmp/squid.ruturn.tmp"
echo > $RETURN
echo > $TMP_DATA

$SQUID -p 882 mgr:info > $TMP_DATA

mv $TMP_DATA $DATA
