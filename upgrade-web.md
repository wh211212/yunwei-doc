# port-maping zfund

route add 192.168.0.62 mask 255.255.255.255 10.1.1.1

route add 192.168.0.66 mask 255.255.255.255 10.1.1.1
# aniutv

cat > /srv/salt/prod/init/files/upload.txt << EOF
wx/Web/Index/Controller/ActivityController.class.php
wx/Web/Index/Controller/ApiController.class.php
wx/Web/Index/View/Activity/fengxianpingce.html
wx/Web/Index/View/Activity/pingcesucc.html
EOF

# aniucom

cat > /srv/salt/prod/init/files/upload.txt << EOF
njdx/myweb/Aniuweb/Publicfile/View/Html/header.html
njdx/myweb/Public/Common/css/public.css
EOF

# neimu

cat > /srv/salt/prod/init/files/upload.txt << EOF
neimu/App/Tpl/Common_Top.html
EOF

# tysx


# zabbix && saltstack

salt -N group_web state.sls init.upgrade env=prod   # web更新

salt -N group_wx state.sls init.upgrade env=prod    # wx 更新

salt -N group_anzt state.sls init.anztweb env=prod  # anzt更新

salt -N group_anzt state.sls init.anztweb env=prod  # neimu 更新

# ansible

/usr/bin/ansible pm.aniu.so -m shell -a '/bin/bash /home/wh/script/upgrade-zentao.sh' -o

ssh root@'pm.aniu.so' '/bin/bash /home/wh/script/upgrade-zentao.sh'
