jdk-rpm-install:
  file.managed:
    - name: /usr/local/src/jdk-7u79-linux-x64.rpm
    - source: salt://jdk/files/jdk-7u79-linux-x64.rpm
    - user: root
    - group: root
    - mode: 644

jdk-env-set:
  file.managed:
    - name: /etc/profile.d/jdk.sh
    - source: salt://jdk/files/jdk.sh
    - root: root
    - group: root
    - mode: 755
  cmd.run:
    - name:  cd /usr/local/src && rpm -ivh jdk-7u79-linux-x64.rpm && bash /etc/profile.d/jdk.sh && source /etc/profile
    - unless: test -d /usr/java/jdk1.7.0_79
    - require: 
      - file: jdk-env-set
