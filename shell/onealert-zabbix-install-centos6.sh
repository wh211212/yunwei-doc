#!/bin/bash
# Date : 2016年3月4日10:00:00
# Author : lijun
# Contact : lijuna@oneapm.com
# Company : www.onealert.com
# OneAlert pre install script : zabbix
YUM_URL="http://yum.110monitor.com"
USER_NAME="onealert"
YUM_PATH="/etc/yum.repos.d/onealert-agent.repo"
yellow='\e[0;33m'
green='\e[0;32m'
endColor='\e[0m'
if [ $(echo "$UID") = "0" ]; then
    sudo_cmd=''
else
    sudo_cmd='sudo'
fi
if [ -z "$AppKey" ]; then
    echo -e "${yellow}Missing AppKey end of the install command.${endColor}"
    exit 3;
fi
if [ -z "$Plugin" ]; then
    echo -e "${yellow}Missing Plugin end of the install command.${endColor}"
    exit 3;
fi

INSTALL_PROCESS_URL="http://c.110monitor.com/alert/api/escalation/agentInstall/$AppKey"
curl -d "status=creating" -o /dev/null -s $INSTALL_PROCESS_URL
$sudo_cmd mkdir -p /var/run/$USER_NAME/
$sudo_cmd mkdir -p /var/lib/$USER_NAME/
$sudo_cmd mkdir -p /var/log/$USER_NAME/
$sudo_cmd mkdir -p /etc/$USER_NAME/

egrep "^$USER_NAME" /etc/passwd >/dev/null
if [ $? -ne 0 ]; then
    $sudo_cmd useradd $USER_NAME
fi

$sudo_cmd chown -R $USER_NAME:$USER_NAME /var/run/$USER_NAME/
$sudo_cmd chown -R $USER_NAME:$USER_NAME /var/lib/$USER_NAME/
$sudo_cmd chown -R $USER_NAME:$USER_NAME /var/log/$USER_NAME/
$sudo_cmd chown -R $USER_NAME:$USER_NAME /etc/$USER_NAME/

echo -e "\033[34m\n* start installing yum sources for onealert-agent\n\033[0m"
if [ -f $YUM_PATH ];then
    $sudo_cmd rm -rf $YUM_PATH
fi
$sudo_cmd sh -c "echo -e '[onealert-agent]\nname=OneAlert repository\nbaseurl=$YUM_URL/rpm/centos/#releasever/#basearch\nenabled=1\ngpgcheck=0' > $YUM_PATH"
$sudo_cmd sed -i "s%#%$%g" $YUM_PATH
curl -d "status=pedding" -o /dev/null -s $INSTALL_PROCESS_URL
echo -e "\033[34m* installing the onealert agent package\n\033[0m\n"
$sudo_cmd yum install onealert-agent
echo -e "${green}yum install onealert agent successful!${endColor}"
curl -d "status=installed" -o /dev/null -s $INSTALL_PROCESS_URL
echo -e "start to set configuration..."
echo -e "initialize onealert agent."
$sudo_cmd /usr/bin/onealert-config --init --token $AppKey --force
echo -e "initialize onealert done."
echo -e "start add $Plugin plugin."
$sudo_cmd /usr/bin/onealert-config --add $Plugin --app-key $AppKey --force
echo -e "add $Plugin plugin is done."
echo -e "start run onealert agent..."
$sudo_cmd chkconfig --add onealert
$sudo_cmd initctl start onealert
curl -d "status=success" -o /dev/null -s $INSTALL_PROCESS_URL
