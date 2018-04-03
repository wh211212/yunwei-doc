# 批量删除redis keys

redis-cli keys "keyname*" | xargs redis-cli del

> 如果redis服务设置了密码，使用下面命令删除：

redis-cli -a password keys "keyname*" | xargs -a password redis-cli del
