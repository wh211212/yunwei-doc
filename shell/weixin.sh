#!/bin/bash
#############################################################
# SCRIPT_NAME:weixin.sh
# Function: send message from weixin for zabbix monitor
# Author: hwang@aniu.tv
# Changelog:
# 2017-03-21  wanghui   add db-alert
#############################################################
#
CropID='wx11ac451376ae0e98'
Secret='V4nZFFnLpYBH8oFxsQmEzb3m3OjiyFJ9uMujF0JRDORmelE01iVyg6l60TPbK1wS'
GURL="https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=$CropID&corpsecret=$Secret"
Gtoken=$(/usr/bin/curl -s -G "$GURL" | awk -F\" '{print $4}')

PURL="https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=$Gtoken"
function body() {
        local int AppID=11                          #企业号中的应用id
        local UserID=@all                           #部门成员id，zabbix中定义的微信接收者
        local PartyID=7                             #部门id，定义了范围，组内成员都可接收到消息
        local Msg=$(echo "$@" | cut -d" " -f3-)     #过滤出zabbix传递的第三个参数
        printf '{\n'
        printf '\t"touser": "'"$UserID"\"",\n"
        printf '\t"toparty": "'"$PartyID"\"",\n"
        printf '\t"msgtype": "text",\n'
        printf '\t"agentid": "'" $AppID "\"",\n"
        printf '\t"text": {\n'
        printf '\t\t"content": "'"$Msg"\""\n"
        printf '\t},\n'
        printf '\t"safe":"0"\n'
        printf '}\n'
}

/usr/bin/curl --data-ascii "$(body $1 $2 $3)" $PURL
#
