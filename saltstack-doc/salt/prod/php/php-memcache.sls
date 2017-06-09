include:
  - php.install

memcached-plugin:
  file.managed:
    - name: /usr/local/src/php-memcached-3.0.8.tgz
    - source: salt://php/files/memcached-3.0.8.tgz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src && tar zxf php-memcached-3.0.8.tgz && cd php-memcached-3.0.8 && /opt/php-fastcgi/bin/phpize && ./configure --enable-memcache --with-php-config=/opt/php-fastcgi/bin/php-config && make && make install
    - unless: test -f /opt/php-fastcgi/lib/php/extensions/*/memcached.so
    - require:
      - file: memcached-plugin

enable-memcached:
  file.append:
    - name: /opt/php-fastcgi/etc/php.ini
    - text:
      - extension=memcached.so
