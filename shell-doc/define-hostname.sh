#!/bin/bash
# ==============================================================================
# Function: define hostname for use
# Changelog:
# 2017-07-08  hwang@aniu.tv  initial
################################################################################
# defien variable
oldname=`hostname`
newname=kvm
# read your hostname
#read -p "please input the name :" name
#echo "$name"
# first setup
echo "127.0.0.1   localhost localhost.localdomain $newname " > /etc/hosts
echo "$newname" >> /etc/hosts
# second
sed -i "s/\$oldname/\$newname/g" /etc/sysconfig/network
# third
#hostname ${newname}
# reconnect ssh session  can find the os hostname was change
