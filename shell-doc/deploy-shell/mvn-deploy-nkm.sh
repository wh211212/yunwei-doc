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
cd $Workspace/aniu-nkm-module && $Cmd1 || exit 1
cd ${Workspace}/aniu-nkm-dao && ${Cmd1} || exit 1
cd ${Workspace}/aniu-nkm-service && ${Cmd1} || exit 1
cd ${Workspace}/aniu-nkm-core && ${Cmd1} || exit 1
cd ${Workspace}/aniu-nkm-redis && ${Cmd1} || exit 1
cd ${Workspace}/aniu-nkm-factory && ${Cmd1} || exit 1
cd ${Workspace}/aniu-nkm-admin && ${Cmd2} || exit 2
cd ${Workspace}/aniu-nkm-api && ${Cmd2} || exit 2
cd ${Workspace}/aniu-nkm-api-task&& ${Cmd2} || exit 2