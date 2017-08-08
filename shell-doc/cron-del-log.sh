#!/bin/bash
#----------------------------------------------------------
# Functions: crontab delete log & wakback
# Changelog:
# 2017-08-04 wanghui initial create
#----------------------------------------------------------
# define variables
project=aniu-vcms-api
warback=/data/warback/$project
portlist=(8081)
# Delete the logs & war 30/60 days ago
find $warback/ -mtime +30 -name "*.war" -exec rm -rf {} \;

# add project dir
for port in ${portlist[@]};
  do
    tomcat_port=tomcat-$port
    project_dir=/data/tomcats/$tomcat_port
    find $tomcat_port/ -mtime +30 -name "*.log" -exec rm -rf {} \;
  done

# crontab
# 0 1 1 * * /bin/bash /home/wh/script/rsync_crm_concract.sh


