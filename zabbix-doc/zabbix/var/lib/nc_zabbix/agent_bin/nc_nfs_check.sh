#!/bin/bash
# Version:1.0
# Writter : MJ

### Error Code ###
# -0.9905 --- nfsstat command is not exist,please use 'yum install nfsstat' to install
# -0.9906 --- lack of options
# -0.9907 --- the mount point dose not mounted correctly



# Parameters
NFSSTAT=/usr/sbin/nfsstat

# Judge current nfs mount status is the same in zabbix
exist_return(){
   echo "$1"
   exit 1
}

# Check Parameters
check_parameters(){
[ -e "$NFSSTAT" ] || exist_return "-0.9905"
}


# Get nfs status on the server
get_nfs_status() {
# Check nfs client mount point
ZABBIX_NFS_CLIENT_MOUNT_POINT="$1"
[ -z "$ZABBIX_NFS_CLIENT_MOUNT_POINT" ] && exist_return "-0.9906"
NFS_CLIENT_MOUNT_POINT=`$NFSSTAT -m | grep -v Flags | grep $ZABBIX_NFS_CLIENT_MOUNT_POINT | awk '{print $1}'`

# Check nfs server mount point
ZABBIX_NFS_SERVER_MOUNT_POINT="$3"
[ -z "$ZABBIX_NFS_SERVER_MOUNT_POINT" ] && exist_return "-0.9906"
NFS_SERVER_MOUNT_POINT=`$NFSSTAT -m | grep -v Flags | grep $ZABBIX_NFS_CLIENT_MOUNT_POINT |awk  '{print $NF}'| awk -F':' '{print $NF}'`

# Check nfs server name or ip
ZABBIX_NFS_SERVER_NAME="$2"
[ -z "$ZABBIX_NFS_SERVER_NAME" ] && exist_return "-0.9906"
NFS_SERVER_NAME=`$NFSSTAT -m | grep -v Flags | grep $ZABBIX_NFS_CLIENT_MOUNT_POINT | grep $ZABBIX_NFS_SERVER_NAME | awk  '{print $NF}' | awk -F':' '{print $1}'`
}

# Check number of nfs mount point
nfs_mount_number(){
NUM_MOUNT_POINT=`$NFSSTAT -m| grep -v Flags |grep -v '^$' | wc -l`
echo $NUM_MOUNT_POINT
}

# compare if mount point the same between zabbix and server
check_nfs(){
   # Check if mount point is correctly mounted
   [ "$ZABBIX_NFS_CLIENT_MOUNT_POINT" != "$NFS_CLIENT_MOUNT_POINT" ] && exist_return "-0.9907"
   [ "$ZABBIX_NFS_SERVER_MOUNT_POINT" != "$NFS_SERVER_MOUNT_POINT" ] && exist_return "-0.9907"
   [ "$ZABBIX_NFS_SERVER_NAME" != "$NFS_SERVER_NAME" ] && exist_return "-0.9907"

   echo 'OK' && exit 0
}

## Main ##
if [ $1 == "NFS_NUM" ]; then
	check_parameters
	nfs_mount_number
else
	check_parameters
	get_nfs_status $1 $2 $3
	check_nfs
fi
