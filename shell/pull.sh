#!/bin/bash
######################################################
# FUncitons: checkout dockerfile repo form aniu gitlab
# Maintainers: wanghui yunwei@aniu.tv
# ChangeLog:
# 2018-03-06 shaonbean initial
#####################################################
# set -xe
# checkout

GIT=$(which git)
cd /home/wh/yunwei/zabbix && $GIT stash && $GIT pull origin master
