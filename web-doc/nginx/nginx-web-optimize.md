# 企业级Nginx Web服务优化实战

## Nginx基本安全优化

- 调整参数隐藏Nginx软件版本号信息

 编辑nginx.conf,添加：
 
 server_tokens off;
 
- 更改源码隐藏Nginx软件名及版本号

- 更改nginx服务的默认用户

useradd nginx -s /sbin/nologin -M

## 优化Nginx参数提高性能

- 优化nginx进程配置

grep process /proc/cpuinfo | wc -l