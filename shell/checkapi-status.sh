#!/bin/bash
#-------------------------------------------------------------------------------
# Functions: check api run status
#-------------------------------------------------------------------------------
# ChangeLog:
# 2018-05-22    wanghui    initial
#-------------------------------------------------------------------------------
# set -x # for debug

DATE=`date +%F_%T`
DATETIME=`date +%Y-%m-%d`

# Default for binaries - use the PATH - override in the config file if PATH chaneg required
CURL_BIN=$(which curl)
IFCONFIG_BIN=$(which ifconfig)

# jenkins & package config
project=aniuapi

# define port list array
portlist=(7081 7082 7083)

# print array len
# echo ${#portlist[@]}
# for port in ${portlist[@]};do;echo $port;done
#-------------------------------------------------------------------------------
sleep 30

function checkrun() {
  # get server cuurrent ip
  ip=`$IFCONFIG_BIN | grep 'inet' | grep -v '127.0.0.1' | awk '{ print $2}'`

  for port in ${portlist[@]}
  do
# Get the detection URl from developer
    url="api/v2/video/commend?channelid=100211&clienttype=2&devid=800001&pno=1&productid=004&psize=3&time=20151110141945&type=2&sign=51c2e405b3e808256e209a9f44a35058"
    checkurl="http://$ip:$port/$project/$url"
    status_code=`$CURL_BIN -o /dev/null -m 10 --connect-timeout 10 -s -w %{http_code} $checkurl`
  if [ "$status_code" = "200" ]; then
       echo "*** $DATE $project $ip $port is running ok! ***"
    else
       echo "*** $DATE $project $ip $port is not running! ***"
       exit 0
  fi
done
}

# set main functions
function main() {
  checkrun
}

# call main function
main
