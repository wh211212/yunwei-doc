include:
  - pkg.pkg-init

keepalived-install:
  file.managed:
    - name: /usr/local/src/keepalived-1.2.22.tar.gz
    - source: salt://keepalived/files/keepalived-1.2.22.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src && tar zxf keepalived-1.2.22.tar.gz && cd keepalived-1.2.22 && ./configure --prefix=/usr/local/keepalived --disable-fwmark && make && make install
    - unless: test -d /usr/local/keepalived
    - require:
      - file: keepalived-install

keepalived-sysconfig:
  file.managed:
    - name: /etc/sysconfig/keepalived
    - source: salt://keepalived/files/keepalived.sysconfig
    - user: root
    - group: root
    - mode: 755

keepalived-init:
  file.managed:
    - name: /etc/init.d/keepalived
    - source: salt://keepalived/files/keepalived.init
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: chkconfig keepalived on
    - unless: chkconfig --list | grep keepalived
    - require:
      - file: keepalived-init

keepalived-dir:
  file.directory:
    - name: /etc/keepalived
    - user: root
    - group: root
    - mode: 744
