#!/bin/bash
#########################################################################
# File Name: check_longtime_status.sh
# Author: shaonbean
# Email: shaonbean@qq.com
# Created Time: Thu 04 Aug 2016 03:42:12 PM CST
#########################################################################

#set variables
read -t 60 -p "input the day you want to check before: " day
date=`date --date "$day days ago" +"%Y-%m-%d"`
#date=
log_path=/home/wh/scripts
logfile=$log_path/localhost_access_log.$date.txt

#total
sum_access_time=`cat $logfile | awk '{s+=$NF} END {print s}'` 
total_sum_access=`cat $logfile | wc -l`
#avg_access_time=`expr $sum_access_time /$total_sum_access`
avg_access_time=`awk 'BEGIN{printf "%.2f\n",('$sum_access_time'/'$total_sum_access')}'`

echo "total access time is: $sum_access_time"
echo "total access number is : $total_sum_access"
echo "avg access time is : $avg_access_time"

#longtime access
read -p "input respond to the request more than time: " sec

total_slow_access_time=`awk '$NF>2' $logfile | awk '{s+=$NF} END {print s}'`
long_time_page_sum=`awk '$NF>$sec' $logfile | wc -l`
#avg_slow_access_time=`expr $total_slow_access_time/$long_time_page_sum`
avg_slow_access_time=`awk 'BEGIN{printf "%.2f\n",('$total_slow_access_time'/'$long_time_page_sum')}'`
echo "total_slow_access_time is : $total_slow_access_time"
echo "total_slow_access_number is : $long_time_page_sum"
echo "avg_slow_access_time is : $avg_slow_access_time" 

#access page
awk '$NF>2' $logfile | awk '{print $(NF-4)'} | awk '{++s[$1]} END {for (k in s) print s[k],k}' | sort -r | head -5 > $log_path/top5_logtime_access_page.txt
echo "show top 5 longtime access page"
cat $log_path/top5_logtime_access_page.txt
sleep 5

#cheak over
