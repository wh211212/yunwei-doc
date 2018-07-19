#!/bin/bash
###########################################
# send api errors log to repo server
# Changelog:
# 2018-05-07 wanghui initial
###########################################
# set -x
YESTERDAY=`date -d yesterday +"%Y-%m-%d"`

IFCONFIG_BIN=$(which ifconfig)

PROJECT=aniuapi

PORTLIST=(7081 7082 7083)

# define functions
function apierrors() {

  for PORT in ${PORTLIST[@]};
    do
    IPADDR=`$IFCONFIG_BIN | grep 'inet' | grep -v '127.0.0.1' | awk '{ print $2}'`    

    tomcat_port=tomcat-$PORT
    tomcat_home=/data/tomcats/${tomcat_port}
    yesterday_api_slow=$tomcat_home/logs/$PROJECT-$PORT-slow.txt 

   # 获取前一天接口响应大于5秒的日志
   # sed -n "/${YESTERDAY} [0-24]/,/${YESTERDAY} [0-24]/p" $api_error > $yesterday_api_slow
    awk '$NF>5' $tomcat_home/logs/localhost_access_log.${YESTERDAY}.txt > $yesterday_api_slow

  # 发送接口错误日志到邮件服务器（192.168.0.222）
    REPO_SERVER=192.168.0.99
    REPO_SERVER_PORT=21212
    REPO_SERVER_USER=root
    
    REPO_API_ERRORS_DIR=/var/www/html/log/$PROJECT/$IPADDR/$YESTERDAY

    scp -P $REPO_SERVER_PORT $yesterday_api_slow $REPO_SERVER_USER@$REPO_SERVER:$REPO_API_ERRORS_DIR/
    
done

    #scp -P $REPO_SERVER_PORT -r $API_ERRORS_DIR $REPO_SERVER_USER@$REPO_SERVER:$API_ERRORS_DIR
    
}

# call apierrors
apierrors
