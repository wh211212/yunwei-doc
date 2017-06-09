#!/usr/bin/python
##################################
# Zabbix monitoring script
#
# hearbeat:
#  - Connect to zabbix app server from proxy server and measure response time for heartbeat request.
#
#  - Syntax:nc_zabbix-app-heart-beat.py[<zabbix-app ip or proxy it's going through>, <port>]
#
#  - Return values:
#  	- Positive: last response time value.
# 	- Negative values: See respective comments for each below.
#
##################################
# Contact:
#  ops_senior@chinanetcloud.com
#  Original writer isaac.egglestone@chinanetcloud.com
##################################
# ChangeLog:
#  20151103    IE	Initial creation.
##################################
#VERSION=1.0

import sys
import telnetlib
import socket
import timeit
import time
import shutil

if len(sys.argv) == 3:
	host = sys.argv[1]
	port = sys.argv[2]
else:
	print "Usage /name.py <hostname or ip where zabbix lives> <port where zabbix answers>"
	quit()
# Setup variables edit these as required
############################################################################################
timeout = 10
hostname=socket.gethostname()
# A list to store read status in.
readlist = ();
# The temp file to store updates in.
zabbix_tmp_file = '''/var/lib/nc_zabbix/tmp/zabbix_proxy_heartbeat.tmp'''
# The file zabbix-agent will read
zabbix_file = '''/var/lib/nc_zabbix/tmp/zabbix_proxy_heartbeat'''


#Error codes to return during communciations:
############################################################################################
#Error code to return when end of file occurs on reading the connection after data is sent.
read_timeout_code = -25
#Error code to return when zabbix does not return OK but did return something
#End of stream/file while writing to socket (IE we were connected, we tried to send some data but the connection dropped
write_failed = -35
#Write succeeded but reponse failed to come back.
bad_return_code = -50
#Timeout code for initial socket connection (IE we got nowhere maybe iptables, or firewall blocking it or it's down)
connect_timeout_code = -100

#Error Codes for script/variable issues.
#Script will throw an uknown error in zabbix as reporting -0.99 or example will actually get tracked here.
#Run script on command line to see type of error and fix it.

#Static Constants:
############################################################################################
#Expected response from Zabbix.
zabbixsays=["OK"]
#Heartbeat to send to Zabbix
heartbeat = '''ZBXD.A.......{"request":"proxy heartbeat","host":"'''+hostname+'''"}ZBXD.........'''

#Main
############################################################################################
time_before=time.time()

def finishup(status):
	if 'tn' in globals():
		tn.close()
	zabbix_tmp_file_handle.write(str(status)+"\n")
	# Move the tmp file to the file zabbix will read.
	shutil.move(zabbix_tmp_file,zabbix_file)
	quit()


# Write data to a temp file to avoid zabbix reading half written file
try:
	zabbix_tmp_file_handle = open(zabbix_tmp_file, 'w')
except IOError:
	print "Problem with creating the file : "+zabbix_tmp_file
	quit()

#Try to open a connection to the zabbix port
try:
	tn = telnetlib.Telnet(host,port,timeout)
except (socket.timeout,socket.error):
	finishup(connect_timeout_code)

#If open suceeded send heartbeat message
try:
	tn.write(heartbeat + "\n")
except socket.error:
	finishup(write_failed)
#Wait for OK message
try:
	readlist = tn.expect(zabbixsays, timeout)
except EOFError:
	finishup(read_timeout_code)
if readlist[0] == -1:
	finishup(bad_return_code)

#Time the process and finish up by writing to a file etc...
time_after=time.time()
total_time=time_after - time_before
finishup(total_time)
