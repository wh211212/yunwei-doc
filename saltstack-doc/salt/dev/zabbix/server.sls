include:                                                                                                                                                                         
  - zabbix.pkg-init
   
zabbix-user:
  user.present:
    - name: zabbix
    - shell: /sbin/nologin
  group.present:
    - name: zabbix
 
zabbix-server-init:
  file.managed:
    - name: /usr/local/src/zabbix-3.0.3.tar.gz
    - source: salt://zabbix/files/zabbix-3.0.3.tar.gz
    - unless: test -f /usr/local/src/zabbix-3.0.3.tar.gz
  cmd.run:
    - name: cd /usr/local/src && tar zxf zabbix-3.0.3.tar.gz && cd zabbix-3.0.3 && ./configure --prefix=/opt/zabbix --enable-server --enable-agent --with-libcurl --with-mysql=/data/mysql/bin/mysql_config --with-net-snmp --with-openssl --with-libxml2 --enable-ipv6 && make && make install
    - unless: test -d /opt/zabbix
    - require:
      - file: zabbix-server-init

zabbix-server-conf:
  file.managed:
    - name: /opt/zabbix/etc/zabbix_server.conf
    - source: salt://zabbix/files/zabbix_server.conf

zabbix-agentd-conf:
  file.managed:
    - name: /opt/zabbix/etc/zabbix_agentd.conf
    - source: salt://zabbix/files/zabbix_agentd.conf

zabbix-db-set:
  file.managed:
    - name: /root/.my.cnf
    - source: salt://zabbix/files/my.cnf
  cmd.run:
    - name: /data/mysql/bin/mysql -e "create database zabbix character set utf8 collate utf8_bin;"  && /data/mysql/bin/mysql -e "grant all privileges on zabbix.* to zabbix@localhost identified by '@Zabbix..0';" && /data/mysql/bin/mysql -e "flush privileges;"
    - unless: /data/mysql/bin/mysql -e "use zabbix;"
    - require: 
      - file: zabbix-db-set

zabbix-sql-set:
  cmd.run:
    - name: cd /usr/local/src/zabbix-3.0.3/database/mysql && /data/mysql/bin/mysql -uzabbix -p@Zabbix..0 zabbix < schema.sql && /data/mysql/bin/mysql -uzabbix -p@Zabbix..0 zabbix < images.sql && /data/mysql/bin/mysql -uzabbix -p@Zabbix..0 zabbix < data.sql
    - unless: /data/mysql/bin/mysql -e "show create table zabbix.users"

zabbix-port-set:
  file.managed:
    - name: /etc/services
    - source: salt://zabbix/files/services

zabbix-log-set:
  file.directory:
    - name: /var/log/zabbix
    - unless: test -d /var/log/zabbix
  cmd.run:
    - name: chown -R zabbix:zabbix /var/log/zabbix
    - unless: ls -l /var/log/zabbix | awk '/zabbix/{print $3"\t"$4}' 
    - require:
      - file: zabbix-log-set

zabbix-server-daemon:
  file.managed:
    - name: /etc/init.d/zabbix_server
    - source: salt://zabbix/files/zabbix_server
    - user: root
    - group: root
    - mode: 755
  cmd.run: 
    - name: chkconfig zabbix_server on && ln -s /data/mysql/lib/libmysqlclient.so.20 /usr/lib64/ && /etc/init.d/zabbix_server start
    - unless: ps -ef | grep zabbix_server | grep -v grep
    - require: 
      - file: zabbix-server-daemon

zabbix-pid-set:             
  file.directory:           
    - name: /opt/zabbix/pid 
    - unless: test -d /opt/zabbix/pid            
  cmd.run:                  
    - name: chown -R zabbix:zabbix /opt/zabbix/pid
    - unless: ls -l /opt/zabbix/pid | awk '/zabbix/{print $3"\t"$4}'
    - require:              
      - file: zabbix-pid-set  

zabbix-agentd-daemon:
  file.managed:
    - name: /etc/init.d/zabbix_agentd
    - source: salt://zabbix/files/zabbix_agentd
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: chkconfig zabbix_agentd on && /etc/init.d/zabbix_agentd start
    - unless: ps -ef | grep zabbix_agentd | grep -v grep
    - require:
      - file: zabbix-agentd-daemon

zabbix-front-set:
  cmd.run:
    - name: cp -rf /usr/local/src/zabbix-3.0.3/frontends/php /opt/nginx/html/zabbix && chown -R www:www /opt/nginx/html/zabbix
    - unless: test -d /opt/nginx/html/zabbix

zabbix-conf-php:
  file.managed:
    - name: /opt/nginx/html/zabbix/conf/zabbix.conf.php
    - source: salt://zabbix/files/zabbix.conf.php
    - user: zabbix
    - group: zabbix
    - mode: 644
