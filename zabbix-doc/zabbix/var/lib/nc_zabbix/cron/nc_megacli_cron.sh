#MM 191212 initital creation
#LH 140128 adding -nolog so that it doesn't create /MegaSAS.log
VERSION=1.1
MEGACLI=/opt/MegaRAID/MegaCli/MegaCli64
sudo $MEGACLI -AdpBbuCmd -aAll -nolog |grep "rn t"| awk '{print $4}'|perl -e "print scalar(localtime(<STDIN>))"| awk '{print $2" "$3" "$4" GMT"}'>/var/lib/nc_zabbix/tmp/BBU.state
sudo $MEGACLI -FwTermLog -Dsply -aALL -nolog |grep 'BBU enabled|BBU disabled'|tail -1|awk '{print $1" "$2" "$6}'>>/var/lib/nc_zabbix/tmp/BBU.state

