#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2017/3/15 18:44
# @Author  : shaonbean
# @Site    : http://blog.csdn.net/wh211212
# @File    : wechat.py
# @Software: PyCharm
import urllib,urllib2
import json
import sys
import simplejson
def gettoken():
    #微信企业号中“设置--功能--权限管理--管理员”可以找到
    CropID='wxeec7c2e818b96031'
    Secret='BKHYofcpZzvCV0rBYfkdYe40lkoj5wTuEwI7OIryOzsiBwrfoFzNnYqACxf3wG7x'
    GURL="https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid="+CropID+"&corpsecret="+Secret
    token_file = urllib2.urlopen(GURL)
    token_data = token_file.read().decode('utf-8')
    token_json = json.loads(token_data)
    token_json.keys()
    token = token_json['access_token']
    return token
def senddata(access_token,user,content):
    PURL="https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token="+access_token
    send_values = {
        "touser":user,      #企业号中的用户帐号，在zabbix用户Media中配置。
        "msgtype":"text",   #消息类型。
        "agentid":"1",        #企业号中的应用id（根据自己的应用更改）
        "text":{
            "content":content
           },
        "safe":"0"
        }
    send_data = json.dumps(send_values, ensure_ascii=False)
    send_request = urllib2.Request(PURL, send_data)
    response = json.loads(urllib2.urlopen(send_request).read())
    print str(response)

if __name__ == '__main__':
    user = str(sys.argv[1])   #zabbix传过来的第一个参数（用户）
    content = str(sys.argv[3])  #zabbix传过来的第三个参数（内容）
    accesstoken = gettoken()
    senddata(accesstoken,user,content)
