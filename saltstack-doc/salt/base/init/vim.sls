sync_vimrc:
  file.managed:
    - name: /etc/vimrc
    - source: salt://init/config/vimrc
    - user: root
    - group: root
    - mode: 644
