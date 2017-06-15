# port-maping zfund

route add 192.168.0.62 mask 255.255.255.255 10.1.1.1

route add 192.168.0.62 mask 255.255.255.255 10.1.1.1

# aniutv

cat > /srv/salt/prod/init/files/upload.txt << EOF
nkmv3/myweb/Niuke/Publicfile/View/Html/investedufooter.html
nkmv3/myweb/Public/Common/js/js.js
EOF


# aniucom
cat > /srv/salt/prod/init/files/upload.txt << EOF
aniucom/myweb/Niuke/Publicfile/View/Html/header.html
EOF


# neimu

cat > /srv/salt/prod/init/files/upload.txt << EOF
neimu/App/Lib/Action/IndexAction.class.php
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
