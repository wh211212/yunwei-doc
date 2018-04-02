# MongoDB创建用户使用
https://www.mongodb.com/
https://www.mongodb.com/download-center#community

# mongodb loginin

```bash
mongo --port 27017

help # 查看帮助

use admin # 切换到管理员

db.createUser(
  {
    user: "Aniumongodb",
    pwd: "Aniumongodb123.",
    roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
  }
)
# 
[root@mongodb ~]# mongo --port 27017
MongoDB shell version v3.6.3
connecting to: mongodb://127.0.0.1:27017/
MongoDB server version: 3.6.3
Server has startup warnings: 
2018-04-02T17:12:06.214+0800 I STORAGE  [initandlisten] 
2018-04-02T17:12:06.214+0800 I STORAGE  [initandlisten] ** WARNING: Using the XFS filesystem is strongly recommended with the WiredTiger storage engine
2018-04-02T17:12:06.214+0800 I STORAGE  [initandlisten] **          See http://dochub.mongodb.org/core/prodnotes-filesystem
2018-04-02T17:12:07.413+0800 I CONTROL  [initandlisten] 
2018-04-02T17:12:07.413+0800 I CONTROL  [initandlisten] ** WARNING: Access control is not enabled for the database.
2018-04-02T17:12:07.413+0800 I CONTROL  [initandlisten] **          Read and write access to data and configuration is unrestricted.
2018-04-02T17:12:07.414+0800 I CONTROL  [initandlisten] 
MongoDB Enterprise > use admin
switched to db admin
MongoDB Enterprise > db.createUser(
...   {
...     user: "Aniumongodb",
...     pwd: "Aniumongodb123.",
...     roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
...   }
... )
Successfully added user: {
        "user" : "Aniumongodb",
        "roles" : [
                {
                        "role" : "userAdminAnyDatabase",
                        "db" : "admin"
                }
        ]
}
MongoDB Enterprise > exit
bye
```

## MongoDB用户简介

```bash
Built-In Roles（内置角色）：
    1. 数据库用户角色：read、readWrite;
    2. 数据库管理角色：dbAdmin、dbOwner、userAdmin；
    3. 集群管理角色：clusterAdmin、clusterManager、clusterMonitor、hostManager；
    4. 备份恢复角色：backup、restore；
    5. 所有数据库角色：readAnyDatabase、readWriteAnyDatabase、userAdminAnyDatabase、dbAdminAnyDatabase
    6. 超级用户角色：root  
    // 这里还有几个角色间接或直接提供了系统超级用户的访问（dbOwner 、userAdmin、userAdminAnyDatabase）
    7. 内部角色：__system
    
# 用户角色权限
Read：允许用户读取指定数据库
readWrite：允许用户读写指定数据库
dbAdmin：允许用户在指定数据库中执行管理函数，如索引创建、删除，查看统计或访问system.profile
userAdmin：允许用户向system.users集合写入，可以找指定数据库里创建、删除和管理用户
clusterAdmin：只在admin数据库中可用，赋予用户所有分片和复制集相关函数的管理权限。
readAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的读权限
readWriteAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的读写权限
userAdminAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的userAdmin权限
dbAdminAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的dbAdmin权限。
root：只在admin数据库中可用。超级账号，超级权限    
```

- 创建超级管理员账户

```bash
db.createUser(
...  {
...    user: "Aniudba",
...    pwd: "Aniudba123.",
...    roles: [
...       { role: "root", db: "admin" }
...    ]
...  }
... )
Successfully added user: {
        "user" : "Aniudba",
        "roles" : [
                {
                        "role" : "root",
                        "db" : "admin"
                }
        ]
}
```


## MongoDB启动错误

- WARNING: soft rlimits too low. rlimits set to 1024 processes, 16392 files. Number of processes should be at least 8196 

```bash
修改 /etc/security/limits.d/90-nproc.conf

*          soft    nproc     16392 # 1024改为16392
root       soft    nproc     unlimited

重启MongoDB服务  /etc/init.d/mongod restart
```
- MongoDB 连接工具
 
- WARNING: Using the XFS filesystem is strongly recommended with the WiredTiger storage engine


- WARNING: Access control is not enabled for the database.Read and write access to data and configuration is unrestricted.


- 参考：http://www.cnblogs.com/zhoujinyi/p/4610050.html
- 
