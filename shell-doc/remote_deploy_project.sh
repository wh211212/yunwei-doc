#!/bin/bash
################################################################################
# Functions: auto deploy api project, base on tomcat
################################################################################
# ChangeLog:
# 2016-12-19    wanghui    initial create
# 2017-06-27    wanghui    change some Functions
# add logrotate & crontab delete log
################################################################################
# set some variables
date=`date +%F_%T`
# DATE=`date +Y-%m-%d`
project_name=aniu-income-admin
project_dir=aniu-income-admin
remote_user=root
remote_host=192.168.0.103
remote_port=54077
# 后期让开发修改 project_name 与 project_dir 统一名称

# define some dir
workspace=/var/lib/jenkins/workspace
project_home=$workspace/$project_dir
backup_dir=/opt/warback/$project_name/$date
wget_dir=/tmp/wget
deploylog=/var/log/deploy.log
#
################################################################################
#
function deploy() {
# make sure define folder was created when you first execute this script, then you can annotation
[ -d $backup_dir ] || mkdir -p $backup_dir
[ -d $wget_dir ] || mkdir -p $wget_dir

# backup in use project war to back_dir
# /bin/mv $Wget_dir/$Project.war $Back_dir/$Project_$Date.war

# upload project war from remote server
/usr/bin/scp -P $remote_port $remote_user@$remote_host:$project_home/target/$project_name.war $wget_dir/

for port in 8081
  do
  tomcat_port=tomcat_$port
  tomcat_home=/opt/tomcats/$tomcat_port
  webapps_dir=$tomcat_home/webapps
# shutdown tomcat
  /bin/bash $tomcat_home/bin/shutdown.sh
  tomcat_status=`ps -ef | grep $tomcat_port | grep -v grep | awk '{print $2}' | wc -l`
  if [ $tomcat_status -eq 0 ]; then
       echo "*** $date $tomcat_port auto shutdown succeed. ***"
       echo "*** $date $tomcat_port auto shutdown succeed. ***" >> $deploylog
    else
       echo "*** $date $tomcat_port auto shutdown failed, then should force shutdown $tomcat_port. ***"
       echo "*** $date $tomcat_port auto shutdown failed, then should force shutdown $tomcat_port. ***" >> $deploylog
       ps -ef | grep $tomcat_port | grep -v grep | awk '{print $2}' | xargs kill -9
  fi
# delete tomcat & start tomcat
  /bin/rm -rf $webapps_dir/$project_name*
  /bin/cp $wget_dir/$project_name.war $webapps_dir/
  /bin/bash $tomcat_home/bin/startup.sh
#  sleep three seconds waiting tomcat startup
  sleep 3
  tomcat_pid=`ps -ef | grep $tomcat_port | grep -v grep | awk '{print $2}' | wc -l`
  if [ $tomcat_pid -eq 1 ];then
     echo "***********************************************"
     echo "*** $date $tomcat_port auto start succeed ! ***"
     echo "*** $date $tomcat_port auto start succeed ! ***" >> $deploylog
     echo "***********************************************"
  else
    echo "***********************************************"
    echo "*** $date $tomcat_port auto start failed ! ***"
    echo "*** $date $tomcat_port auto start failed ! ***" >> $deploylog
    echo "***********************************************"
  fi
done
}

########################################################################
# checkrun: check tomcat service status
########################################################################
#
function checkrun() {
  # get server cuurrent ip
  ip=`ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
  for port in 8081
  do
# Get the detection URl from developer
    url=api/v2/video/commend?channelid=100211&clienttype=2&devid=800001&pno=1&productid=004&psize=3&time=20151110141945&type=2&sign=51c2e405b3e808256e209a9f44a35058
    checkurl="http://$ip:$port/$project_name/$url"
    status_code=`curl -o /dev/null -m 10 --connect-timeout 10 -s -w %{http_code} $checkurl`
  if [ "$status_code" = "200" ]; then
       echo "*** $date deployment service $ip $port start succeed. ***"
       echo "*** $date deployment service $ip $port start succeed. ***" >> $deploylog
    else
       echo "*** $date deployment service $ip $port start failed. ***"
       echo "*** $date deployment service $ip $port start failed. ***" >> $deploylog
  fi
done
}

# set main functions
function main() {
  # first execute function deploy
  deploy
  echo "*** sleep 30 second waiting for service restart. ***"
  sleep 30
  echo "*** to determine whether the deployment service start correctly. *** "
  echo "---------------------------------------------------------------------"
  # then execute function checkrun make sure tomcat service running correctly
  checkrun
}

# call main function
main
