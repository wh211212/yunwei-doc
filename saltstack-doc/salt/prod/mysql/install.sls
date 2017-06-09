include:
  - mysql.pkg-install
  - mysql.boost-init

mysql-user:
  user.present:
    - name: mysql
  group.present:
    - name: mysql

mysql-init:
  file.managed:
    - name: /usr/local/src/mysql-5.7.12.tar.gz
    - source: salt://mysql/files/mysql-5.7.12.tar.gz
  cmd.run:
    - name: cd /usr/local/src && tar zxf mysql-5.7.12.tar.gz && cd mysql-5.7.12 && cmake -DCMAKE_INSTALL_PREFIX=/data/mysql -DMYSQL_DATADIR=/data/mysql/data -DSYSCONFDIR=/etc -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DMYSQL_UNIX_ADDR=/data/mysql/mysql.sock -DMYSQL_TCP_PORT=3306 -DENABLED_LOCAL_INFILE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DDOWNLOAD_BOOST=1 -DWITH_BOOST=/data/boost && make -j `grep processor /proc/cpuinfo | wc -l` && make install
    - unless: test -d /data/mysql/bin
    - require:
      - file: mysql-init

mysql-conf:
  file.managed:
    - name: /etc/my.cnf
    - source: salt://mysql/files/my.cnf

mysql-env:
  file.append:
    - name: /etc/profile
    - text:
      - export PATH=/data/mysql/bin:$PATH
  cmd.run:
    - name: chown -R mysql:mysql /data/mysql && chmod -R go-rwx /data/mysql/data && source /etc/profile 
    - require:
      - file: mysql-init

#mysql-log:
#  file.directory:
#    - name: /var/log/mysql
#    - user: mysql
#    - group: mysql
#    - mode: 755

mysql-daemon:
  file.managed:
    - name: /etc/init.d/mysqld
    - source: salt://mysql/files/mysql.server
  cmd.run:
    - name: chkconfig mysqld on && chmod +x /etc/init.d/mysqld  
    - require: 
      - file: mysql-daemon

mysql-service:
  cmd.run:
    - name: /etc/init.d/mysqld start
    - unless: ps -ef | grep mysqld | grep -v grep
  service.running:
    - name: mysqld
    - enable: True
    - require:
      - file: mysql-init

#mysql-safe:
#  cmd.run:
#    - name: /data/mysql/bin/mysqld --initialize-insecure --user=mysql --basedir=/data/mysql --basedir=/data/mysql/data && mysqld_safe --user=mysql --datadir=/data/mysql/data/ --log-error=/data/mysql/error.log
# initial mysql database 
# mysql_secure_installation it's important
