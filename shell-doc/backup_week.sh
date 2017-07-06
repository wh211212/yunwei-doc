#!/bin/bash
# ==============================================================================
# Function: 备份脚本
# ChangeLog:
# 2017-07-06 shaonbean@qq.com initial
# ==============================================================================
# 定义需要备份的目录
# basedir=存储此脚本所备份数据的目录
basedir=/backup/weekly

# ==============================================================================
# 定义脚本运行的环境变量
PATH=/bin:/usr/bin:/sbin:/use/sbin;
export PATH
export LANG=C

# 设置要备份的服务的配置文件，以及备份的目录
etc=&basedir/etc
www=&basedir/www
opt=&basedir/opt

# 判断目录是否存在。不存在创建
for dirs in $etc $www $opt
do
  [ ! -d "$dirs"] && mkdir -p $dirs
done

# 1.备份系统主要服务的配置文件，全备/etc
cp -a /data/www   $www
cp -a /opt        $opt
cp -a /etc        $etc
cd /
  tar -jpc -f $etc/etc.tar.bz2 /etc

@ 2. 用户参数备份  
