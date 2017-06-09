sync_sysctl:
  file.managed:
    - name: /etc/sysctl.conf
    - source: salt://init/config/sysctl.conf
    - user: root
    - group: root
    - mode: 644
