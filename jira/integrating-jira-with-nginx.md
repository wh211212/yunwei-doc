# 配置nginx反向代理jira并实现https

## 配置Tomcat

> 在本文中，我们设置可以在地址http://jira.aniu.so/jira（标准HTTP端口80）上访问JIRA，而JIRA本身可以使用上下文路径/ jira监听端口8080。

### 修改配置文件server.xml(在jira安装目录下)

```
更改前：
<Context docBase="${catalina.home}/atlassian-jira" path="" reloadable="false" useHttpOnly="true">

更改后：
<Context docBase="${catalina.home}/atlassian-jira" path="/jira" reloadable="false" useHttpOnly="true">
```

### 配置连接器

- 添加proxyName和proxyPort元素(用适当的属性替换它们)，以及下面的另一个连接器——这用于故障排除，以绕过代理:

```
<!-- Nginx Proxy Connector --> # 仅仅使用nginx不使用https
<Connector port="8080" maxThreads="150" minSpareThreads="25" connectionTimeout="20000" enableLookups="false" maxHttpHeaderSize="8192" protocol="HTTP/1.1" useBodyEncodingForURI="true" redirectPort="8443" acceptCount="100" disableUploadTimeout="true"
proxyName="jira.aniu.so" proxyPort="80"/>

<!-- OPTIONAL,Nginx Proxy Connector with https -->  # 本文使用这次方式
<Connector port="8081" maxThreads="150" minSpareThreads="25" connectionTimeout="20000" enableLookups="false" maxHttpHeaderSize="8192" protocol="HTTP/1.1" useBodyEncodingForURI="true" redirectPort="8443" acceptCount="100" disableUploadTimeout="true"
proxyName="jira.aniu.so" proxyPort="443" scheme="https" secure="true"/>

<!-- Standard HTTP Connector -->
<Connector port="8082" maxThreads="150" minSpareThreads="25" connectionTimeout="20000" enableLookups="false" maxHttpHeaderSize="8192" protocol="HTTP/1.1" useBodyEncodingForURI="true" redirectPort="8443" acceptCount="100" disableUploadTimeout="true"/>
```

### 配置nginx

> 配置https，需要证书，使用CSR在线生成工具（https://ssl.sundns.com/tool/csrgenerator），生成csr和key文件，方便后面的使用

```
# 在线制作的csr和key上传到服务器/etc/pki/tls/certs目录下，如下：

-rw-r--r--  1 root root    1050 Jul 25 20:26 jira.aniu.so.csr
-rw-r--r--  1 root root    1675 Jul 25 20:27 jira.aniu.so.key
# 使用下面命令生成crt文件，如下：
[root@sh-kvm-3-1 certs]# openssl x509 -in jira.aniu.so.csr -out jira.aniu.so.crt -req -signkey jira.aniu.so.key -days 3650
Signature ok
subject=/C=CN/O=aniu/OU=DevOps/ST=Shanghai/L=Shanghai/CN=jira.aniu.so/emailAddress=yunwei@aniu.tv
Getting Private key
```

- 更新Nginx设置以拥有以下服务器(以FQDN和jira-hostname替换jira.aniu.so，并使用服务器的主机名):

```
# cat jira.aniu.so.conf （nginx使用yum安装）
server {
  listen 80;
  server_name jira.aniu.so;
  return 301 https://$host$request_uri;
}

server {
  listen 443 ssl;
  server_name jenkins.aniu.so;
  access_log  /var/log/nginx/jira.aniu.so.access.log  main;
  error_log  /var/log/nginx/jira.aniu.so.error.log;

  ssl                  on;
  ssl_certificate      /etc/pki/tls/certs/jira.aniu.so.crt;
  ssl_certificate_key  /etc/pki/tls/certs/jira.aniu.so.key;

  location /jira {
    proxy_set_header        Host $host:$server_port;
    proxy_set_header        X-Real-IP $remote_addr;
    proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header        X-Forwarded-Proto $scheme;
    proxy_redirect          http:// https://;
    proxy_pass              http://sh-kvm-3-1:8080/jira; # sh-kvm-3-1这里为jira所在服务器的主机名
    client_max_body_size    10M;
    proxy_set_header        X-Forwarded-Host $host;
    proxy_set_header        X-Forwarded-Server $host;
    # Required for new HTTP-based CLI
    proxy_http_version 1.1;
    proxy_request_buffering off;
  }
}
# 更改完成之后重启jira和nginx，访问https://jira.aniu.so/jira,能看到jira集成nginx已经成功
```
![jira-nginx-https](http://img.blog.csdn.net/20170725211012864?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
## 参考链接

- https://confluence.atlassian.com/jirakb/integrating-jira-with-nginx-426115340.html
