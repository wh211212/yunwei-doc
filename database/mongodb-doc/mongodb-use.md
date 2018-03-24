#
https://www.mongodb.com/
https://www.mongodb.com/download-center#community

# mongodb loginin

mongo --port 27017

help # 查看帮助

use admin # 切换到管理员

db.createUser(
  {
    user: "admin",
    pwd: "password",
    roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
  }
)
