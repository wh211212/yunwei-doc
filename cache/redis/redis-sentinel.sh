#!/bin/sh
#
# redis        init file for starting up the redis daemon
#
# chkconfig:   - 20 80
# description: Starts and stops the redis daemon.
# Source function library.
. /etc/rc.d/init.d/functions

# define some variables
#\cp /usr/local/redis/src/{redis-server,redis-sentinel,redis-cli} /usr/local/sbin/
REDISPORTLIST=(9000 9001 9002)
EXEC=/usr/local/sbin/redis-server
CLIEXEC=/usr/local/sbin/redis-cli
SENEXEC=/usr/local/sbin/redis-sentinel
REDIS_SENTINEL_DIR=/data/redis-sentinel
#
case "$1" in
    start)
#    for port in ${REDISPORTLIST[@]};
#    do
#    REDISPID=/var/run/redis_${port}.pid
#    REDIS_SENTINEL_HOME=$REDIS_SENTINEL_DIR/$port
#    REDISCONF="$REDIS_SENTINEL_HOME/redis.conf"
#        if [ -f $REDISPID ]
#        then
#                echo "$REDISPID exists, Redis is already running or crashed"
#        else
#                echo "Starting Redis server..."
#                $EXEC $REDISCONF
#        fi
#     done
    # start redis
    /data/redis-sentinel/9000/redis-server /data/redis-sentinel/9000/redis.conf
    /data/redis-sentinel/9001/redis-server /data/redis-sentinel/9001/redis.conf
    /data/redis-sentinel/9002/redis-server /data/redis-sentinel/9002/redis.conf
    # start sentinel
    /data/redis-sentinel/9000/redis-sentinel /data/redis-sentinel/9000/sentinel.conf
    /data/redis-sentinel/9001/redis-sentinel /data/redis-sentinel/9001/sentinel.conf
    /data/redis-sentinel/9002/redis-sentinel /data/redis-sentinel/9002/sentinel.conf

        ;;
    stop)
#    # stop redis
#    for port in ${REDISPORTLIST[@]};
#    do
#    REDISPID=/var/run/redis_${port}.pid
#        if [ ! -f $REDISPID ]
#        then
#                echo "$REDISPID does not exist, redis ${port} process is not running"
#        else
#                PID=$(cat $REDISPID)
#                echo "Stopping redis ${port} process ..."
#                $CLIEXEC -p $REDISPORT shutdown
#                while [ -x /proc/${PID} ]
#                do
#                    echo "Waiting for Redis ${port} to be shutdown ..."
#                    sleep 2
#                done
#                echo "Redis ${port} stopped"
#        fi
#     done
#    # stop sentinel
#    for port in ${REDISPORTLIST[@]};
#    do
#    SENTINEPID=/var/run/sentinel_2${port}.pid
#        if [ ! -f $SENTINEPID ]
#        then
#                echo "$SENTINEPID does not exist, sentinel process is not running"
#        else
#                PID=$(cat $SENTINEPID)
#                echo "Stopping Sentinel process ..."
#                $CLIEXEC -p $SENTINEPID shutdown
#                while [ -x /proc/${PID} ]
#                do
#                    echo "Waiting for Sentinel process to be shutdown ..."
#                    sleep 2
#                done
#                echo "Sentinel 2${port} stopped"
#        fi
#     done
      killall -9 redis-server & killall -9 killall-sentinel
        ;;
     restart)
        stop
        start
        ;;
    *)
        echo $"Usage: $0 {start|stop|restart|}"
        exit 2
esac
exit $?
