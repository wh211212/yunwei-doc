tomcat-base:
  file.directory:
    - name: /opt/tomcats
    - unless: test -d /opt/tomcats

tomcat-init:
  file.managed:
    - name: /opt/tomcats/apache-tomcat-7.0.70.tar.gz
    - source: salt://tomcat/files/apache-tomcat-7.0.70.tar.gz
  cmd.run:
    - name: cd /opt/tomcats && tar zxvf apache-tomcat-7.0.70.tar.gz && cp -rf apache-tomcat-7.0.70 tomcat-8081 && rm -rf apache-tomcat-7.0.70
    - unless: test -d /opt/tomcats/tomcat-8081
    - require:
      - file: tomcat-init

tomcat-set:
  file.managed:
    - name: /opt/tomcats/tomcat-8081/conf/server.xml
    - source: salt://tomcat/files/server.xml

catalina.sh-set:
  file.managed:
    - name: /opt/tomcats/tomcat-8081/bin/catalina.sh
    - source: salt://tomcat/files/catalina.sh
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: /opt/tomcats/tomcat-8081/bin/catalina.sh start && echo "/opt/tomcatas/tomcat-8081/bin/startup.sh" >> /etc/rc.local
    - unless: grep tomcat-8081 /etc/rc.local

catalina.out-rorate:
  file.managed:
    - name: /etc/logrotate.d/tomcat
    - source: salt://tomcat/files/tomcat
    - user: root
    - group: root
    - mode: 644

tomcat-gui-set:
  file.managed:
    - name: /opt/tomcats/tomcat-8081/conf/tomcat-users.xml
    - source: salt://tomcat/files/tomcat-users.xml
  cmd.run:
    - name: /opt/tomcats/tomcat-8081/bin/shutdown.sh && /opt/tomcats/tomcat-8081/bin/startup.sh
    - require:
      - file: tomcat-gui-set
