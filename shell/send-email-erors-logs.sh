#!/bin/bash
##########################################################################
# Script Name: auto_backup_gitlabdata.sh
# Author: wanghui
# Email: yunwei@aniu.tv
#########################################################################
# set 0x
API_ERRORS_DIR=/var/log/tomcat/api-errors

# 接口时间格式
YESTERDAY=`date -d yesterday +"%Y-%m-%d"`

# 邮件发送给谁
MailToUser1=hwang@aniu.tv
MailToUser2=yjiang@aniu.tv
MailToUser3=crshen@aniu.tv
MailToUser4=mwu@aniu.tv
MailToUser5=lwang@aniu.tv
MailToUser6=glshen@aniu.tv

function aniuapi() {
  # aniu-api
  PROJECT=aniuapi

  Aniuapi_Server1=192.168.0.32
  MailContent1=$API_ERRORS_DIR/$Aniuapi_Server1/$YESTERDAY-$Aniuapi_Server1-7081-$PROJECT-errors.txt
  MailContent2=$API_ERRORS_DIR/$Aniuapi_Server1/$YESTERDAY-$Aniuapi_Server1-7082-$PROJECT-errors.txt
  MailContent3=$API_ERRORS_DIR/$Aniuapi_Server1/$YESTERDAY-$Aniuapi_Server1-7083-$PROJECT-errors.txt

  echo "附件为${PROJECT}所有端口错误日志" | mail -s "${YESTERDAY} ${PROJECT} Errors Log." -a "$MailContent1" -a "$MailContent2" -a "$MailContent3" hwang@aniu.tv -c $MailToUser2 $MailToUser3 $MailToUser4 $MailToUser5 $MailToUser6

  }

function zjtapi() {
  # zjt-api
  PROJECT=zjtapi

  Aniuapi_Server1=192.168.0.32
  MailContent1=$API_ERRORS_DIR/$Aniuapi_Server1/$YESTERDAY-$Aniuapi_Server1-7081-$PROJECT-errors.txt
  MailContent2=$API_ERRORS_DIR/$Aniuapi_Server1/$YESTERDAY-$Aniuapi_Server1-7082-$PROJECT-errors.txt
  MailContent3=$API_ERRORS_DIR/$Aniuapi_Server1/$YESTERDAY-$Aniuapi_Server1-7083-$PROJECT-errors.txt

  echo "附件为${PROJECT}所有端口错误日志" | mail -s "${YESTERDAY} ${PROJECT} Errors Log." -a "$MailContent1" -a "$MailContent2" -a "$MailContent3" hwang@aniu.tv -c $MailToUser2 $MailToUser3 $MailToUser4 $MailToUser5 $MailToUser6

  }

function njdxapi() {
  # njdx-api
  PROJECT=njdxapi

  Aniuapi_Server1=192.168.0.30
  MailContent1=$API_ERRORS_DIR/$Aniuapi_Server1/$YESTERDAY-$Aniuapi_Server1-7081-$PROJECT-errors.txt
  MailContent2=$API_ERRORS_DIR/$Aniuapi_Server1/$YESTERDAY-$Aniuapi_Server1-7082-$PROJECT-errors.txt
  MailContent3=$API_ERRORS_DIR/$Aniuapi_Server1/$YESTERDAY-$Aniuapi_Server1-7083-$PROJECT-errors.txt

  echo "附件为${PROJECT}所有端口错误日志" | mail -s "${YESTERDAY} ${PROJECT} Errors Log." -a "$MailContent1" -a "$MailContent2" -a "$MailContent3" hwang@aniu.tv -c $MailToUser2 $MailToUser3 $MailToUser4 $MailToUser5 $MailToUser6

  }

function wxapi() {
  # wx-api
  PROJECT=wxapi

  Aniuapi_Server1=192.168.0.31
  MailContent1=$API_ERRORS_DIR/$Aniuapi_Server1/$YESTERDAY-$Aniuapi_Server1-7081-$PROJECT-errors.txt
  MailContent2=$API_ERRORS_DIR/$Aniuapi_Server1/$YESTERDAY-$Aniuapi_Server1-7082-$PROJECT-errors.txt
  MailContent3=$API_ERRORS_DIR/$Aniuapi_Server1/$YESTERDAY-$Aniuapi_Server1-7083-$PROJECT-errors.txt

  echo "附件为${PROJECT}所有端口错误日志" | mail -s "${YESTERDAY} ${PROJECT} Errors Log." -a "$MailContent1" -a "$MailContent2" -a "$MailContent3" hwang@aniu.tv -c $MailToUser2 $MailToUser3 $MailToUser4 $MailToUser5 $MailToUser6

}

function userapi() {
  # wx-api
  PROJECT=userapi

  Aniuapi_Server1=192.168.0.34
  MailContent1=$API_ERRORS_DIR/$Aniuapi_Server1/$YESTERDAY-$Aniuapi_Server1-7081-$PROJECT-errors.txt
  MailContent2=$API_ERRORS_DIR/$Aniuapi_Server1/$YESTERDAY-$Aniuapi_Server1-7082-$PROJECT-errors.txt
  MailContent3=$API_ERRORS_DIR/$Aniuapi_Server1/$YESTERDAY-$Aniuapi_Server1-7083-$PROJECT-errors.txt

  echo "附件为${PROJECT}所有端口错误日志" | mail -s "${YESTERDAY} ${PROJECT} Errors Log." -a "$MailContent1" -a "$MailContent2" -a "$MailContent3" hwang@aniu.tv -c $MailToUser2 $MailToUser3 $MailToUser4 $MailToUser5 $MailToUser6

}

function message-channel() {
  # wx-api
  PROJECT=message-channel

  Aniuapi_Server1=192.168.0.29
  MailContent1=$API_ERRORS_DIR/$Aniuapi_Server1/$YESTERDAY-$Aniuapi_Server1-7081-$PROJECT-errors.txt
  MailContent2=$API_ERRORS_DIR/$Aniuapi_Server1/$YESTERDAY-$Aniuapi_Server1-7082-$PROJECT-errors.txt

  echo "附件为${PROJECT}所有端口错误日志" | mail -s "${YESTERDAY} ${PROJECT} Errors Log." -a "$MailContent1" -a "$MailContent2" -a "$MailContent3" hwang@aniu.tv -c $MailToUser2 $MailToUser3 $MailTo
User4 $MailToUser5 $MailToUser6

}
# 
function main() {
  # callback 
  aniuapi
  njdxapi
  zjtapi
  wxapi
  userapi
  message-channel
}

main
