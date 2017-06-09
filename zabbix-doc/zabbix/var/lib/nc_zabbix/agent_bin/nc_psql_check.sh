#!/bin/bash
##################################
# Zabbix monitoring script
#
# PostgreSQL:
#  - pg_stat_database
#  - pg_stat_replication
#
# Info:
#  - PostgreSQL data are gathered real-time
##################################
# ChangeLog:
#  20120207    DL    Organize
##################################

# Zabbix requested parameter
ZBX_REQ_DATA="$1"

# PostgreSQL details
DBUSER="zabbix"
PSQL_BIN="/usr/bin/psql"


# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF=$CURRENT_DIR/../conf/nc_psql_check.conf
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

PSQL_CMD="$PSQL_BIN --username=$DBUSER"

#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - numeric items need to be of type "float" (allow negative + float)
#
ERROR_NO_BIN="-0.9901"
ERROR_WRONG_PARAM="-0.9902"
ERROR_GENERIC="-0.9903"

# Check PSQL BIN
if [ ! -x "$PSQL_BIN" ]; then
  echo $ERROR_NO_BIN
  exit 1
fi

# Only ZBX_REQ_DATA is mandatory
# If ZBX_REQ_DATA is not specified, get from mysql global status
if [ -z "$ZBX_REQ_DATA" ]; then
  echo $ERROR_WRONG_PARAM
  exit 1
fi

PSQL_STATS_KEY="$1"
PSQL_DB="postgres"

# PSQL do not use credentials , manually check if zabbix is authorized or not
$PSQL_CMD "$PSQL_DB" -t -c "\l" >&/dev/null
if [ $? -ne 0 ]; then
  echo $ERROR_GENERIC
  exit 1
fi

case "$PSQL_STATS_KEY" in
  "version"                     ) "$PSQL_BIN" --version | head -n1 ;;
  "server_processes"            ) $PSQL_CMD "$PSQL_DB" -A -t -c "select sum(numbackends) from pg_stat_database" ;;
  "tx_commited"                 ) $PSQL_CMD "$PSQL_DB" -A -t -c "select sum(xact_commit) from pg_stat_database" ;;
  "tx_rolledback"               ) $PSQL_CMD "$PSQL_DB" -A -t -c "select sum(xact_rollback) from pg_stat_database" ;; 
  "tx_blksread"                 ) $PSQL_CMD "$PSQL_DB" -A -t -c "select sum(blks_read) from pg_stat_database" ;;
  "tx_blkshit"                  ) $PSQL_CMD "$PSQL_DB" -A -t -c "select sum(blks_hit) from pg_stat_database" ;;
  "tx_commited_per_min"         ) $PSQL_CMD "$PSQL_DB" -A -t -c "select sum(xact_commit) from pg_stat_database" ;;
  "tx_rolledback_per_min"       ) $PSQL_CMD "$PSQL_DB" -A -t -c "select sum(xact_rollback) from pg_stat_database" ;;    
  "conn_count"                  ) $PSQL_CMD "$PSQL_DB" -A -t -c "select count(*) from pg_stat_activity" ;;
  "lock_count"                  ) $PSQL_CMD "$PSQL_DB" -A -t -c "select count(*) from pg_locks" ;;
  "replication_state"           ) $PSQL_CMD "$PSQL_DB" -A -t -c "select state from pg_stat_replication";;
  "replication_sent_location"   ) $PSQL_CMD "$PSQL_DB" -A -t -c "select sent_location from pg_stat_replication" ;;
  "replication_write_location"  ) $PSQL_CMD "$PSQL_DB" -A -t -c "select write_location  from pg_stat_replicatVion" ;;
  "replication_flush_location"  ) $PSQL_CMD "$PSQL_DB" -A -t -c "select flush_location from pg_stat_replication" ;;
  "replication_replay_location" ) $PSQL_CMD "$PSQL_DB" -A -t -c "select replay_location from pg_stat_replication" ;;
  "replication_sync_state"      ) $PSQL_CMD "$PSQL_DB" -A -t -c "select sync_state  from pg_stat_replication" ;; 
  "uptime"                      ) $PSQL_CMD "$PSQL_DB" -A -t -c "select EXTRACT(EPOCH FROM pg_postmaster_start_time())" &> /dev/null
    if [ $? -ne 0 ];then
        echo "$ERROR_WRONG_PARAM"
    else
        echo "$(date +%s)-$($PSQL_CMD $PSQL_DB -A -t -c "select EXTRACT(EPOCH FROM pg_postmaster_start_time())")" | bc -l
    fi
    ;;
  *                             ) echo "$ERROR_WRONG_PARAM" ;;
esac
