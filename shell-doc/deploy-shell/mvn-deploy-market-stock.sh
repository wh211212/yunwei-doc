#!/bin/bash
#---------------------------------
# Functions: deploy java project
# Changelog:
# 2017-08-01 wanghui initial
#---------------------------------
# define variables
Project_name=market-stock
Workspace=/var/lib/jenkins/workspace/${Project_name}
# mve test project
Cmd1='mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -q'
Cmd2='mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -Ponline'
# execute shell
cd ${Workspace}/aniu-stock-api && ${Cmd2} || exit 1
cd ${Workspace}/aniu-algoquote-api && ${Cmd2} || exit 1
cd ${Workspace}/aniu-algoquote-admin && ${Cmd2} || exit 1