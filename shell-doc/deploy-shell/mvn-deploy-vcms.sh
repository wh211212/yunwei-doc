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
cd ${Workspace}/aniu-vcms-api && ${Cmd2} || exit 1
cd ${Workspace}/aniu-vcms-synch && ${Cmd2} || exit 1
cd ${Workspace}/aniu-vcms-admin && ${Cmd2} || exit 1
