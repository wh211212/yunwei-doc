boost-init:
  file.managed:
    - name: /usr/local/src/boost_1_59_0.tar.gz
    - source: salt://mysql/files/boost_1_59_0.tar.gz
  cmd.run:
    - name: cd /usr/local/src && tar zxf boost_1_59_0.tar.gz && mkdir -p /data/mysql/data && mv boost_1_59_0 /data/boost
    - unless: test -d /data/mysql
    - require: 
      - file: boost-init
