# config aniu web env

## install nginx

cat nginx.repo
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=0
enabled=1
#https://www.nginx.com/resources/wiki/start/topics/tutorials/install/

- 

[root@web-server-2 yum.repos.d]# yum list | grep nginx
nginx.x86_64                                1.12.1-1.el6.ngx             @nginx 
nginx-all-modules.noarch                    1.10.2-1.el6                 @epel  
nginx-filesystem.noarch                     1.10.2-1.el6                 @epel  
nginx-mod-http-geoip.x86_64                 1.10.2-1.el6                 @epel  
nginx-mod-http-image-filter.x86_64          1.10.2-1.el6                 @epel  
nginx-mod-http-perl.x86_64                  1.10.2-1.el6                 @epel  
nginx-mod-http-xslt-filter.x86_64           1.10.2-1.el6                 @epel  
nginx-mod-mail.x86_64                       1.10.2-1.el6                 @epel  
nginx-mod-stream.x86_64                     1.10.2-1.el6                 @epel  
collectd-nginx.x86_64                       4.10.9-4.el6                 epel   
munin-nginx.noarch                          2.0.33-1.el6                 epel   
nginx-debug.x86_64                          1.8.0-1.el6.ngx              nginx  
nginx-debuginfo.x86_64                      1.12.1-1.el6.ngx             nginx  
nginx-module-geoip.x86_64                   1.12.1-1.el6.ngx             nginx  
nginx-module-geoip-debuginfo.x86_64         1.12.1-1.el6.ngx             nginx  
nginx-module-image-filter.x86_64            1.12.1-1.el6.ngx             nginx  
nginx-module-image-filter-debuginfo.x86_64  1.12.1-1.el6.ngx             nginx  
nginx-module-njs.x86_64                     1.12.1.0.1.10-1.el6.ngx      nginx  
nginx-module-njs-debuginfo.x86_64           1.12.1.0.1.10-1.el6.ngx      nginx  
nginx-module-perl.x86_64                    1.12.1-1.el6.ngx             nginx  
nginx-module-perl-debuginfo.x86_64          1.12.1-1.el6.ngx             nginx  
nginx-module-xslt.x86_64                    1.12.1-1.el6.ngx             nginx  
nginx-module-xslt-debuginfo.x86_64          1.12.1-1.el6.ngx             nginx  
nginx-nr-agent.noarch                       2.0.0-12.el6.ngx             nginx  
pcp-pmda-nginx.x86_64                       3.10.9-9.el6                 base 

- yum install

yum install nginx -y


## install php

yum install php php-fpm php-bcmath php-cli php-common php-embedded php-enchant php-gd php-mbstring php-mcrypt php-soap php-recode php-redis php-tidy php-xml php-xmlrpc php-zts            

 php                                x86_64                  5.3.3-49.el6                              base                     1.1 M
 php-bcmath                         x86_64                  5.3.3-49.el6                              base                      40 k
 php-cli                            x86_64                  5.3.3-49.el6                              base                     2.2 M
 php-common                         x86_64                  5.3.3-49.el6                              base                     530 k
 php-embedded                       x86_64                  5.3.3-49.el6                              base                     1.1 M
 php-enchant                        x86_64                  5.3.3-49.el6                              base                      34 k
 php-fpm                            x86_64                  5.3.3-49.el6                              base                     1.1 M
 php-gd                             x86_64                  5.3.3-49.el6                              base                     111 k
 php-mbstring                       x86_64                  5.3.3-49.el6                              base                     460 k
 php-mcrypt                         x86_64                  5.3.3-5.el6                               epel                      19 k
 php-pecl-redis                     x86_64                  2.2.8-1.el6                               epel                     147 k
 php-recode                         x86_64                  5.3.3-49.el6                              base                      30 k
 php-soap                           x86_64                  5.3.3-49.el6                              base                     145 k
 php-tidy                           x86_64                  5.3.3-49.el6                              base                      41 k
 php-xml                            x86_64                  5.3.3-49.el6                              base                     108 k
 php-xmlrpc                         x86_64                  5.3.3-49.el6                              base                      58 k
 php-zts 
 
## 配置php 


 