#!/opt/remi/php71/root/usr/bin/php
############################################################################################################### 
# Function: send messages to weixin office accounts
# Changelog:
# 2017-03-21  hwang@aniu.tv  add web-alert
###################################################
#
<?php
define("CorpID", "wx11ac451376ae0e98");
define("Secret", "HHbybAZIctuApeq0ZAb24hIB0vpUg5_VIXBl-oWZe8pHB8GtGiYWRU10-qk0lv3L");
//获取access_token
$token_access_url = "https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=" . CorpID . "&corpsecret=" . Secret;
$res = file_get_contents($token_access_url);
$result = json_decode($res, true); 
$access_token = $result['access_token'];

$post_data = array (
        "touser" =>"@all",//发送给所有能接收到消息的人
        "toparty" =>"",
        "totag"=>"",
        "msgtype" =>"text",
        "agentid" => "$argv[12]", //应用ID
        "text" =>
                array (
                "content" => "$argv[3]",//zabbix传入的告警内容
                ),
        "safe" => "0",
        );
$post_data = json_encode($post_data , JSON_UNESCAPED_UNICODE);
$url="https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=$access_token";
$ch = curl_init();
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_URL,$url);
curl_setopt($ch, CURLOPT_POSTFIELDS, $post_data);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, FALSE);
$result=curl_exec($ch);
echo curl_error($ch);
curl_close($ch);
print_r($result);
?>
