# shell 常见错误

## win下编辑的脚本linux上运行出错

一般是脚本的系统格式不一致导致的，win下编辑的脚本格式为doc，但是linux运行的脚本需要是unix格式的，会出现换行不一致错误

:set ff 查看linux上脚本的系统格式，应该是unix，如果是dos，更改为unix，

:set ff=unix

- ff = format

## 免密设置

普通用户authorized_keys的权限必须限定为600（go-rwx），否则普通用户无法实现无密钥访问，而ROOT用户按照默认即可实现无密钥访问