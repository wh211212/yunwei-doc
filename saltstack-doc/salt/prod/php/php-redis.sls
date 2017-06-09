include:
  - php.install

redis-plugin:
  file.managed:
    - name: /usr/local/src/php-redis-3.0.0.tgz
    - source: salt://php/files/redis-3.0.0.tgz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src && tar zxf php-redis-3.0.0.tgz && cd php-redis-3.0.0 && /opt/php-fastcgi/bin/phpize && ./configure --with-php-config=/opt/php-fastcgi/bin/php-config && make && make install
    - unless: test -f /opt/php-fastcgi/lib/php/extensions/*/redis.so
    - require:
      - file: redis-plugin

enable-redis:
  file.append:
    - name: /opt/php-fastcgi/etc/php.ini
    - text:
      - extension=redis.so
