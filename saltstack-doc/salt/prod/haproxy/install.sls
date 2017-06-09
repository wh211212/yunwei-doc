include:
 - pkg.pkg-init

haproxy-install:    
 file.managed:    
   - name: /usr/local/src/haproxy-1.6.5.tar.gz
   - source: salt://haproxy/files/haproxy-1.6.5.tar.gz
   - user: root
   - group: root
   - mode: 755
 cmd.run:        
   - name: cd /usr/local/src && tar zxf haproxy-1.6.5.tar.gz && cd haproxy-1.6.5 && make TARGET=linux26 PREFIX=/usr/local/haproxy && make install PREFIX=/usr/local/haproxy
   - unless: test -d /usr/local/haproxy   
   - require:    
     - pkg: pkg-init
     - file: haproxy-install

sync-haproxy:
 file.managed:
   - name: /etc/init.d/haproxy
   - source: salt://haproxy/files/haproxy.init
   - user: root
   - group: root
   - mode: 755
   - require:
     - cmd: haproxy-install
 cmd.run:
   - name: chkconfig --add haproxy
   - unless: chkconfig --list | grep haproxy
   - require:
     - file: /etc/init.d/haproxy

net.ipv4.ip_nonlocal_bind:
 sysctl.present:
   - value: 1

haproxy-config-dir:
 file.directory:
   - name: /etc/haproxy
   - user: root
   - group: root
   - mode: 755

haproxy-log-dir:
  file.directory:
    - name: /var/log/haproxy
    - user: root
    - group: root
    - mode: 755

haproxy-rsyslog:
  file.managed:
    - name: /etc/rsyslog.conf
    - source: salt://haproxy/files/rsyslog.conf
    - user: root
    - group: root
    - mode: 644
  cmd.run: 
    - name: /etc/init.d/rsyslog restart
    - require:
      - file: haproxy-rsyslog
