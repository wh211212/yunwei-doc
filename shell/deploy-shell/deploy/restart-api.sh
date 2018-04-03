#!/bin/bash
#-------------------------------------------------------------------------------
# Functions: auto deploy api project, base on tomcat
#-------------------------------------------------------------------------------
# ChangeLog:
# 2016-12-19    wanghui    initial create
# 2017-06-27    wanghui    change some Functions
# 2017-08-04    wanghui    add array use
# add logrotate & crontab delete log & add iuput color
#-------------------------------------------------------------------------------
# set some variables
source /etc/profile
# define project variables
date=`date +%F_%T`
# DATE=`date +Y-%m-%d`
project_name=aniu-api
project_dir=old-project
project=aniuapi
# define some dir
workspace=/var/lib/jenkins/workspace
project_home=$workspace/$project_dir
backup_dir=/data/warback/$project_name
wget_dir=/tmp/wget
deploylog=/var/log/deploy.log
# define array
portlist=(8082 8083)
# print array len
# echo ${#portlist[@]}
# use
# for port in ${portlist[@]};do;echo $port;done
#-------------------------------------------------------------------------------
function restart() {
for port in ${portlist[@]};
  do
  tomcat_port=tomcat_$port
#  tomcat_home=/data/tomcats/${tomcat_port}
  tomcat_home=/data/${tomcat_port}
  webapps_dir=$tomcat_home/webapps
# shutdown tomcat
  /bin/bash $tomcat_home/bin/shutdown.sh
  sleep 3
  tomcat_status=`ps -ef | grep ${tomcat_port} | grep -v grep | awk '{print $2}' | wc -l`
  if [ $tomcat_status -eq 0 ]; then
       echo -e "*** \033[31m $date $tomcat_port auto shutdown succeed. \033[0m ***"
       echo "*** $date $tomcat_port auto shutdown succeed. ***" >> $deploylog
    else
       echo -e "*** \033[31m $date $tomcat_port auto shutdown failed, then should force shutdown $tomcat_port. \033[0m ***"
       echo "*** $date $tomcat_port auto shutdown failed, then should force shutdown $tomcat_port. ***" >> $deploylog
       ps -ef | grep $tomcat_port | grep -v grep | awk '{print $2}' | xargs kill -9
  fi
# delete tomcat & start tomcat
  /bin/rm -rf $webapps_dir/$project*
  /bin/cp $wget_dir/$project.war $webapps_dir/
  /bin/bash $tomcat_home/bin/startup.sh
#  sleep three seconds waiting tomcat startup
  sleep 3
  tomcat_pid=`ps -ef | grep $tomcat_port | grep -v grep | awk '{print $2}' | wc -l`
  if [ $tomcat_pid -eq 1 ];then
     echo "*************************************************************"
     echo "*** $date $tomcat_port auto restart succeed ! ***"
     echo "*** $date $tomcat_port auto restart succeed ! ***" >> $deploylog
     echo "*************************************************************"
  else
    echo "******************************************************************"
    echo -e "*** \033[31m $date $tomcat_port auto restart failed ! \033[0m ***"
    echo "*** $date $tomcat_port auto restart failed ! ***"       >> $deploylog
    echo "*******************************************************************"
  fi
done
}

# set main functions
function main() {
  # callback restart func
  restart
}
# call main function
main
