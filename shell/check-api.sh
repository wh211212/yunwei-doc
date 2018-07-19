#!/bin/bash
## ####################################
# functions: check api status
#######################################
# ChangeLog:
#   2016-05-27  wh    initial creation      
######################################

date=$(date +%F-%T)
for apiurl in $(cat /home/wh/script/api_url.txt)
do
status_code=`curl -o /dev/null -m 10 --connect-timeout 10 -s -w %{http_code} $apiurl`
if [ "$status_code" = "200" ]; then
       echo "$apiurl status code:\t $status_code" 
    else
       echo "api status code:\t $apiurl not alive" 
       echo "$date api:\t $apiurl not alive" >> /home/wh/log/api_status.log
fi
sleep 1
done
