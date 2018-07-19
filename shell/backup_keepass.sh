#!/bin/bash
#-----------------------------------
# Functions: backup keepass file
# Changelog:
# 2017-10-13 wanghui initial
#----------------------------------
file_dir=/var/www/html/yunwei
#file_name=$file_dir/aniu.kdbx
file_name=$file_dir/yunwei.kdbx
date=`date +%F_%T`
#
cp $file_name $file_dir/${date}_yunwei.kdbx
