ntpdate-init:
  pkg.installed:
    - name: ntpdate
set-crontab:
  cron.present:
    - name: /usr/bin/ntpdate times.aliyun.com >> /dev/null 2>&1
    - user: root
    - minute: '*5'
