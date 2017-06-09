#!/bin/bash
#
# Description: this script will compare my.cnf vs. running config.
# Author: Alan.sun@chinanetcloud.com
#
##################################
# ChangeLog:
#  20121022     AS      Init create
#  20130520     MD      added exit_step function
#

PT_CONFIG_DIFF="/usr/bin/pt-config-diff"
CNC_CONF="/etc/my.cnf"
TMP_FILE=$(mktemp)
TMP_DIR="/var/lib/nc_zabbix/tmp/mysql_check"
RESULT_FILE="$TMP_DIR/$(date +%s)"
MYSQL_USER="nccheckdb"
MYSQL_PASS="Lm03Whqt"
EXCLUDE="innodb_data_file_path\|Variable\|differences\|delay_key_write\|====="

# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF=$CURRENT_DIR/../conf/
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF


# Error codes
ERROR_NO_RESULT="-0.9900"
ERROR_CONF_CHANGED="-0.9901"
ERROR_WRONG_PARAM="-0.9902"
ERROR_GENERIC="-0.9903"
ERROR_NO_PERCONA="-0.9904"
ERROR_BAD_PASS="-0.9905"

if [ ! -x "$PT_CONFIG_DIFF" ]; then
    echo "$ERROR_NO_PERCONA"
    exit 1
fi

if [ ! -r $MYSQL_DEFAULT_FILE ]; then
    echo "$ERROR_GENERIC"
    exit 1
fi

if [ ! -d $TMP_DIR ]; then
    mkdir -p $TMP_DIR
fi

# exit script run
exit_step(){
    /bin/rm -f $TMP_FILE
}

# Check mysql access
mysql -u $MYSQL_USER -p$MYSQL_PASS -e 'SELECT VERSION();' &>/dev/null
if [ $? -ne 0 ]; then
    echo "$ERROR_BAD_PASS"
    exit_step
    exit 1
fi

grep -v "^$" $CNC_CONF | grep -v "^#" | sed 's/\t//g' > $TMP_FILE

# pt-config-diff command
$PT_CONFIG_DIFF --report-width=250 $TMP_FILE u=$MYSQL_USER,p=$MYSQL_PASS > $RESULT_FILE 2>/dev/null

if [ $? -eq 0 ]; then
    # my.cnf = mysql running config
    echo "1"
    exit_step
    exit 0
else
    sed -i "/$EXCLUDE/d" $RESULT_FILE
    LINE=$(cat $RESULT_FILE | wc -l)
    SQL_MODE=$(grep sql_mode $RESULT_FILE | wc -l)

    if [ $LINE -ge 2 ]; then
        echo "$ERROR_CONF_CHANGED"
        exit_step
        exit 1
    elif [ $LINE -eq 1 ]; then
          if [ $SQL_MODE -eq 1 ]; then
              # compares sql_mode TRADITIONAL correctly
              CONF_VAR=$(awk '{print $2}' $RESULT_FILE)
              SERVER_VAR=$(awk '{print $3}' $RESULT_FILE)
              SERVER_VAR=${SERVER_VAR/STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER/TRADITIONAL}
              if [ "$CONF_VAR" == "$SERVER_VAR" ]; then
                  echo "1"
              else
                  echo "$ERROR_CONF_CHANGED"
                  exit_step
                  exit 1
              fi
          else
              # one entry is different
              echo "$ERROR_CONF_CHANGED"
              exit_step
              exit 1
          fi
    else
         # my.cnf = mysql running config
         echo "1"
         exit_step
         exit 0
    fi
fi
