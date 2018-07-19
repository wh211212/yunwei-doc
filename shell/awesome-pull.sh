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
cd /home/wh/yunwei/awesome-cloudnative-cn && $GIT stash && $GIT pull origin master


cd /home/wh/yunwei/awesome-windows-cn && $GIT stash && $GIT pull origin master
