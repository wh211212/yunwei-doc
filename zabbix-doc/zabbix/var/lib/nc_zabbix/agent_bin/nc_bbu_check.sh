#MM 191112 initital creation
#MM 221112 make relearn time human readable
#MM 141212 add state & stuff
#MM 191212 move data get to cronjob
#MM 141113 add no state logic
VERSION=1.3

ERROR_WRONG_PARAM="-9902"
# Zabbix requested parameter
ZBX_REQ_DATA="$1"
FILE_LENGTH=$(cat /var/lib/nc_zabbix/tmp/BBU.state|wc -l)
case "$ZBX_REQ_DATA" in
        relearn_time ) head -1 /var/lib/nc_zabbix/tmp/BBU.state;;
        state ) if [ $FILE_LENGTH == 2 ];then tail -1 /var/lib/nc_zabbix/tmp/BBU.state;
          else echo "no state found"; fi;;
        *        )  echo $ERROR_WRONG_PARAM; exit 1;;
esac

exit 0
