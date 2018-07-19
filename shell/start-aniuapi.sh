#!/bin/bash
#-------------------------------------------------------------------------------
# Functions: auto deploy api project, base on tomcat
#-------------------------------------------------------------------------------
# ChangeLog:
# 2018-05-07    wanghui    initial
# add logrotate & crontab delete log & add iuput color
#-------------------------------------------------------------------------------
# set -x # for debug

DATE=`date +%F_%T`
DATETIME=`date +%Y-%m-%d`

# jenkins & package config
project=aniuapi

deploylog=/var/log/tomcat/deploy-${DATETIME}.log

# define port list array
portlist=(7081 7082 7083)

# define functions
function startapi() {

  for port in ${portlist[@]};
    do
    tomcat_port=tomcat-$port
    tomcat_home=/data/tomcats/${tomcat_port}
    /bin/bash $tomcat_home/bin/startup.sh

    sleep 5

    tomcat_pid=`ps -ef | grep $tomcat_port | grep "[o]rg.apache.catalina.startup.Bootstrap start" | grep -v grep | awk '{print $2}' | wc -l`
    if [ $tomcat_pid -eq 1 ];then
        echo "*************************************************************"
        echo "*** $DATE $tomcat_port auto start succeed ! ***"
        echo "*** $DATE $tomcat_port auto start succeed ! ***" >> $deploylog
        echo "*************************************************************"
      else
        echo "*************************************************************"
        echo "*** $DATE $tomcat_port auto start failed ! ***"
        echo "*** $DATE $tomcat_port auto start failed ! ***"   >> $deploylog
        echo "*************************************************************"
    fi
    done
}


# set main functions
function main() {
  startapi
}

# call main function
main
