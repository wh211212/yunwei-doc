# mysql master

grant replication slave on *.* to replica@'%' identified by 'Dbreplica..0';


change master to master_host='192.168.10.10',master_user='replica',master_password='Dbreplica..0',master_log_file='mysql-bin.000001',master_log_pos=120;  