tcl-install:
  pkg.installed:
    - name: tcl

redis-source-install:
  file.managed:
    - name: /opt/redis-3.2.0.tar.gz
    - source: salt://redis/files/redis-3.2.0.tar.gz 
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - name: cd /opt && tar zxf redis-3.2.0.tar.gz  && cd redis-3.2.0 &&  make && make test && rm -rf redis-3.2.0.tar.gz
    - unless: test -d /opt/redis-3.2.0
    - require:
      - file: redis-source-install

redis.conf-dir-set:
  file.directory:
    - name: /etc/redis
    - user: root
    - group: root
    - mode: 644

redis.conf-set:
  file.managed:
    - name: /etc/redis/6379.conf
    - source: salt://redis/files/redis.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: redis.conf-dir-set

redis-server:
  file.managed:
    - name: /etc/init.d/redis
    - source: salt://redis/files/redis-daemon
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: /etc/init.d/redis start
    - unless: netstat -nltp | grep 6379
    - require:
      - file: redis-server
