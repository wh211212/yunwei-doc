# 企业级Nginx Web服务优化实战

## Nginx基本安全优化

- 调整参数隐藏Nginx软件版本号信息

```
# 编辑nginx.conf,http位置添加：
 server_tokens off;
```
- 更改源码隐藏Nginx软件名及版本号

> 编译安装的nginx修改nginx.h和ngx_http_header_filter_module.c、ngx_http_special_response.c

```
sed -i 's#Server: nginx#Server: aniu#g' h和ngx_http_header_filter_module
```

- 更改nginx服务的默认用户

```bash
useradd nginx -s /sbin/nologin -M
```

## 优化Nginx参数提高性能

- 优化nginx进程配置
```bash
grep process /proc/cpuinfo | wc -l # 表示一颗CPU四核
sed -i 's#worker_processes 1#worker_processes 4#g' /etc/nginx/nginx.conf 
```

## Nginx事件处理模型优化

```bash
events {
    use epoll;
    worker_connections  16384; # nginx单个进程允许客户端的最大连接数
    multi_accept on;
}
```

- 开启高效文件传输模式

```bash
    sendfile        on;
    tcp_nopush     on;
    tcp_nodely on
```

- 上传文件大小限制

```bash
client_max_boby_size 8m;
```

## 概述

- 安全优化：隐藏Nginx软件名及版本号、集群中各角色服务站点目录权限控制策略、站点目录下所有的文件和目录访问控制
- 性能加安全优化：连接超时参数及FastCGI相关参数调优、CDN加速、Nginx并发连接数及请求速率控制
- 性能优化：gzip压缩功能、expires缓存功能、rebots.txt协议及防爬虫优化解决方案、静态资源防盗链
- 用户体验优化：错误页面优雅展示、
