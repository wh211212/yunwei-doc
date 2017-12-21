#
[mysqld]
binlog-format=ROW 
log-bin=master-bin 
log-slave-updates=true
#gtid-mode=on  
#enforce-gtid-consistency=true
master-info-repository=TABLE 
relay-log-info-repository=TABLE 
replicate-ignore-db = mysql
replicate-ignore-db = performance_schema
replicate-ignore-db = information_schema
replicate-ignore-db = aniu_crm
sync-master-info=1 
slave-parallel-workers=2 
binlog-checksum=CRC32 
master-verify-checksum=1 
slave-sql-verify-checksum=1 
binlog-rows-query-log_events=1 
server-id=11
report-port=3306 
port=3306 
datadir=/data/mysql
socket=/data/mysql/mysql.sock
report-host=master
#rpl_semi_sync_master_enabled=ON
#lower_case_table_name=1
slave_skip_errors = 1062


#read_only=1
skip-external-locking
key_buffer_size = 128M
max_allowed_packet = 16M
table_open_cache = 1024
sort_buffer_size = 2M
read_buffer_size = 2M
read_rnd_buffer_size = 8M
myisam_sort_buffer_size = 32M
thread_cache_size = 16
query_cache_size = 16M
query_cache_limit = 1M
join_buffer_size = 16M
tmp_table_size = 32M
max_tmp_tables = 64
back_log = 500
max_connections = 1200
max_connect_errors = 1024
innodb_stats_on_metadata=0
innodb_table_locks=0
innodb_write_io_threads=16
#general_log=ON

#ignore Write size
lower_case_table_names = 1

slow_query_log
long_query_time = 2
relay-log=/data/mysql/relaylog
max_relay_log_size = 1G

innodb_data_home_dir = /data/mysql
innodb_data_file_path = ibdata1:2000M;ibdata2:10M:autoextend
innodb_log_group_home_dir = /data/mysql
innodb_log_files_in_group = 3 
innodb_lock_wait_timeout = 150
innodb_open_files = 600
innodb_file_per_table = 1
innodb_file_io_threads=4



##############################################

innodb_buffer_pool_size=10G
innodb_log_file_size=2G
innodb_log_buffer_size=8M
innodb_log_files_in_group=4
innodb_autoextend_increment=128
innodb_flush_log_at_trx_commit=2
innodb_flush_method=O_DIRECT
innodb_io_capacity=2000
innodb_io_capacity_max=6000
innodb_lru_scan_depth=2000
#innodb_additional_mem_pool_size=16M
innodb_max_dirty_pages_pct=90

# Binary log/replication
sync_binlog=20
sync_relay_log=20
expire_logs_days=10
transaction-isolation=READ-COMMITTED
innodb_autoinc_lock_mode = 2

# Other
#timezone=GMT
character-set-server=utf8
collation-server=utf8_general_ci
sql-mode="STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION,ONLY_FULL_GROUP_BY"
skip-name-resolve
max-connect-errors=10000
max-connections=3000

[mysqldump]
quick


[myisamchk]
key_buffer_size = 256M
sort_buffer_size = 256M
read_buffer = 4M
write_buffer = 4M

[mysqlhotcopy]
interactive-timeout

[mysqld_safe]
open-files-limit = 8192


 [root@yunwei mysql]# /usr/sbin/mysqld --initialize --user=mysql --socket=/var/lib/mysql/mysql.sock
 100 200 300 400 500 600 700 800 900 1000
 100 200 300 400 500
 100 200 300 400 500
 100 200 300 400 500
2017-12-06T11:14:35.605531Z 1 [Note] A temporary password is generated for root@localhost: 2HntkUfIZa<b

# zhucong 

grant replication slave on *.* to replication@'172.16.88.8' identified by 'Aniureplication123.';

## 5.7 初始化设置

Can't find error-message file '/data/mysql/share/mysql/errmsg.sys'. Check error-message file location and 'lc-messages-dir' configuration directive.

--initialize-insecure 不会生成密码 