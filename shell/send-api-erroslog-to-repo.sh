#!/bin/bash
###########################################
# send api errors log to repo server
# Changelog:
# 2018-05-07 wanghui initial
###########################################
# set -x
YESTERDAY=`date -d yesterday +"%Y-%m-%d"`

PROJECT=aniuapi

IFCONFIG=$(which ifconfig)

PORTLIST=(7081 7082 7083)

# define functions
function apierrors() {

  for PORT in ${PORTLIST[@]};
    do
    
    IPADDR=`$IFCONFIG | grep 'inet' | grep -v '127.0.0.1' | awk '{ print $2}'`

    tomcat_port=tomcat-$PORT
    tomcat_home=/data/tomcats/${tomcat_port}
    api_error=$tomcat_home/logs/aniuapi-error.log
    yesterday_api_error=$tomcat_home/logs/$PROJECT-$PORT-errors.txt 

  # 获取接口前一天错误日志
    sed -n "/${YESTERDAY} [0-24]/,/${YESTERDAY} [0-24]/p" $api_error > $yesterday_api_error

  # 发送接口错误日志到邮件服务器（192.168.0.222）
    REPO_SERVER=192.168.0.99
    REPO_SERVER_PORT=21212
    REPO_SERVER_USER=root
    
    API_ERRORS_DIR=/var/www/html/log/$PROJECT/$IPADDR/$YESTERDAY

    [ -d $API_ERRORS_DIR ] || mkdir -p $API_ERRORS_DIR

    cp $yesterday_api_error $API_ERRORS_DIR

    #scp -P $REPO_SERVER_PORT $API_ERRORS_DIR/$YESTERDAY-$IPADDR-$PORT-$PROJECT-errors.txt $REPO_SERVER_USER@$REPO_SERVER:$API_ERRORS_DIR/$YESTERDAY-$IPADDR-$PORT-$PROJECT-errors.txt
    
done

    scp -P $REPO_SERVER_PORT -r $API_ERRORS_DIR $REPO_SERVER_USER@$REPO_SERVER:$API_ERRORS_DIR
    
}

# call apierrors
apierrors
