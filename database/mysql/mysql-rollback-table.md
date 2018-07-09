# mysql 恢复表数据

## table A 

-  从全库备份中抽取出t表的表结构

```
sed -e '/./{H;$!d;}' -e 'x;/CREATE TABLE `A`/!d;q' DB.sql > A.sql (表结构)
```

- 从全库备份中抽取出t表的内容

```
grep 'INSERT INTO `A`' DB.sql > A.sql
```

- 到测试库上恢复

```
# 创建数据库
create database DB;

source /tmp/A.sql; 恢复表结构

source /tmp/A.sql; 恢复表数据
```

- 参考：https://www.jb51.net/article/98090.htm
