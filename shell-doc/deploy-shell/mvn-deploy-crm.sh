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
cd $WORKSPACE/aniu-crm-dependency && mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am || exit 0
cd $WORKSPACE/aniu-crm-module && mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am  || exit 0 
cd $WORKSPACE/aniu-crm-dao && mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am || exit 0
cd $WORKSPACE/aniu-crm-service && mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am || exit 0
cd $WORKSPACE/aniu-crm-core && mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am || exit 0
cd $WORKSPACE/aniu-crm-api && mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am -Ponline || exit 0
cd $WORKSPACE/aniu-crm-admin && mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am -Ponline || exit 0