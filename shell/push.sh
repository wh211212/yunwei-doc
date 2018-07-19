#!/bin/bash
######################################################
# FUncitons: push dockerfile repo to wanghui github
# Maintainers: wanghui yunwei@aniu.tv
# ChangeLog:
# 2018-03-06 shaonbean initial
#####################################################
# set -xe
# push

GIT=$(which git)
cd /home/wh/yunwei/zabbix && $GIT push wang master
