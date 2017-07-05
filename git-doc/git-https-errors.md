#1. 401 Authorization 问题
执行命令：
git clone https://192.168.1.18/git/project project.git
错误现象：
error: The requested URL returned error: 401 Authorization Required while accessing https://192.168.1.18/project/info/refs

fatal: HTTP request failed

错误原因：
可以看出是因为Authorization的问题。
解决办法：
在执行命令式直接提供username和password，如下
将git clone https://192.168.1.18/git/project 替换成git clone https://username:password@192.168.1.18/git/project
如果不是使用https，还可以修改HOME目录下的.netrc 添加

machine 192.168.1.18 login username password password

.netrc 一般用于ftp的自动登录与简化。基本用法

1.default login <loginname> password <password>
设置登陆站点的用户名和密码
2.binary(asc)
设置文件传输格式
3.runique
防止本机和远程同名的文件被覆盖。
4.prompt off
关闭提示。当使用mget时，总是有很多的提示，用这个参数后，就不再有哪些提示。
5.hash on
每传1k的文件，将在屏幕打出一个#
6.macdef <mac_name>
定义宏，以空行结束。如果定义宏名为init,则该宏命令将在ftp后自动运行。
For example:
machine default login anonymous password user@my.site
macdef init
binary .
runique .
hash on .
prompt off
(空行)        #不可缺



2. 如果使用的是https出现

error:  while accessing https://192.168.1.18/git/project/info/refs

fatal: HTTP request failed

还可能是sslVerify失败， 解决办法：

取消git sslVerify

git config –global http.sslVerify false

3. 用 git 保存空目录
git 和 svn 不同，仅仅跟踪文件的变动，不跟踪目录。所以，一个空目录，如果里面没有文件，即便 git add 这个目录，

另外在别处 check out 的时候，是没有这个空目录的。只跟踪文件变化，不跟踪目录，这么设计是有原因的。

但这会带来一些小麻烦。有时候，确实需要在代码仓库中保留某个空目录。比如测试时需要用到的空目录。

变通的解决办法是在空目录下存一个 .gitignore 文件。然后 git add 此目录后，相当于跟踪了 .gitignore 文件，

产生的“副作用”就是这个“空”目录也纳入“跟踪”，最终的效果是可以 check out 出一个看起来空空的目录。

如果有许多这样的空目录，可以用下面的命令自动补充 .gitignore 文件：

$find . -type d -empty -and -not -regex ./\.git.* -exec touch {}/.gitignore \; 递归找寻当前目录下，

类型为目录，且为空，也没有 .git 开头的文件，在其中用 touch 新建一个空的 .gitignore 文件。然后 git add 之后即可。

如果这些特殊文件会对测试带来干扰，那就只好在测试程序运行具体测试项目之前，先跑一段初始化目录结构的代码。

另外可能还需要编写负责清理的代码。

4. 在不同git库之间执行pull进行merge时，会出现两个不相关的版本分支进行合并的问题。

本身可能没有冲突的地方，但是分支完全不同，想要强行进行merge的话就需要在pull 后面加上 –allow-unrelated-histories，如

git pull origin –allow-unrelated-histories

#
git config --global http.sslVerify false
git clone https://yunwei:anwg123.@gitlab.aniu.so/aniu-web/tv189.git



git remote add origin https://yunwei:anwg123.@gitlab.aniu.so/aniu-web/tv189.git

https://gitlab.aniu.so/aniu-web/tv189.git
