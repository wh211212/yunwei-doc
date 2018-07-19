#!/bin/bash
#----------------------------------
# Functions: git push remote github
# Auther: wanghui
#----------------------------------
# 
cd /home/wh/gitlab/yunwei-doc/ && git stash && git pull origin master && git stash clear
if [ $? -eq 0 ];then
  git push -u wang master
  else
  echo "git pull form master error!"
fi
