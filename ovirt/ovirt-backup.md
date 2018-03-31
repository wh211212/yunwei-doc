# ovirt backup

/usr/bin/engine-backup --mode=backup --scope=all --file=engine-backup.txt --log=engine-backup.log

# ovirt resotre

[root@ovirt ~]# engine-backup --mode=restore --scope=all --file=engine-backup.txt --log=engine-restore.log
Preparing to restore:
FATAL: Engine service is active - can not restore backup

还原需要停止engine

#