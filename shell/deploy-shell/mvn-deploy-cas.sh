#!/bin/bash
#---------------------------------------
# Functions: deploy java project 
# Changelog:
# 2017-08-01 wanghui initial
#---------------------------------------
# define variables
export JAVA_HOME=/var/lib/jenkins/tools/hudson.model.JDK/SE_JDK_1.7
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
echo $JAVA_HOME
java --version

Workspace=/var/lib/jenkins/workspace
Project_home=old-project

# mve test project 
cd $WORKSPACE/aniu-cas-dependency && mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am || exit 0
cd $WORKSPACE/aniu-cas-module && mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am  || exit 0 
cd $WORKSPACE/aniu-cas-dao && mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am || exit 0
cd $WORKSPACE/aniu-cas-service && mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am || exit 0
cd $WORKSPACE/aniu-cas-core && mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am || exit 0
cd $WORKSPACE/aniu-cas-api && mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am -Ponline || exit 0
cd $WORKSPACE/aniu-cas-admin && mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am -Ponline || exit 0