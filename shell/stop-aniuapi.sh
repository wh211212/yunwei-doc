#!/bin/bash
#-------------------------------------------------------------------------------
# Functions: stop aniuapi 
#-------------------------------------------------------------------------------
# ChangeLog:
# 2018-05-07    wanghui    change
# add logrotate & crontab delete log & add iuput color
#-------------------------------------------------------------------------------
# set -x # for debug

DATE=`date +%F_%T`
DATETIME=`date +%Y-%m-%d`

# jenkins & package config
project_name=aniu-api
project=aniuapi

deploylog=/var/log/tomcat/deploy-${DATETIME}.log

# define port list array

portlist=(7081 7082 7083)

# define functions
function stopapi() {

  for port in ${portlist[@]};
    do
    tomcat_port=tomcat-$port
    tomcat_home=/data/tomcats/${tomcat_port}
    webapps_dir=$tomcat_home/webapps
    /bin/bash $tomcat_home/bin/shutdown.sh

    sleep 5

    tomcat_status=`ps -ef | grep ${tomcat_port} | grep "[o]rg.apache.catalina.startup.Bootstrap start" | grep -v grep | awk '{print $2}' | wc -l`

    if [ $tomcat_status -eq 0 ]; then
        echo "*** $DATE $tomcat_port auto shutdown succeed. ***"
        echo "*** $DATE $tomcat_port auto shutdown succeed. ***" >> $deploylog
      else
        echo "*** $DATE $tomcat_port auto shutdown failed, then should force shutdown $tomcat_port. ***"
        echo "*** $DATE $tomcat_port auto shutdown failed, then should force shutdown $tomcat_port. ***" >> $deploylog
       ps -ef | grep $tomcat_port | grep -v grep | awk '{print $2}' | xargs kill -9
    fi

done
}

# set main functions
function main() {
  stopapi
}

# call main function
main
