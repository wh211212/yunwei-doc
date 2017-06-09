include:
  - memcached.install
  - user.www

memcached-server:
  cmd.run:
    - name: /usr/local/memcached/bin/memcached -d -m 1024 -p 11211 -c 4096 -u www
    - unless: netstat -nltp | grep 11211
    - require:
      - cmd: memcached-source-install
      - user: www-user-group

memcached-daemon:
  cmd.run:
    - name: echo "/usr/local/memcached/bin/memcached -d -m 1024 -p 11211 -c 4096 -u www" >> /etc/rc.d/rc.local
    - unless: grep memcached /etc/rc.d/rc.local
