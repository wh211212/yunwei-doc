# 安装Docker Compose

## 先决条件

> Docker Compose依靠Docker Engine进行任何有意义的工作，确保您已经安装了Docker Engine

## 安装Docker Compose

> https://docs.docker.com/compose/install/

- 使用pip安装

```bash
pip install docker-compose
#
sudo pip install docker-compose
```

- 从github安装

```bash
$ sudo curl -L --fail https://github.com/docker/compose/releases/download/1.17.0/run.sh -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
```

- 升级

> 如果从Compose 1.2或更低版本升级，则在升级Compose之后，需要删除或迁移现有的容器。这是因为，从版本1.3开始，Compose使用Docker标签来跟踪容器，因此需要添加标签来重新创建它们。 如果Compose检测到没有标签创建的容器，它将拒绝运行，这样就不会有两套。如果要继续使用现有的容器（例如，因为它们有要保留的数据卷），可以使用Compose 1.5.x通过以下命令来迁移它们：

```bash
docker-compose migrate-to-labels
# 直接删除
docker rm -f -v myapp_web_1 myapp_db_1 ...
```

- 卸载compose

```bash
sudo rm /usr/local/bin/docker-compose # 使用curl安装的
pip uninstall docker-compose # 使用pip卸载
```
