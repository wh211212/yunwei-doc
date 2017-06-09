include:
  - php.pkg-php-init
  - user.www

php-install:
  file.managed:
    - name: /usr/local/src/php-7.0.8.tar.gz
    - source: salt://php/files/php-7.0.8.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src && tar zxf php-7.0.8.tar.gz && cd php-7.0.8&&  ./configure --prefix=/opt/php-fastcgi --with-pdo-mysql=mysqlnd --with-mysqli=mysqlnd --with-mysql=mysqlnd --with-iconv-dir --with-jpeg-dir --with-png-dir --with-zlib --enable-xml  --with-libxml-dir --with-curl --enable-bcmath --enable-shmop --enable-sysvsem  --enable-inline-optimization --enable-mbregex --with-openssl --enable-mbstring --with-gd --enable-gd-native-ttf --with-freetype-dir=/usr/lib64 --with-gettext=/usr/lib64 --enable-sockets --with-xmlrpc --enable-zip --enable-soap --disable-debug --enable-opcache --enable-zip --with-config-file-path=/opt/php-fastcgi/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www && make && make install
    - require:
      - file: php-install
      - user: www-user-group
    - unless: test -d /opt/php-fastcgi

pdo-plugin:
  cmd.run:
    - name: cd /usr/local/src/php-7.0.8/ext/pdo_mysql/ && /opt/php-fastcgi/bin/phpize && ./configure --with-php-config=/opt/php-fastcgi/bin/php-config && make && make install
    - unless: test -f /opt/php-fastcgi/lib/php/extensions/*/pdo_mysql.so
    - require:
      - cmd: php-install

php-ini:
  file.managed:
    - name: /opt/php-fastcgi/etc/php.ini
    - source: salt://php/files/php.ini-production
    - user: root
    - group: root
    - mode: 644

php-fpm:
  file.managed:
    - name: /opt/php-fastcgi/etc/php-fpm.conf
    - source: salt://php/files/php-fpm.conf.default
    - user: root
    - group: root
    - mode: 644

php-config:
  file.managed:
    - name: /opt/php-fastcgi/etc/php-fpm.d/www.conf
    - source: salt://php/files/www.conf.default
    - user: root
    - group: root
    - mode: 644

php-fastcgi-service:
  file.managed:
    - name: /etc/init.d/php-fpm
    - source: salt://php/files/init.d.php-fpm
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: chkconfig --add php-fpm
    - unless: chkconfig --list | grep php-fpm
    - require:
      - file: php-fastcgi-service
  service.running:
    - name: php-fpm
    - enable: True
    - require:
      - cmd: php-fastcgi-service
    - watch:
      - file: php-ini
      - file: php-fpm

php-info:
  cmd.run:
    - name: echo "<?php phpinfo(); ?>" >> /opt/nginx/html/phpinfo.php
    - unless: test -f /opt/nginx/html/phpinfo.php
