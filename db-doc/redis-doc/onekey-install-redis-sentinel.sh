#!/usr/bin/env bash
# ----------------------------------------
# Functions: onekey install redis sentinel
# Auther: shaonbean
# Changelog:
# 2017-08-22 wanghui initial
# ----------------------------------------
# syntx check
# define some variables
redis_sentinel_ip=`ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
redis_sentinel_dir=/data/redis-sentinel
redis_dir=/usr/local/redis
version=4.0.1
#redis_pid_dir=/var/run/redis
redis_log=/var/log/redis
#redis_rdb_aof_dir=/var/lib/redis
#
#[ -d $redis_pid_dir ] || mkdir $redis_pid_dir
[ -d $redis_log ] || mkdir $redis_log

# upgrade os && install dev tools
yum update -y && yum groupinstall -y "Development Tools" && yum -y install tcl

# download latest redis
wget http://download.redis.io/releases/redis-$version.tar.gz -P /usr/local/src

# compress && make
cd /usr/local/src && tar zxvf redis-$version.tar.gz -C /usr/local/
cd /usr/local/ && ln -sv redis-$version redis && cd redis && make && taskset -c 1 sudo make test

# config sysctl.conf
echo 512 > /proc/sys/net/core/somaxconn
sysctl vm.overcommit_memory=1

# config three redis
#portlist=(9000,9001,9002)
mkdir -pv $redis_sentinel_dir/{9000,9001,9002}
# copy excute command
\cp $redis_dir/src/{redis-server,redis-sentinel} $redis_sentinel_dir/9000/
\cp $redis_dir/src/{redis-server,redis-sentinel} $redis_sentinel_dir/9001/
\cp $redis_dir/src/{redis-server,redis-sentinel} $redis_sentinel_dir/9002/
# copy redis.conf & sentinel.conf
\cp $redis_dir/{redis.conf,sentinel.conf} $redis_sentinel_dir/9000/
\cp $redis_dir/{redis.conf,sentinel.conf} $redis_sentinel_dir/9001/
\cp $redis_dir/{redis.conf,sentinel.conf} $redis_sentinel_dir/9002/

# config redis.conf
# example by /data/redis-sentinel/9000/redis.conf
sed -i "s/bind 127.0.0.1/bind $redis_sentinel_ip/g" $redis_sentinel_dir/9000/redis.conf
sed -i 's/protected-mode\ yes/protected-mode\ no/g' $redis_sentinel_dir/9000/redis.conf
#sed -i "s/\/var\/run\/redis_6379.pid/\/var\/run\/redis/redis_9000.pid/g" $redis_sentinel_dir/9000/redis.conf
sed -i 's/6379/9000/g' $redis_sentinel_dir/9000/redis.conf
sed -i 's/daemonize no/daemonize yes/g' $redis_sentinel_dir/9000/redis.conf
sed -i 's/appendonly no/appendonly yes/g' $redis_sentinel_dir/9000/redis.conf
#sed -i 's/logfile ""/logfile \"\/data\/redis-sentinel\/9000\"/g' $redis_sentinel_dir/9000/redis.conf
sed -i "s/logfile \"\"/logfile \/var\/log\/redis\/redis_9000.log/g" $redis_sentinel_dir/9000/redis.conf
#sed -i 's/dir \.\//dir \/data\/redis-sentinel\/9000\//g' $redis_sentinel_dir/9000/redis.conf
#sed -i 's/appendonly.aof/\/data\/redis-sentinel\/9000\/appendonly.aof/g' $redis_sentinel_dir/9000/redis.conf
# rename config for secuirty
#rename-command SHUTDOWN REDIS_SHUTDOWN
#rename-command FLUSHDB REDIS_FLUSHDB
#rename-command FLUSHALL REDIS_FLUSHALL
#rename-command KEYS REDIS_KEYS
#echo 'rename-command CONFIG REDIS_CONFIG' >> $redis_sentinel_dir/9000/redis.conf
#echo 'rename-command FLUSHALL REDIS_FLUSHALL' >> $redis_sentinel_dir/9000/redis.conf
#echo 'rename-command FLUSHDB REDIS_FLUSHDB' >> $redis_sentinel_dir/9000/redis.conf

#
cp $redis_sentinel_dir/9000/redis.conf $redis_sentinel_dir/9001/redis.conf
cp $redis_sentinel_dir/9000/redis.conf $redis_sentinel_dir/9002/redis.conf
sed -i 's/9000/9001/g' $redis_sentinel_dir/9001/redis.conf
echo "slaveof $redis_sentinel_ip 9000" >> $redis_sentinel_dir/9001/redis.conf
sed -i 's/9000/9002/g' $redis_sentinel_dir/9002/redis.conf
echo "slaveof $redis_sentinel_ip 9000" >> $redis_sentinel_dir/9001/redis.conf

# ln redis-server &  redis-sentinel
cp $redis_dir/src/{redis-server,redis-sentinel,redis-cli} /usr/local/sbin/

# start redis
#$redis_sentinel_dir/9000/redis-server $redis_sentinel_dir/9000/redis.conf
#$redis_sentinel_dir/9001/redis-server $redis_sentinel_dir/9001/redis.conf
#$redis_sentinel_dir/9002/redis-server $redis_sentinel_dir/9002/redis.conf
cd $redis_sentinel_dir/9000
./redis-server redis.conf
cd $redis_sentinel_dir/9001
./redis-server redis.conf
cd $redis_sentinel_dir/9002
./redis-server redis.conf

# watch redis master/slave status
ps -ef | grep redis
$redis_dir/src/redis-cli -h $redis_sentinel_ip -p 9000 info replication
sleep 5

# config sentinel.conf & start sentinel 1
# example by /data/redis-sentinel/9000/sentinel.conf
sed -i 's/\# protected-mode no/protected-mode no/g' $redis_sentinel_dir/9000/sentinel.conf
sed -i 's/port 26379/port 29000/g' $redis_sentinel_dir/9000/sentinel.conf
sed -i "s/127.0.0.1 6379/$redis_sentinel_ip 9000/g" $redis_sentinel_dir/9000/sentinel.conf
sed -i "s/dir \/tmp/\dir \/data\/redis-sentinel/g" $redis_sentinel_dir/9000/sentinel.conf
echo "daemonize yes" >> $redis_sentinel_dir/9000/sentinel.conf
#
\cp  $redis_sentinel_dir/9000/sentinel.conf $redis_sentinel_dir/9001/sentinel.conf
\cp  $redis_sentinel_dir/9000/sentinel.conf $redis_sentinel_dir/9002/sentinel.conf
sed -i 's/port 29000/port 29001/g' $redis_sentinel_dir/9001/sentinel.conf
sed -i 's/port 29000/port 29002/g' $redis_sentinel_dir/9002/sentinel.conf

# start sentinel
$redis_sentinel_dir/9000/redis-sentinel $redis_sentinel_dir/9000/sentinel.conf
$redis_sentinel_dir/9001/redis-sentinel $redis_sentinel_dir/9001/sentinel.conf
$redis_sentinel_dir/9002/redis-sentinel $redis_sentinel_dir/9002/sentinel.conf
#cd $redis_sentinel_dir/9000
#./redis-sentinel sentinel.conf
#cd $redis_sentinel_dir/9001
#./redis-sentinel sentinel.conf
#cd $redis_sentinel_dir/9002
#./redis-sentinel sentinel.conf

# watch sentinel status
ps -ef | grep redis
$redis_dir/src/redis-cli -h $redis_sentinel_ip -p 29000 sentinel masters
