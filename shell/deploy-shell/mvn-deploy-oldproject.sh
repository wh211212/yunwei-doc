#!/bin/bash
#---------------------------------
# Functions: deploy java project
# Changelog:
# 2017-08-01 wanghui initial
#---------------------------------
# define variables
Project_name=old-project
Workspace=/var/lib/jenkins/workspace/${Project_name}
# mve test project
Cmd1='mvn clean deploy -B -e -U -Dmaven.test.skip=true -q'
Cmd2='mvn clean deploy -B -e -U -Dmaven.test.skip=true'
cd ${Workspace}/tysx-mms-base && ${Cmd1} || exit 1
cd ${Workspace}/tysx-mms-db && ${Cmd1} || exit 1
cd ${Workspace}/tysx-mms-service && ${Cmd1} || exit 1
cd ${Workspace}/tysx-mms-admin && ${Cmd2} || exit 1
cd ${Workspace}/aniu-api && ${Cmd2} || exit 1
cd ${Workspace}aniu-admin && ${Cmd2} || exit 1
