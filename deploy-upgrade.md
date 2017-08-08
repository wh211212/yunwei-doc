# 更新
scp -P54077 /var/lib/jenkins/workspace/aniu-nkm/aniu-nkm-api/target/aniu-api-product_nkm.war /data/svn/aniu-project/aniu-api-product_nkm/target/

# web 更新
salt -N group_web state.sls init.pcdzcj env=prod
salt -N group_web state.sls init.pcdztj env=prod
salt -N group_anzt state.sls init.pcanzt env=prod
salt -N group_wx state.sls init.pcdzcj env=prod
salt -N group_wx state.sls init.pcanzt env=prod

# api更新


