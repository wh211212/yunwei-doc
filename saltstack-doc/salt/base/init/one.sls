first-sls:
  file.managed:
    - name: /tmp/foo.conf
    - source: salt://init/config/foo.conf
    - user: root
    - group: root
    - mode: 644
