#!/usr/bin/env bash
# ***********************************************
# @Time     : 2018/4/26 18:29
# @Author   : shaonbean@qq.com
# @Software : PyCharm
# @Blog     : http://blog.csdn.net/wh211212
# ***********************************************
#
warback_dir=/data/warback/aniu-api

[ -d ${warback_dir} ] && find /data/warback/aniu-api/* -mtime +7 -exec rm -rf {} \;

# define port list array
portlist=(7081 7082 7083)

# define functions
function removeoldlog() {

for port in ${portlist[@]};
  do
  tomcat_port=tomcat-$port
  tomcat_home=/data/tomcats/${tomcat_port}

  [ -d ${tomcat_home} ] && find ${tomcat_home}/logs/* -mtime +10 -exec rm -rf {} \;

  done
}

removeoldlog
