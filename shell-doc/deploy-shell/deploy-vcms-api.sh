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
date=`date +%F_%T`
# DATE=`date +Y-%m-%d`
project_name=aniu-vcms-api
project_dir=aniu-vcms
remote_user=root
remote_host=192.168.0.103
remote_port=54077

# 后期让开发修改 project_name 与 project_dir 统一名称
# define some dir
workspace=/var/lib/jenkins/workspace
project_home=$workspace/$project_dir
backup_dir=/data/warback/$project_name
wget_dir=/tmp/wget
deploylog=/var/log/deploy.log
# define array
portlist=(8081)
# print array len
# echo ${#portlist[@]}
# use
# for port in ${portlist[@]};do;echo $port;done
#-------------------------------------------------------------------------------
function deploy() {
# make sure define folder was created when you first execute this script, then you can annotation
[ -d $backup_dir ] || mkdir -p $backup_dir
[ -d $wget_dir ] || mkdir -p $wget_dir

# backup in use project war to back_dir
/bin/mv $wget_dir/$project_name.war $backup_dir/${project_name}_${date}.war

# upload project war from remote server
/usr/bin/scp -P $remote_port $remote_user@$remote_host:$project_home/$project_name/target/$project_name.war $wget_dir/

for port in ${portlist[@]};
  do
  tomcat_port=tomcat-$port
  tomcat_home=/data/tomcats/${tomcat_port}
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
  /bin/rm -rf $webapps_dir/$project_name*
  /bin/cp $wget_dir/$project_name.war $webapps_dir/
  /bin/bash $tomcat_home/bin/startup.sh
#  sleep three seconds waiting tomcat startup
  sleep 3
  tomcat_pid=`ps -ef | grep $tomcat_port | grep -v grep | awk '{print $2}' | wc -l`
  if [ $tomcat_pid -eq 1 ];then
     echo "*************************************************************"
     echo "*** $date $tomcat_port auto start succeed ! ***"
     echo "*** $date $tomcat_port auto start succeed ! ***" >> $deploylog
     echo "*************************************************************"
  else
    echo "******************************************************************"
    echo -e "*** \033[31m $date $tomcat_port auto start failed ! \033[0m ***"
    echo "*** $date $tomcat_port auto start failed ! ***"       >> $deploylog
    echo "*******************************************************************"
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

  for port in ${portlist[@]}
  do
# Get the detection URl from developer
    url=api/getVideolist-2?publish_date_from=2016-5-24&publish_date_to=2016-5-24&page_size=1&page_idx=0
    checkurl="http://$ip:$port/$project_name/$url"
    status_code=`curl -o /dev/null -m 10 --connect-timeout 10 -s -w %{http_code} $checkurl`
  if [ "$status_code" = "200" ]; then
       echo "*** $date deployment service $ip $port start succeed. ***"
       echo "---------------------------------------------------------"
       echo "*** $date deployment service $ip $port start succeed. ***" >> $deploylog
    else
       echo -e "*** \033[31m $date deployment service $ip $port start failed. \033[0m ***"
       echo "--------------------------------------------------------"
       echo "*** $date deployment service $ip $port start failed. ***" >> $deploylog
  fi
done
}

# set main functions
function main() {
  # first execute function deploy
  deploy
  sleep 30
  echo "*** sleep 30 second waiting for service restart. ***"
  checkrun
}

# call main function
main
