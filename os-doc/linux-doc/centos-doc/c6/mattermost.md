# mattermost
website:
https://docs.mattermost.com/guides/user.html

## install

docker run --name mattermost-preview -d --publish 8065:8065 mattermost/mattermost-preview


## 升级 mattermost

> 要删除现有的Docker预览并运行新版本，请使用：

```
docker stop mattermost-preview
docker rm -v mattermost-preview
```

## 访问容器

```
docker ps
docker exec -ti mattermost-preview /bin/bash
exit # 登出容器
```


# mattermost 配置界面

http://mattermost.aniu.so:8065/admin_console/general/configuration
