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

username caven pass eoswkdtlstjddlf


# zfund vpn

username xiangyonghong password gSNt6rQNSbGyOLr
username xiangyonghong attributes
 vpn-group-policy ROOT
 vpn-framed-ip-address 192.168.103.199 255.255.255.255

 username yangbo password hkUsF7Z1Aq2A2ubs
 username yangbo attributes
  vpn-group-policy ROOT
  vpn-framed-ip-address 192.168.103.187 255.255.255.255

  username zhangxiaodan password BFOsZ4pq7CXe51qS
  username zhangxiaodan attributes
   vpn-group-policy ROOT
   vpn-framed-ip-address 192.168.103.188 255.255.255.255


# 新增vpn账号步骤
BeiaiQ4-ASA-01# configure terminal
BeiaiQ4-ASA-01(config)# username wangyiqiang password BFOsZ4pq7CXe51qs
BeiaiQ4-ASA-01(config)# username wangyiqiang attributes
BeiaiQ4-ASA-01(config-username)# vpn-group-policy ROOT
BeiaiQ4-ASA-01(config-username)# vpn-framed-ip-address 192.168.103.190 255.255$
#
   username aimi password BFOsZ4pq7CXe51qs
   username aimi attributes
    vpn-group-policy ROOT
    vpn-framed-ip-address 192.168.103.191 255.255.255.255
#
   username aimi password BFOsZ4pq7CXe51qsa
   username aimi attributes
    vpn-group-policy ROOT
    vpn-framed-ip-address 192.168.103.194 255.255.255.255
    
   username aimi password hkUsF7Z1Aq2A2ubsa
   username aimi attributes
    vpn-group-policy ROOT
    vpn-framed-ip-address 192.168.103.195 255.255.255.255
    
   username sunyanhai password abUsF7Z1Aq2A2ubsa
   username sunyanhai attributes
    vpn-group-policy ROOT
    vpn-framed-ip-address 192.168.103.194 255.255.255.255
    
   username qiaofei password P71q2nKoI6iflGGo
   username qiaofei attributes
    vpn-group-policy ROOT
    vpn-framed-ip-address 192.168.103.195 255.255.255.255
    
   username yehao password JNim6TBQORDtLGn3
   username yehao attributes
    vpn-group-policy ROOT
    vpn-framed-ip-address 192.168.103.196 255.255.255.255
   username sunming password GMsGCVgeNw6Qj09e
   username sunming attributes
    vpn-group-policy ROOT
    vpn-framed-ip-address 192.168.103.197 255.255.255.255   
    
   username shenguoliang password CsDiNYB32uxXfldF
   username shenguoliang attributes
    vpn-group-policy ROOT
    vpn-framed-ip-address 192.168.103.103 255.255.255.255              