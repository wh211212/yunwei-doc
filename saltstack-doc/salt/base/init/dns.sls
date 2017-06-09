sync_dns:
  file.managed:
    - name: /etc/resolv.conf
    - source: salt://init/config/resolv.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
