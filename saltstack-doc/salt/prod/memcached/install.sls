include:
  - libevent.install

memcached-source-install:
  file.managed:
    - name: /usr/local/src/memcached-1.4.27.tar.gz
    - source: salt://memcached/files/memcached-1.4.27.tar.gz
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - name: cd /usr/local/src && tar zxf memcached-1.4.27.tar.gz && cd memcached-1.4.27 && ./configure --prefix=/usr/local/memcached -with-libevent=/usr/local/libevent && make && make install
    - unless: test -d /usr/local/memcached
    - require:
      - cmd: libevent-source-install
      - file: memcached-source-install
