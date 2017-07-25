# 使用nginx代理jira和confluence

https://confluence.atlassian.com/jirakb/integrating-jira-with-nginx-426115340.html

> jira 和 confluence部署到在一台机器上,都使用 80 端口访问。使用 nginx 代理,直接使用 proxy_pass http://127.0.0.1:8080 jira 的首页小插件不太好使,发现使用 try_files 可以。

## 增加jira_proxy.conf配置

```
vim /etc/nginx/jira_proxy.conf

proxy_connect_timeout 30s;
proxy_send_timeout 120;
proxy_read_timeout 120;
proxy_buffer_size 32k;
proxy_buffers 4 32k;
proxy_busy_buffers_size 64k;
proxy_redirect off;
proxy_hide_header Vary;
proxy_set_header Accept-Encoding '';
proxy_set_header Host $host;
proxy_set_header Referer $http_referer;
proxy_set_header Cookie $http_cookie;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```

## 增加jira.aniu.so.conf配置

```
# vim /etc/nginx/conf.d/jira_proxy.conf
server {
    listen       80;
    server_name  jira.aniu.so;

    location / {
            try_files $uri @jira;
    }

    location @jira {
            internal;
            proxy_pass http://127.0.0.1:8080;
            include jira_proxy.conf;
    }
}

server {
    listen       80;
    server_name  wiki.aniu.so;

    location / {
            try_files $uri @confluence;
    }

    location @confluence {
            internal;
            proxy_pass http://127.0.0.1:8090;
            include jira_proxy.conf;
    }
}
```

## 在这个例子中，我们想要一个设置，可以在地址http://www.atlassian.com/jira（标准HTTP端口80）上访问JIRA，而JIRA本身可以使用上下文路径/ jira监听端口8080。
