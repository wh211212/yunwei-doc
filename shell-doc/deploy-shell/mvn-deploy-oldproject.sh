#!/bin/bash
#---------------------------------------
# Functions: deploy java project 
# Changelog:
# 2017-08-01 wanghui initial
#---------------------------------------
# define variables
Workspace=/var/lib/jenkins/workspace
Project_home=old-project

# mve test project 
cd $WORKSPACE/tysx-mms-base && mvn clean  -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am
cd $WORKSPACE/tysx-mms-db && mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am
cd $WORKSPACE/tysx-mms-service && mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am
cd $WORKSPACE/tysx-mms-admin && mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am -Ponline
cd $WORKSPACE/aniu-api && mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am -Ponline
cd $WORKSPACE/aniu-admin && mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am -Ponline
