#!/bin/bash
##################################################################################################
#    Description:
#    - rollback java project war
##################################################################################################
#    CHANGELOG
#    2016-12-08    shaon              initial create
#    2017-08-015    wanghui           change somethings
##################################################################################################
# 到备份目录下查看要回滚的版本
echo "three last deploy version"
war_back=/data/warback/aniu-stock
ls -ltr $warback | tail -3 > /tmp/version.txt
cat /tmp/version.txt
read -p "which version war you want rollback: " version

back_version=$war_back/$version

# 通过参数传递要回复到那个版本  bash /data/script/rollback.sh /data/war_back/aniu-stock_2016-12-08-15:31:04.war
ps -ef | grep tomcat_8083 | grep -v grep | awk '{print $2}' | sed -e "s/^/kill -9 /g" | sh -
rm -rf /data/tomcat_8083/webapps/aniu-stock
rm -rf /data/tomcat_8083/webapps/aniu-stock.war
cp $back_version /data/tomcat_8083/webapps/aniu-stock.war
/data/tomcat_8083/bin/startup.sh

/data/tomcat_8082/bin/shutdown.sh
ps -ef | grep tomcat_8082 | grep -v grep | awk '{print $2}' | sed -e "s/^/kill -9 /g" | sh -
rm -rf /data/tomcat_8082/webapps/aniu-stock
rm -rf /data/tomcat_8082/webapps/aniu-stock.war
cp $back_version /data/tomcat_8082/webapps/aniu-stock.war
/data/tomcat_8082/bin/startup.sh

/data/tomcat_8084/bin/shutdown.sh
ps -ef | grep tomcat_8084 | grep -v grep | awk '{print $2}' | sed -e "s/^/kill -9 /g" | sh -
rm -rf /data/tomcat_8084/webapps/aniu-stock
rm -rf /data/tomcat_8084/webapps/aniu-stock.war
cp $back_version /data/tomcat_8084/webapps/aniu-stock.war
/data/tomcat_8084/bin/startup.sh
