#!/bin/bash
#################################################################
#Please check the path of the command mysql is correct or not ###
#################################################################

set -x

DEST_FOLDER=/var/lib/nc_zabbix/tmp
psql_ping_file="$DEST_FOLDER/psql.ping"
#psql_status_file="$DEST_FOLDER/psql.status"
#psql_extended_file="$DEST_FOLDER/psql.extended"
#psql_connection_check_count="$DEST_FOLDER/psql.connection"
pgsql_table_database="$DEST_FOLDER/pgsql_table_database"
pgsql_function_result="$DEST_FOLDER/pgsql_function_result"

# Global Variable
## Variable to store the Standard Statistics Views
standard_statistics_views_name=""
statistics_functions=""
function_list=""
function_list_fill_oid=""


# Get status
psql postgres -t -c "select * from pg_stat_database" | grep -vE '^ *$' > $pgsql_table_database



# check for existing folder - creates it
if [ ! -d $DEST_FOLDER ]; then
    mkdir -p $DEST_FOLDER 2> /dev/null
    [ $? -ne 0 ] && (echo "ERROR: Can NOT create destination folder: $DEST_FOLDER - check permissions"; exit 2)
fi


# shwo version
echo "version: $(psql --version|head -n1)" > $psql_status_file



## Get the Standard Statistics Views names and store in the Variable 
## Make sure you have the default database postgres in your databse, or you must change the database name into the database_name you have in your database

standard_statistics_views_name=`psql postgres -t -c "\dS pg_stat*" | awk -F ' ' '{print $3}'`


# function to get all the stat tables from database 

for loop_get_status_tables in $standard_statistics_views_name ;
do
    echo "select * from $loop_get_status_tables" | psql postgres > $DEST_FOLDER/pgstatus_$loop_get_status_tables
done


###
# get all the functions use oid as a argument from pgsql use '\df pg_stat*'
# grep -E 'oid *$' allentesttext

## get all the function return value
##
##
#statistics_functions=`psql postgres -t -c "\df pg_stat*"`
function_list=$(psql postgres -t -c "\df pg_stat*" | grep -E 'oid *$' | awk -F ' ' '{print $3}')

echo "" > $pgsql_function_result

## add argument to each function
database_name_list=$(cat tmp/pgsql_table_database | awk -F ' ' '{print $3}')
for database_name in $database_name_list ;
do
    #   echo $database_name
    for func_name in $function_list;
    do

    ##
    # change database_name into oid
    db_oid=`grep $database_name $pgsql_table_database | awk -F ' ' '{print $1}'`

    #check whether the oid is null or not
    # if null skip
    if [ $db_oid -ne " "  ]; then
        func_result=$(psql postgres -t -c "select $func_name($db_oid)" | sed 's/^\ *//')
        #            printf "%s:%s:%s\n" $database_name $func_name $func_result
    fi
    echo -e "$database_name $func_name $func_result" >> $pgsql_function_result
    done
done



# Get activity
#echo "select * from pg_stat_activity" | psql postgres > $psql_table_activity

