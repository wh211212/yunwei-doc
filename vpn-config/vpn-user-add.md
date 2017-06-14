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

username huangjianhang pass 123qwe!@#

# zfund vpn
username huangjianhang password RFz1wu4jz4U3CBOC encrypted
username huangjianhang attributes
 vpn-group-policy ROOT
 vpn-framed-ip-address 192.168.103.186 255.255.255.255

 username yangbo password hkUsF7Z1Aq2A2ubs encrypted
 username yangbo attributes
  vpn-group-policy ROOT
  vpn-framed-ip-address 192.168.103.187 255.255.255.255

  username zhangxiaodan password BFOsZ4pq7CXe51qS encrypted
  username zhangxiaodan attributes
   vpn-group-policy ROOT
   vpn-framed-ip-address 192.168.103.188 255.255.255.255
