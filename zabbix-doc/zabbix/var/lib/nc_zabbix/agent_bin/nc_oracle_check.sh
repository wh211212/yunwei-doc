#!/bin/bash
#
# 
#

export ORACLE_BASE=/opt/oracle/db
export ORACLE_HOME=$ORACLE_BASE/product/10.2.0/db_1
export ORACLE_SID=
export ORA_CRS_HOME=/opt/oracle/crs
export PATH=$PATH:$ORACLE_HOME/bin:$ORA_CRS_HOME/bin
export NLS_LANG=


CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF="$CURRENT_DIR/../conf/nc_oracle_check.conf"
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

zaboraver="1.5"
rval=0

if [ "$2" != "" ]; then
       export ORACLE_SID=$2
fi

case $1 in

'checkactive')
        sql="select to_char(case when inst_cnt > 0 then 1 else 0 end,'FM99999999999999990') retvalue
             from (select count(*) inst_cnt from v\$instance 
                   where status = 'OPEN' and logins = 'ALLOWED' and database_status = 'ACTIVE');"
        ;;

'rcachehit')
        sql="SELECT to_char((1 - (phy.value - lob.value - dir.value) / ses.value) * 100, 'FM99999990.9999') retvalue
            FROM   v\$sysstat ses, v\$sysstat lob,
                   v\$sysstat dir, v\$sysstat phy
            WHERE  ses.name = 'session logical reads'
            AND    dir.name = 'physical reads direct'
            AND    lob.name = 'physical reads direct (lob)'
            AND    phy.name = 'physical reads';"
        ;;

'dsksortratio')
        sql="SELECT to_char(d.value/(d.value + m.value)*100, 'FM99999990.9999') retvalue
             FROM  v\$sysstat m, v\$sysstat d
             WHERE m.name = 'sorts (memory)'
             AND d.name = 'sorts (disk)';"
        ;;

'activeusercount')
        sql="select to_char(count(*)-1, 'FM99999999999999990') retvalue from v\$session where username is not null 
             and status='ACTIVE';"
        ;;

'usercount')
        sql="select to_char(count(*)-1, 'FM99999999999999990') retvalue from v\$session where username is not null;"
        ;;

'dbsize')
        sql="SELECT to_char(sum(  NVL(a.bytes - NVL(f.bytes, 0), 0)), 'FM99999999999999990') retvalue
             FROM sys.dba_tablespaces d,
             (select tablespace_name, sum(bytes) bytes from dba_data_files group by tablespace_name) a,
             (select tablespace_name, sum(bytes) bytes from dba_free_space group by tablespace_name) f
             WHERE d.tablespace_name = a.tablespace_name(+) AND d.tablespace_name = f.tablespace_name(+)
             AND NOT (d.extent_management like 'LOCAL' AND d.contents like 'TEMPORARY');"
        ;;

'dbfilesize')
        sql="select to_char(sum(bytes), 'FM99999999999999990') retvalue from dba_data_files;"
        ;;

'version')
        sql="select banner from v\$version where rownum=1;"
        ;;

'uptime')
        sql="select to_char((sysdate-startup_time)*86400, 'FM99999999999999990') retvalue from v\$instance;"
        ;;

'commits')
        sql="select to_char(value, 'FM99999999999999990') retvalue from v\$sysstat where name = 'user commits';"
        ;;

'rollbacks')
        sql="select to_char(value, 'FM99999999999999990') retvalue from v\$sysstat where name = 'user rollbacks';"
        ;;

'deadlocks')
        sql="select to_char(value, 'FM99999999999999990') retvalue from v\$sysstat where name = 'enqueue deadlocks';"
        ;;

'redowrites')
        sql="select to_char(value, 'FM99999999999999990') retvalue from v\$sysstat where name = 'redo writes';"
        ;;

'tblscans')
        sql="select to_char(value, 'FM99999999999999990') retvalue from v\$sysstat where name = 'table scans (long tables)';"
        ;;

'tblrowsscans')
        sql="select to_char(value, 'FM99999999999999990') retvalue from v\$sysstat where name = 'table scan rows gotten';"
        ;;

