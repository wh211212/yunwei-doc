init-epel:
  pkg.installed:
    - sources:
      - epel-release: http://mirrors.aliyun.com/epel/epel-release-latest-6.noarch.rpm
    - unless: rpm -qa | grep epel-release-6-8 
#  cmd.run:
#    - name: rpm -ivh http://mirrors.aliyun.com/epel/epel-release-latest-6.noarch.rpm
