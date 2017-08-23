# 运维狗高频命令行精选

- 列出目录里的 前10大文件

du -hs */ | sort -hr | head

- 找文件中重复的行

cat file.txt | sort | uniq -dc

- 获取服务器ip地址
ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'

-  清除文件中的空行

sed '/^$/d' file >newfile

- 查看最常用命令

history | awk '{print $2}' | awk 'BEGIN {FS="|"}{print $1}' | sort | uniq -c | sort -n | tail | sort -nr

- 按修改时间排序 

find /etc/sysconfig/* -type f -printf '%TY-%Tm-%Td %TT %p\n' | sort

- 按大小排序

ls -al | sort +4n

- 把叫做help的文件重命名为help.txt 

find . -name "-help" -exec mv {} help.txt \;

- 从子目录中检索文件并复制到当前目录

find ./ -iname '*avi' -exec cp  {} ./ \;

- 清理僵尸进程

kill -HUP `ps -A -ostat,ppid,pid,cmd | grep -e '^[Zz]' | awk '{print $2}'`

- 清理.svn

rm -rf `find ./ -iname *.svn*`

