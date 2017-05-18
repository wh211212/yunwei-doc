# cisco asa

## 添加用户密码

telnet 172.16.2.1 # 登录ASA防火墙

configure terminal

username 用户名 pass 密码 （创建账号密码）
username 用户名 attributes
  vpn-framed-ip-address 100.2.2.18 255.255.255.255
  vpn-group-policy ROOT

# 更改用户密码

username 用户名 pass 密码
username xindongfeng pass 9hMtNsN49JdsnLsadL
