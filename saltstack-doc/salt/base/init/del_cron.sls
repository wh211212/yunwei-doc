ntpdate-remove:
  pkg.removed:
    - name: ntpdate
    - unless: rpm -qa | grep ntpdate
unset-crontab:
  cron.absent:
    - name: /usr/bin/ntpdate times.aliyun.com >> /dev/null 2>&1