'indexffs')
        sql="select to_char(value, 'FM99999999999999990') retvalue from v\$sysstat where name = 'index fast full scans (full)';"
        ;;

'hparsratio') 
        sql="SELECT to_char(h.value/t.value*100,'FM99999990.9999') retvalue
             FROM  v\$sysstat h, v\$sysstat t
             WHERE h.name = 'parse count (hard)'
             AND t.name = 'parse count (total)';"
        ;;

'netsent')
        sql="select to_char(value, 'FM99999999999999990') retvalue from v\$sysstat where name = 'bytes sent via SQL*Net to client';"
        ;;

'netresv')
        sql="select to_char(value, 'FM99999999999999990') retvalue from v\$sysstat where name = 'bytes received via SQL*Net from client';"
        ;;

'netroundtrips')
        sql="select to_char(value, 'FM99999999999999990') retvalue from v\$sysstat where name = 'SQL*Net roundtrips to/from client';"
        ;;

'logonscurrent')
        sql="select to_char(value, 'FM99999999999999990') retvalue from v\$sysstat where name = 'logons current';"
        ;;

'physicalreads')
    sql="select to_char(value, 'FM99999999999999990') retvalue from v\$sysstat where name = 'physical reads';"
    ;;

'sessionlogicalreads')
    sql="select to_char(value, 'FM99999999999999990') retvalue from v\$sysstat where name = 'session logical reads';"
    ;;

'lastarclog')
        sql="select to_char(max(SEQUENCE#), 'FM99999999999999990') retvalue from v\$log where archived = 'YES';"
        ;;

'lastapplarclog')
        sql="select to_char(max(lh.SEQUENCE#), 'FM99999999999999990') retvalue
             from v\$loghist lh, v\$archived_log al
             where lh.SEQUENCE# = al.SEQUENCE# and applied='YES';"
        ;;

'freebufwaits')
        sql="select to_char(time_waited, 'FM99999999999999990') retvalue
             from v\$system_event se, v\$event_name en
             where se.event(+) = en.name and en.name = 'free buffer waits';"
        ;;

'bufbusywaits')
        sql="select to_char(time_waited, 'FM99999999999999990') retvalue
             from v\$system_event se, v\$event_name en
             where se.event(+) = en.name and en.name = 'buffer busy waits';"
        ;;

'logswcompletion')
        sql="select to_char(time_waited, 'FM99999999999999990') retvalue
             from v\$system_event se, v\$event_name en
             where se.event(+) = en.name and en.name = 'log file switch completion';"
        ;;

'logfilesync')
        sql="select to_char(time_waited, 'FM99999999999999990') retvalue
             from v\$system_event se, v\$event_name en
             where se.event(+) = en.name and en.name = 'log file sync';"
        ;;

'logprllwrite')
        sql="select to_char(time_waited, 'FM99999999999999990') retvalue
             from v\$system_event se, v\$event_name en
             where se.event(+) = en.name and en.name = 'log file parallel write';"
        ;;

'enqueue')
        sql="select to_char(time_waited, 'FM99999999999999990') retvalue
             from v\$system_event se, v\$event_name en
             where se.event(+) = en.name and en.name = 'enqueue';"
        ;;

'dbseqread')
        sql="select to_char(time_waited, 'FM99999999999999990') retvalue
             from v\$system_event se, v\$event_name en
             where se.event(+) = en.name and en.name = 'db file sequential read';"
        ;;

'dbscattread')
        sql="select to_char(time_waited, 'FM99999999999999990') retvalue
             from v\$system_event se, v\$event_name en
             where se.event(+) = en.name and en.name = 'db file scattered read';"
        ;;

'dbsnglwrite')
        sql="select to_char(time_waited, 'FM99999999999999990') retvalue
             from v\$system_event se, v\$event_name en
             where se.event(+) = en.name and en.name = 'db file single write';"
        ;;

'dbprllwrite')
        sql="select to_char(time_waited, 'FM99999999999999990') retvalue
             from v\$system_event se, v\$event_name en
             where se.event(+) = en.name and en.name = 'db file parallel write';"
        ;;

