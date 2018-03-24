# 使用SonarQube扫描仪分析Maven




- Sonargraph Integration: Skipping project aniu-api-product [tv.aniu:aniu-api-product], since no Sonargraph rules are activated in current SonarQube quality profile [SonarQube] 

> 此报错暂时不影响maven 集成到 sonar上

- 413 Request Entity Too Large

> 原因是nginx默认上传文件的大小是1M，可nginx的设置中修改

解决方法如下：
1.打开nginx配置文件 nginx.conf, 路径一般是：/etc/nginx/nginx.conf。
2.在http{}段中加入 client_max_body_size 20m; 20m为允许最大上传的大小（大小可自定义）。
3.保存后重启nginx，问题解决。

- sonar Failed to upload report - 500: An error has occurred

> Caused by: com.mysql.jdbc.PacketTooBigException: Packet for query is too large (22790518 > 16777216). You can change this value on the server by setting the max_allowed_packet' variable.

show variables like '%max_allowed_packet%';
更改mysql 的max_allowed_packet参数，设置 max_allowed_packet = 64M ,然后重启mysql
[mysqld]
max_allowed_packet=16M
https://dev.mysql.com/doc/refman/5.7/en/packet-too-large.html

