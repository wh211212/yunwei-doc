#!/bin/bash
#---------------------------------------
# Functions: deploy java project 
# Changelog:
# 2017-08-01 wanghui initial
#---------------------------------------
# define variables
Workspace=/var/lib/jenkins/workspace
Project_home=market-stock

# mve test project 
cd $WORKSPACE/aniu-stock-api && mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am -Ponline || exit 0 
cd $WORKSPACE/aniu-algoquote-api && mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am -Ponline || exit 0
cd $WORKSPACE/aniu-algoquote-admin && mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am -Ponline || exit 0