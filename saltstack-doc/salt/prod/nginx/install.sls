include:
  - pcre.install
  - user.www
  - pkg.pkg-init

nginx-install:
  file.managed:
    - name: /usr/local/src/nginx-1.10.1.tar.gz
    - source: salt://nginx/files/nginx-1.10.1.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src && tar zxf nginx-1.10.1.tar.gz && cd nginx-1.10.1 && ./configure --prefix=/opt/nginx --user=www --group=www --with-http_ssl_module --with-http_stub_status_module --with-file-aio --with-http_dav_module --with-http_mp4_module --with-http_flv_module --with-http_addition_module --with-http_sub_module --with-pcre=/usr/local/src/pcre-8.39 && make && make install && chown -R www:www /opt/nginx
    - unless: test -d /opt/nginx
    - require:
      - user: www-user-group
      - file: nginx-install
      - cmd: pcre-install
#sed -i -e 's/1.10.1//g' -e 's/nginx\//WS/g' -e 's/"NGINX"/"WS"/g' /usr/local/src/nginx-1.10.1/src/core/nginx.h  #hidden nginx version
