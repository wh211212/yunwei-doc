#---------------------------------------
# Functions: deploy java project 
# Changelog:
# 2017-08-01 wanghui initial
#---------------------------------------
# define variables
Workspace=/var/lib/jenkins/workspace
Project_home=aniu-income

# mve test & deploy income project
cd $WORKSPACE/aniu-income-base && mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am -Ponline || exit 0 
cd $WORKSPACE/aniu-income-db && mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am -Ponline || exit 0
cd $WORKSPACE/aniu-income-service && mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am -Ponline || exit 0
cd $WORKSPACE/aniu-income-api && mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am -Ponline || exit 0
cd $WORKSPACE/aniu-income-admin && mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am -Ponline || exit 0