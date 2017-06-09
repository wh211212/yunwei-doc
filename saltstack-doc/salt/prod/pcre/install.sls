pcre-install:
  file.managed:
    - name: /usr/local/src/pcre-8.39.tar.gz
    - source: salt://pcre/files/pcre-8.39.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src && tar zxf pcre-8.39.tar.gz && cd pcre-8.39 && ./configure --prefix=/usr/local/pcre && make && make install
    - unless: test -d /usr/local/pcre
    - require:
      - file: pcre-install
