zabbix-agent-init:
  pkg.installed:
    - name: gcc-c++
  user.present:
    - name: zabbix
    - shell: /sbin/nologin
  group.present:
    - name: zabbix
  file.managed:
    - name: /usr/local/src/zabbix-3.0.3.tar.gz
    - source: salt://zabbix/files/zabbix-3.0.3.tar.gz
    - unless: test -f /usr/local/src/zabbix-3.0.3.tar.gz
  cmd.run:
    - name: cd /usr/local/src && tar zxf zabbix-3.0.3.tar.gz && cd zabbix-3.0.3 && ./configure --prefix=/opt/zabbix --enable-agent && make && make install
    - unless: test -d /opt/zabbix
    - require: 
      - file: zabbix-agent-init

zabbix-agentd-conf:
  file.managed:
    - name: /opt/zabbix/etc/zabbix_agentd.conf
    - source: salt://zabbix/files/zabbix_agentd.conf
    - require: 
      - file: zabbix-agent-init

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
    - unless: ll /var/log/zabbix/ | grep zabbix*
    - require:
      - file: zabbix-log-set

zabbix-pid-set:             
  file.directory:           
    - name: /opt/zabbix/pid 
    - unless: test -d /opt/zabbix/pid            
  cmd.run:                  
    - name: chown -R zabbix:zabbix /opt/zabbix/pid
    - unless: ll /opt/zabbix/pid | grep zabbix*
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
