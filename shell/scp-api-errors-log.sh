#!/bin/bash
###########################################
# scp api errors log to yunwei backup
# Changelog:
# 2018-05-07 wanghui initial
###########################################
# set -x
YESTERDAY=`date -d yesterday +"%Y-%m-%d"`
YESTERDAY1=`date -d yesterday +"%Y-%m-%d 00"`
YESTERDAY2=`date -d yesterday +"%Y-%m-%d 24"`

PROJECT=aniuapi

PORTLIST=(7081 7082 7083)

# define functions
function apierrors() {

  for PORT in ${PORTLIST[@]};
    do
    
    IPADDR=`/usr/sbin/ifconfig | grep 'inet' | grep -v '127.0.0.1' | awk '{ print $2}'`

    tomcat_port=tomcat-$PORT
    tomcat_home=/data/tomcats/${tomcat_port}
    api_error=$tomcat_home/logs/aniuapi-error.log
    yesterday_api_error=$tomcat_home/logs/$YESTERDAY-$IPADDR-$PORT-$PROJECT-errors.txt 

  # 获取接口前一天错误日志
    echo $YESTERDAY1
    #sed -n "/${YESTERDAY1}/,/${YESTERDAY2}/p" $api_error > $yesterday_api_error
    sed -n "/${YESTERDAY} [0-24]/,/${YESTERDAY} [0-24]/p" $api_error > $yesterday_api_error

  # 发送接口错误日志到邮件服务器（192.168.0.222）
    EMAIL_SERVER=192.168.0.222
    EMAIL_SERVER_PORT=21212
    EMAIL_SERVER_USER=root
    
    API_ERRORS_DIR=/var/log/tomcat/api-errors/$IPADDR

    [ -d $API_ERRORS_DIR ] || mkdir -p $API_ERRORS_DIR

    cp $yesterday_api_error $API_ERRORS_DIR

    scp -P $EMAIL_SERVER_PORT $API_ERRORS_DIR/$YESTERDAY-$IPADDR-$PORT-$PROJECT-errors.txt $EMAIL_SERVER_USER@$EMAIL_SERVER:$API_ERRORS_DIR/$YESTERDAY-$IPADDR-$PORT-$PROJECT-errors.txt
    
done
}

# call apierrors
apierrors
