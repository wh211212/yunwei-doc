# 蓝鲸社区版升级（v3.1.5-->v3.1.6）

## 升级步骤

- 下载最新的社区版安装包：http://bk.tencent.com/download/

> 蓝鲸社区版程序包:bkce_src-3.1.6.tgz
> 蓝鲸社区版部署脚本: install_ce-1.0.14.tgz

- 把新下载的安装包长上传到中控机上（/data目录）,笔者（192.168.0.206）

> 初始安装目录为/data，执行下面命令

```bash
cd /data
mkdir tmp
tar xf bkce_src-3.1.6.tgz -C tmp/
tar xf install_ce-1.0.14.tgz -C tmp/
```

- 备份配置文件（重要）

> 备份install目录下的：install.config、globals.env、ports.env

```text
1. 如果没有修改过ports.env则不用备份
2. 如果修改过先将ports.env备份过去，然后新增一行：export BKARCHIVA_PORT=8081
3. 将bkarchiva模块添加到install.config
```
- 操作如下：

```bash
$ mkdir backup
$ cp install/install.config backup/
$ cp install/globals.env backup/
$ cp install/ports.env backup/
```

- 同步目录

```bash
$ rsync -a tmp/src/ /data/src/
$ rsync -a tmp/install/ /data/install/
$ cp backup/install.config install/
$ cp backup/globals.env install/
$ cp backup/ports.env install/
```

> 如果需要包管理SAAS，需要在install.config，选择一台机器增加bkarchiva模块

- 开始升级

```bash
$ cd install/
$ ./bkcec sync all
$ ./bkcec upgrade bkdata
$ ./bkcec upgrade cmdb
$ ./bkcec upgrade fta
$ ./bkcec upgrade gse
$ ./bkcec upgrade job
$ ./bkcec upgrade paas
$ ./bkcec upgrade appo
$ ./bkcec upgrade appt
$ ./bkcec install bkarchiva # 若不需要包管理模块，此步骤可以忽略
$ ./bkcec stop bkdata
$ ./bkcec stop cmdb
$ ./bkcec stop fta
$ ./bkcec stop gse
$ ./bkcec stop job
$ ./bkcec stop paas
$ ./bkcec stop appo
$ ./bkcec stop appt
# 请确保所有进程停止后执行启动进程
$ for mod in bkdata cmdb fta gse job paas appo appt; do ./bkcec status $mod; done
# 请确保所有进程停止后执行启动进程
$ ./bkcec start gse
$ ./bkcec start cmdb
$ ./bkcec start job
$ ./bkcec start paas
$ ./bkcec start fta
$ ./bkcec start bkdata
$ ./bkcec initdata appo
$ ./bkcec start appo
$ ./bkcec activate appo
$ ./bkcec initdata appt
$ ./bkcec start appt
$ ./bkcec activate appt
$ ./bkcec start bkarchiva # 若不需要包管理模块，此步骤可以忽略
$ for mod in bkdata cmdb fta gse job paas appo appt bkarchiva; do ./bkcec status $mod; done
```

## 升级单独模块版本参考：

- http://bbs.bk.tencent.com/forum.php?mod=redirect&goto=findpost&ptid=505&pid=1882&fromuid=165
