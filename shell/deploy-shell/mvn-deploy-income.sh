#!/bin/bash
#---------------------------------
# Functions: deploy java project
# Changelog:
# 2017-08-01 wanghui initial
#---------------------------------
# define variables
Project_name=aniu-nkm
Workspace=/var/lib/jenkins/workspace/${Project_name}
# mve test project
Cmd1='mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -q'
Cmd2='mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -Ponline'
cd $Workspace/aniu-income-base && $Cmd1 || exit 1
cd ${Workspace}/aniu-income-db && ${Cmd1} || exit 1
cd ${Workspace}/aniu-nkm-service && ${Cmd1} || exit 1
cd ${Workspace}/aniu-income-api && ${Cmd2} || exit 1
cd ${Workspace}/aniu-income-admin && ${Cmd2} || exit 1

