#!/bin/bash
#-------------------------------------------------------------------------------
# Functions: auto deploy api project, base on tomcat
#-------------------------------------------------------------------------------
# ChangeLog:
# 2016-12-19    wanghui    initial create
# 2017-06-27    wanghui    change some Functions
# 2017-08-04    wanghui    add array use
# 2018-04-26    wanghui    optimization
# add logrotate & crontab delete log & add iuput color
#-------------------------------------------------------------------------------
# set -x # for debug

DATE=`date +%F_%T`
DATETIME=`date +%Y-%m-%d`

# jenkins & package config
project_name=aniu-api
project_dir=old-project
project=aniuapi
remote_user=root
remote_host=192.168.0.99
remote_port=21212

# project package dir
workspace=/var/lib/jenkins/workspace
project_home=$workspace/$project_dir
backup_dir=/data/warback/$project_name
wget_dir=/tmp/wget

deploylog=/var/log/tomcat/deploy-${DATETIME}.log

# define port list array
portlist=(7081 7082 7083)

# print array len
# echo ${#portlist[@]}
# use
# for port in ${portlist[@]};do;echo $port;done

# make sure define folder was created when you first execute this script, then you can annotation
[ -d $backup_dir ] || mkdir -p $backup_dir
[ -d $wget_dir ] || mkdir -p $wget_dir

#-------------------------------------------------------------------------------
# define functions
function deploy() {

# backup in use project war to back_dir
/bin/mv $wget_dir/$project.war $backup_dir/${project}_${DATE}.war

# upload project war from remote server
/usr/bin/scp -P $remote_port $remote_user@$remote_host:$project_home/$project_name/target/$project.war $wget_dir/

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

# delete tomcat dir & start tomcat
  rm -rf $webapps_dir/$project*
  cp $wget_dir/$project.war $webapps_dir/
  bash $tomcat_home/bin/startup.sh
  sleep 3

  tomcat_pid=`ps -ef | grep $tomcat_port | grep "[o]rg.apache.catalina.startup.Bootstrap start" | grep -v grep | awk '{print $2}' | wc -l`
  if [ $tomcat_pid -eq 1 ];then
      echo "*************************************************************"
      echo "*** $DATE $tomcat_port auto start succeed ! ***"
      echo "*** $DATE $tomcat_port auto start succeed ! ***" >> $deploylog
      echo "*************************************************************"
    else
      echo "*************************************************************"
      echo "*** $DATE $tomcat_port auto start failed ! ***"
      echo "*** $DATE $tomcat_port auto start failed ! ***"  >> $deploylog
      echo "*************************************************************"
  fi
done
}

########################################################################
# checkrun: check tomcat service status
########################################################################

function checkrun() {
  # get server cuurrent ip
  ip=`ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`

  for port in ${portlist[@]}
  do
# Get the detection URl from developer
    url="api/v2/video/commend?channelid=100211&clienttype=2&devid=800001&pno=1&productid=004&psize=3&time=20151110141945&type=2&sign=51c2e405b3e808256e209a9f44a35058"
    checkurl="http://$ip:$port/$project/$url"
    status_code=`curl -o /dev/null -m 10 --connect-timeout 10 -s -w %{http_code} $checkurl`
  if [ "$status_code" = "200" ]; then
       echo "*** $DATE deployment service $ip $port start succeed. ***"
       echo "---------------------------------------------------------"
       echo "*** $DATE deployment service $ip $port start succeed. ***" >> $deploylog
    else
       echo "*** $DATE deployment service $ip $port start failed.  ***"
       echo "--------------------------------------------------------"
       echo "*** $DATE deployment service $ip $port start failed.  ***" >> $deploylog
  fi
done
}

# set main functions
function main() {
  # first execute function deploy
  deploy
}

# call main function
main
