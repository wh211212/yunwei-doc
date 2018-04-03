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
# execute shell
cd ${Workspace}/aniu-product-dao && ${Cmd1} || exit 1
cd ${Workspace}/aniu-product-service && ${Cmd1} || exit 1
cd ${Workspace}/aniu-product-core && ${Cmd1} || exit 1
cd ${Workspace}/aniu-product-api && ${Cmd2} || exit 1
cd ${Workspace}/aniu-service-product && ${Cmd2} || exit 1