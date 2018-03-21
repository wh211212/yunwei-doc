# 对已经运行的redis服务进行加固

查看redis进程是否正常运行

ps -ef | grep redis

搜索redis.conf配置文件所在位置

find / -name redis.conf

# 修改redis.conf后重启redis服务

更改redis的默认端口

禁用高危命令

添加redis访问密码验证

# 重启redis

/path/redis-server /path/redis.conf &