'directread')
        sql="select to_char(time_waited, 'FM99999999999999990') retvalue
             from v\$system_event se, v\$event_name en
             where se.event(+) = en.name and en.name = 'direct path read';"
        ;;

'directwrite')
        sql="select to_char(time_waited, 'FM99999999999999990') retvalue
             from v\$system_event se, v\$event_name en
             where se.event(+) = en.name and en.name = 'direct path write';"
        ;;

'latchfree')
        sql="select to_char(time_waited, 'FM99999999999999990') retvalue
             from v\$system_event se, v\$event_name en
             where se.event(+) = en.name and en.name = 'latch free';"
        ;;

'zaboraver')
        echo "$zaboraver"
        ;;

'-h' | '-?' | '--help')
        echo "zabora version: $zaboraver"
        echo "usage:"
        echo "    $0 checkactive [SID]     -- Check Intance is active and open."
        echo "    $0 usercount [SID]       -- Count of users connected to Oracle."
        echo "    $0 activeusercount [SID] -- Count of active users."
        echo "    $0 dbsize [SID]          -- Size of user data (without temp)."
        echo "    $0 dbfilesize [SID]      -- Size of all datafiles."
        echo "    $0 version [SID]         -- Oracle version (Banner)."
        echo "    $0 dsksortratio [SID]    -- Disk sorts ratio."
        echo "    $0 rcachehit [SID]       -- Read Cache hit ratio."
        echo "    $0 uptime [SID]          -- Instance Uptime (seconds)."
        echo "    $0 commits [SID]         -- User Commits."
        echo "    $0 rollbacks [SID]       -- User Rollbacks."
        echo "    $0 deadlocks [SID]       -- Deadlocks."
        echo "    $0 redowrites [SID]      -- Redo Writes."
        echo "    $0 tblscans [SID]        -- Table scans (long tables)."
        echo "    $0 tblrowsscans [SID]    -- Table scan rows gotten."
        echo "    $0 indexffs [SID]        -- Index fast full scans (full)."
        echo "    $0 hparsratio [SID]      -- Hard parse ratio."
        echo "    $0 netsent [SID]         -- Bytes sent via SQL*Net to client."
        echo "    $0 netresv [SID]         -- Bytes received via SQL*Net from client."
        echo "    $0 netroundtrips [SID]   -- SQL*Net roundtrips to/from client."
        echo "    $0 logonscurrent [SID]   -- Logons current."
        echo "    $0 physicalreads [SID]   -- Physical reads."
        echo "    $0 sessionlogicalread [SID]   -- Session logical reads."
        echo "    $0 lastarclog [SID]      -- Last archived log sequence."
        echo "    $0 lastapplarclog [SID]  -- Last applied archive log (at standby)."
        echo "    $0 freebufwaits [SID]    -- free buffer waits."
        echo "    $0 bufbusywaits [SID]    -- buffer busy waits."
        echo "    $0 logswcompletion [SID] -- log file switch completion."
        echo "    $0 logfilesync [SID]     -- log file sync."
        echo "    $0 logprllwrite [SID]    -- log file parallel write."
        echo "    $0 enqueue [SID]         -- enqueue waits."
        echo "    $0 dbseqread [SID]       -- db file sequential read waits."
        echo "    $0 dbscattread [SID]     -- db file scattered read."
        echo "    $0 dbsnglwrite [SID]     -- db file single write."
        echo "    $0 dbprllwrite [SID]     -- db file parallel write."
        echo "    $0 directread [SID]      -- direct path read."
        echo "    $0 directwrite [SID]     -- direct path write."
        echo "    $0 latchfree [SID]       -- latch free."
        echo "    $0 zaboraver             -- Version of this script."
        rval=1
        exit $rval
        ;;
*)
    echo "ZBX_NOTSUPPORTED"
        rval=1
        exit $rval
        ;;

esac

if [ "$sql" != "" ]; then
       echo "$sql" | sqlplus -s /nolog @/var/lib/nc_zabbix/.cont.sql
fi
rval=$?

if [ "$rval" -ne 0 ]; then
  echo "ZBX_NOTSUPPORTED"
fi

exit $rval
