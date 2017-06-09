base:
  '*':
    - init.env_init
    - users.init
prod:
  '*.example.com':
    - cluster.haproxy-service
    - cluster.haproxy-service-keepalived 
    - web.bbs
  'saltstack-minion.example.com':
    - memcached.service
  'db-mysql':
#    - jdk.install
    - tomcat.install
    - mysql.install
    - php.install
    - nginx.service

dev:
  'db-mysql':
    - zabbix.server
  'saltstack-minion.example.com':
    - zabbix.agent
