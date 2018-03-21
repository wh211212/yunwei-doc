#!/usr/bin/env bash
# ***********************************************
# @Time     : 2018/3/21 11:13
# @Author   : shaonbean@qq.com
# @Software : PyCharm
# @Blog     : http://blog.csdn.net/wh211212
# ***********************************************
#
#!/bin/sh
#
# redis        init file for starting up the redis daemon
#
# chkconfig:   - 20 80
# description: Starts and stops the redis daemon.
#
### BEGIN INIT INFO
# Provides: redis-server
# Required-Start: $local_fs $remote_fs $network
# Required-Stop: $local_fs $remote_fs $network
# Short-Description: start and stop Redis server
# Description: A persistent key-value database
### END INIT INFO

# Source function library.
. /etc/rc.d/init.d/functions

name="redis-server"
exec="/usr/bin/$name"
shut="/usr/libexec/redis-shutdown"
pidfile="/var/run/redis/redis-6379.pid"
REDIS_CONFIG="/etc/redis/6379.conf"

[ -e /etc/sysconfig/redis ] && . /etc/sysconfig/redis

lockfile=/var/lock/subsys/redis

start() {
    [ -f $REDIS_CONFIG ] || exit 6
    [ -x $exec ] || exit 5
    echo -n $"Starting $name: "
    daemon --user ${REDIS_USER-redis} "$exec $REDIS_CONFIG --daemonize yes --pidfile $pidfile"
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $lockfile
    return $retval
}

stop() {
    echo -n $"Stopping $name: "
    [ -x $shut ] && $shut
    retval=$?
    if [ -f $pidfile ]
    then
        # shutdown haven't work, try old way
        killproc -p $pidfile $name
        retval=$?
    else
        success "$name shutdown"
    fi
    echo
    [ $retval -eq 0 ] && rm -f $lockfile
    return $retval
}

restart() {
    stop
    start
}

rh_status() {
    status -p $pidfile $name
}

rh_status_q() {
    rh_status >/dev/null 2>&1
}


case "$1" in
    start)
        rh_status_q && exit 0
        $1
        ;;
    stop)
        rh_status_q || exit 0
        $1
        ;;
    restart)
        $1
        ;;
    reload)
        rh_status_q || exit 7
        $1
        ;;
    force-reload)
        force_reload
        ;;
    status)
        rh_status
        ;;
    condrestart|try-restart)
        rh_status_q || exit 0
        restart
        ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart}"
        exit 2
esac
exit $?