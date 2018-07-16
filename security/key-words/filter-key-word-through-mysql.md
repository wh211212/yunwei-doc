# 网安关键字屏蔽


## 登录 1.2 tysx_s

把关键字添加到filter.txt，上传到1.2上


load data infile '/data/mysql/tysx_s/filter.txt' into table aniu_message_filter lines terminated by'\r\n' (name);

通过上面的sql数据把关键字导入到指定的列中。