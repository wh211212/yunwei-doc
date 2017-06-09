sync-ssh:
  file.managed:
    - name: /etc/ssh/sshd_config
    - source: salt://init/config/sshd_config
    - user: root
    - group: root
    - mode: 644
#  cmd.run:
#    - name: /etc/init.d/sshd restart
#    - require:
#      - file: sync-ssh
  service.running:
    - name: sshd
    - enable: True
    - reload: True
    - require:
      - file: sync-ssh
