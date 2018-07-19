#!/bin/bash
##################################################################################################
#    Description:
#    - backup mysql data
##################################################################################################
#
#    CHANGELOG
#
#    History
#    2016-07-12      JiangYin    Create
#    2018-01-08      JiangYin    Encryption backup file
##################################################################################################

version_num=20160712

##################################################################################################
#       set variable
##################################################################################################
DATE=`date +%Y%m%d`
MYSQLDUMP="/usr/bin/mysqldump"
MYSQL="/usr/bin/mysql"
MYSQL_USER="backup"
MYSQL_PASSWD="RNRHzEyjqFJuGk226ERZ"
MYSQL_AND_CREDS="$MYSQL -u $MYSQL_USER -p$MYSQL_PASSWD"
MYSQLDUMP_AND_CREDS="$MYSQLDUMP -u $MYSQL_USER -p$MYSQL_PASSWD"
BACKUP_FOLDER="/data/backup"
IP="172.16.1.2"
PASSWORD="oz6To4UvZvT5"

# MYSQLDUMP
if [ ! -f "$MYSQLDUMP" ]; then
  echo "ERROR: MYSQLDUMP: $MYSQLDUMP -- binary not found" >&2
  exit 2
fi

#MYSQL
if [ ! -f "$MYSQL" ]; then
  echo "ERROR: MYSQL: $MYSQL -- binary not found" >&2
  exit 2
fi

#BACKUP FOLDER
if [ ! -d $BACKUP_FOLDER ];then
        mkdir -p $BACKUP_FOLDER
fi

#create backup dir with data
mkdir -p /data/backup/$DATE

#backup Database
for DB_NAME in $($MYSQL_AND_CREDS -e "show databases" | sed '/Database/d' | grep -v "information_schema" | grep -v "performance_schema");
do
    echo "---- Backing up Database : $DB_NAME ---- "
    $MYSQLDUMP_AND_CREDS --opt --routines --triggers --events --flush-privileges --skip-add-drop-table --single-transaction  --skip-add-locks --skip-lock-tables --dump-date --databases $DB_NAME | gzip > "$BACKUP_FOLDER/$DATE"/"$DB_NAME".sql.gz
    echo "---- Backup Done ---- ";
done

#for TABLE_NAME in /var/backup/tablesname;
#do
#    echo "---- Backing up Tables : $TABLE_NAME ---- "
#    $MYSQLDUMP_AND_CREDS --opt --routines --triggers --events --flush-privileges --skip-add-drop-table --single-transaction  --skip-add-locks --skip-lock-tables --dump-date --databases $TABLE_NAME | gzip > "$BACKUP_FOLDER"/"$TABLE_NAME".sql.gz
#    echo "---- Backup Done ---- ";
#done

#compress Database
cd "$BACKUP_FOLDER"
echo "---- Compress file ---- "
tar -zcf - $DATE --remove-files | openssl des3 -salt -k $PASSWORD | dd of="$DATE".tar.gz
echo "---- Compress Done ---- ";

##how to decompression the backup file
##dd if=filename |openssl des3 -d -k $PASSWORD | tar zxf -

#use backup user to scp file
chown backup.backup $BACKUP_FOLDER -R

#scp backup file to remote
sudo -u backup scp -P 54077 $BACKUP_FOLDER/${DATE}.tar.gz backup@192.168.0.47:/backup/${IP}
