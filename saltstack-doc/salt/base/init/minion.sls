sync-minion:
  file.managed:
    - name: /etc/salt/minion
    - source: salt://init/config/minion
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - name: /etc/init.d/salt-minion restart
    - require:
      - file: sync-minion
