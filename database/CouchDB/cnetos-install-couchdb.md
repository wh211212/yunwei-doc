# CentOS6 mininal 安装CouchDB2 详细版

> couchdb官网： http://couchdb.apache.org/

- 安装依赖

```
- Erlang OTP (>=R61B03, =<19.x)
- ICU
- OpenSSL
- Mozilla SpiderMonkey (1.8.5)
- GNU Make
- GNU Compiler Collection
- libcurl
- help2man
- Python (>=2.7) for docs
- Python Sphinx (>=1.1.3)
```

> 参考教程：http://docs.couchdb.org/en/2.0.0/install/unix.html

```
# 初始设置，避免不必要的权限问题

/etc/init.d/iptables stop
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# 安装依赖
yum -y update
yum -y groupinstall "Development Tools" "Development Libraries"
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
yum install autoconf automake curl-devel help2man libicu-devel libtool perl-Test-Harness wget libicu-devel curl-devel ncurses-devel libtool libxslt fop java-1.7.0-openjdk java-1.7.0-openjdk-devel unixODBC unixODBC-devel vim openssl-devel
```

## 源码安装erlang

```
yum install erlang-asn1 erlang-erts erlang-eunit erlang erlang-os_mon erlang-xmerl

wget http://erlang.org/download/otp_src_19.3.tar.gz   #满足依赖的最新版erlang
tar -xvf otp_src_19.3.tar.gz
cd otp_src_19.3
./configure && make
make install
```

## 源码安装 js-devel

> js-devel-1.8.5  # 无yum安装包

```
wget http://ftp.mozilla.org/pub/mozilla.org/js/js185-1.0.0.tar.gz
cd js-1.8.5/js/src
./configure && make
sudo make install
```

## 安装autoconf-archive

> 配置puias-computational.repo 安装autoconf-arch

```
vim /etc/yum.repos.d/puias-computational.repo
[PUIAS_6_computational]
name=PUIAS computational Base $releasever - $basearch
mirrorlist=http://puias.math.ias.edu/data/puias/computational/$releasever/$basearch/mirrorlist
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puias

Install autoconf-archive rpm package:
yum install autoconf-archive -y
```

## 源码安装CouchDB

```
wget http://mirror.bit.edu.cn/apache/couchdb/source/2.0.0/apache-couchdb-2.0.0.tar.gz
tar zxvf apache-couchdb-2.0.0.tar.gz
cd apache-couchdb-2.0.0
./configure
make release  # 这里有报错，根据解决方法修改完成之后重新make release,在文章末尾
```

## 添加用户启动couchdb

```
# groupadd CouchDB Administrator
# adduser --system --no-create-home --shell /bin/bash --group --gecos "CouchDB Administrator" couchdb  # 默认CouchDB Administrator不存在，官网命令有点坑
# - adduser: group '--gecos' does not exist

adduser --system --no-create-home --shell /bin/bash -c "CouchDB Administrator" couchdb  # 使用此条命令
mv /usr/local/src/apache-couchdb-2.0.0/rel/couchdb /usr/local/
chown -R couchdb:couchdb /usr/local/couchdb
# find /usr/local/couchdb -type d -exec chmod 0770 {} \;
# chmod 0644 /usr/local/couchdb/etc/*

```

## 配置couchdb，特别重要

```
vim /usr/local/couchdb/etc/vm.args

-name couchdb@n1couchdb.aniu.so

> 注意：前提时设置系统需要设置hostname，修改完成系统hosts文件为

127.0.0.1   localhost localhost.localdomain n1couchdb.aniu.so
0.0.0.0   localhost localhost.localdomain n1couchdb.aniu.so
192.168.0.154 n1couchdb.aniu.so

hostname n1couchdb.aniu.so
sed -i 's/localhost.localdomain/n1couchdb.aniu.so/g' /etc/sysconfig/network

> 上面几步操作是修改hostname，方便识别，为后面配置couchdb集群方便

# -kernel inet_dist_listen_min 9100
# -kernel inet_dist_listen_max 9200

> 上面两个参数暂时不用，配置集群的时候在使用

# 修改couchdb启动时默认监听的ip，默认127.0.0.1，不能通过浏览器进行初始化设置，改为0.0.0.0

sed -i 's/127.0.0.1/0.0.0.0/g' /usr/local/couchdb/etc/default.ini

```

> 配置完成之后使用couchdb用户启动couchdb

```
su - couchdb
cd /usr/local/couchdb
./bin/couchdb

```

- 启动成功界面如下：

```
[info] 2017-07-04T13:09:39.587046Z couchdb@n1couchdb.aniu.so <0.9.0> -------- Application couch_log started on node 'couchdb@n1couchdb.aniu.so'
[info] 2017-07-04T13:09:39.593768Z couchdb@n1couchdb.aniu.so <0.9.0> -------- Application folsom started on node 'couchdb@n1couchdb.aniu.so'
[info] 2017-07-04T13:09:39.649564Z couchdb@n1couchdb.aniu.so <0.9.0> -------- Application couch_stats started on node 'couchdb@n1couchdb.aniu.so'
[info] 2017-07-04T13:09:39.649666Z couchdb@n1couchdb.aniu.so <0.9.0> -------- Application khash started on node 'couchdb@n1couchdb.aniu.so'
[info] 2017-07-04T13:09:39.662118Z couchdb@n1couchdb.aniu.so <0.9.0> -------- Application couch_event started on node 'couchdb@n1couchdb.aniu.so'
[info] 2017-07-04T13:09:39.670377Z couchdb@n1couchdb.aniu.so <0.9.0> -------- Application ibrowse started on node 'couchdb@n1couchdb.aniu.so'
[info] 2017-07-04T13:09:39.678054Z couchdb@n1couchdb.aniu.so <0.9.0> -------- Application ioq started on node 'couchdb@n1couchdb.aniu.so'
[info] 2017-07-04T13:09:39.678117Z couchdb@n1couchdb.aniu.so <0.9.0> -------- Application mochiweb started on node 'couchdb@n1couchdb.aniu.so'
[info] 2017-07-04T13:09:39.678238Z couchdb@n1couchdb.aniu.so <0.9.0> -------- Application oauth started on node 'couchdb@n1couchdb.aniu.so'
[info] 2017-07-04T13:09:39.689266Z couchdb@n1couchdb.aniu.so <0.210.0> -------- Apache CouchDB 2.0.0 is starting.

[info] 2017-07-04T13:09:39.689396Z couchdb@n1couchdb.aniu.so <0.211.0> -------- Starting couch_sup
[info] 2017-07-04T13:09:39.937994Z couchdb@n1couchdb.aniu.so <0.210.0> -------- Apache CouchDB has started. Time to relax.

[info] 2017-07-04T13:09:39.938230Z couchdb@n1couchdb.aniu.so <0.210.0> -------- Apache CouchDB has started on http://0.0.0.0:5986/
[info] 2017-07-04T13:09:39.938366Z couchdb@n1couchdb.aniu.so <0.9.0> -------- Application couch started on node 'couchdb@n1couchdb.aniu.so'
[info] 2017-07-04T13:09:39.938520Z couchdb@n1couchdb.aniu.so <0.9.0> -------- Application ets_lru started on node 'couchdb@n1couchdb.aniu.so'
[info] 2017-07-04T13:09:39.953625Z couchdb@n1couchdb.aniu.so <0.9.0> -------- Application rexi started on node 'couchdb@n1couchdb.aniu.so'
[error] 2017-07-04T13:09:40.065167Z couchdb@n1couchdb.aniu.so <0.293.0> -------- ** System running to use fully qualified hostnames **
** Hostname localhost is illegal **

[info] 2017-07-04T13:09:40.099794Z couchdb@n1couchdb.aniu.so <0.9.0> -------- Application mem3 started on node 'couchdb@n1couchdb.aniu.so'
[info] 2017-07-04T13:09:40.099886Z couchdb@n1couchdb.aniu.so <0.9.0> -------- Application fabric started on node 'couchdb@n1couchdb.aniu.so'
[info] 2017-07-04T13:09:40.126321Z couchdb@n1couchdb.aniu.so <0.9.0> -------- Application chttpd started on node 'couchdb@n1couchdb.aniu.so'
[notice] 2017-07-04T13:09:40.145151Z couchdb@n1couchdb.aniu.so <0.328.0> -------- chttpd_auth_cache changes listener died database_does_not_exist at mem3_shards:load_shards_from_db/6(line:327) <= mem3_shards:load_shards_from_disk/1(line:315) <= mem3_shards:load_shards_from_disk/2(line:331) <= mem3_shards:for_docid/3(line:87) <= fabric_doc_open:go/3(line:38) <= chttpd_auth_cache:ensure_auth_ddoc_exists/2(line:187) <= chttpd_auth_cache:listen_for_changes/1(line:134)
[error] 2017-07-04T13:09:40.145263Z couchdb@n1couchdb.aniu.so emulator -------- Error in process <0.329.0> on node 'couchdb@n1couchdb.aniu.so' with exit value:
{database_does_not_exist,[{mem3_shards,load_shards_from_db,"_users",[{file,"src/mem3_shards.erl"},{line,327}]},{mem3_shards,load_shards_from_disk,1,[{file,"src/mem3_shards.erl"},{line,315}]},{mem3_shards,load_shards_from_disk,2,[{file,"src/mem3_shards.erl"},{line,331}]},{mem3_shards,for_docid,3,[{file,"src/mem3_shards.erl"},{line,87}]},{fabric_doc_open,go,3,[{file,"src/fabric_doc_open.erl"},{line,38}]},{chttpd_auth_cache,ensure_auth_ddoc_exists,2,[{file,"src/chttpd_auth_cache.erl"},{line,187}]},{chttpd_auth_cache,listen_for_changes,1,[{file,"src/chttpd_auth_cache.erl"},{line,134}]}]}

[info] 2017-07-04T13:09:40.151849Z couchdb@n1couchdb.aniu.so <0.9.0> -------- Application couch_index started on node 'couchdb@n1couchdb.aniu.so'
[info] 2017-07-04T13:09:40.151985Z couchdb@n1couchdb.aniu.so <0.9.0> -------- Application couch_mrview started on node 'couchdb@n1couchdb.aniu.so'
[info] 2017-07-04T13:09:40.152078Z couchdb@n1couchdb.aniu.so <0.9.0> -------- Application couch_plugins started on node 'couchdb@n1couchdb.aniu.so'
[info] 2017-07-04T13:09:40.193218Z couchdb@n1couchdb.aniu.so <0.9.0> -------- Application couch_replicator started on node 'couchdb@n1couchdb.aniu.so'
[info] 2017-07-04T13:09:40.193271Z couchdb@n1couchdb.aniu.so <0.9.0> -------- Application couch_peruser started on node 'couchdb@n1couchdb.aniu.so'
[info] 2017-07-04T13:09:40.205124Z couchdb@n1couchdb.aniu.so <0.9.0> -------- Application ddoc_cache started on node 'couchdb@n1couchdb.aniu.so'
[info] 2017-07-04T13:09:40.225182Z couchdb@n1couchdb.aniu.so <0.9.0> -------- Application global_changes started on node 'couchdb@n1couchdb.aniu.so'
[info] 2017-07-04T13:09:40.225319Z couchdb@n1couchdb.aniu.so <0.9.0> -------- Application jiffy started on node 'couchdb@n1couchdb.aniu.so'
[info] 2017-07-04T13:09:40.233555Z couchdb@n1couchdb.aniu.so <0.9.0> -------- Application mango started on node 'couchdb@n1couchdb.aniu.so'
[info] 2017-07-04T13:09:40.241861Z couchdb@n1couchdb.aniu.so <0.9.0> -------- Application setup started on node 'couchdb@n1couchdb.aniu.so'
[info] 2017-07-04T13:09:40.241950Z couchdb@n1couchdb.aniu.so <0.9.0> -------- Application snappy started on node 'couchdb@n1couchdb.aniu.so'
[notice] 2017-07-04T13:09:45.145647Z couchdb@n1couchdb.aniu.so <0.328.0> -------- chttpd_auth_cache changes listener died database_does_not_exist at mem3_shards:load_shards_from_db/6(line:327) <= mem3_shards:load_shards_from_disk/1(line:315) <= mem3_shards:load_shards_from_disk/2(line:331) <= mem3_shards:for_docid/3(line:87) <= fabric_doc_open:go/3(line:38) <= chttpd_auth_cache:ensure_auth_ddoc_exists/2(line:187) <= chttpd_auth_cache:listen_for_changes/1(line:134)
[error] 2017-07-04T13:09:45.145807Z couchdb@n1couchdb.aniu.so emulator -------- Error in process <0.455.0> on node 'couchdb@n1couchdb.aniu.so' with exit value:
{database_does_not_exist,[{mem3_shards,load_shards_from_db,"_users",[{file,"src/mem3_shards.erl"},{line,327}]},{mem3_shards,load_shards_from_disk,1,[{file,"src/mem3_shards.erl"},{line,315}]},{mem3_shards,load_shards_from_disk,2,[{file,"src/mem3_shards.erl"},{line,331}]},{mem3_shards,for_docid,3,[{file,"src/mem3_shards.erl"},{line,87}]},{fabric_doc_open,go,3,[{file,"src/fabric_doc_open.erl"},{line,38}]},{chttpd_auth_cache,ensure_auth_ddoc_exists,2,[{file,"src/chttpd_auth_cache.erl"},{line,187}]},{chttpd_auth_cache,listen_for_changes,1,[{file,"src/chttpd_auth_cache.erl"},{line,134}]}]}
```
## 查看couchdb进程

```
[root@n1couchdb ~]# ps -ef | grep couchdb
couchdb   3582     1  0 20:59 ?        00:00:00 /usr/local/couchdb/bin/../erts-8.3/bin/epmd -daemon
root      3804  3789  0 21:06 pts/2    00:00:00 su - couchdb
couchdb   3805  3804  0 21:06 pts/2    00:00:00 -bash
couchdb   3901  3805  3 21:09 pts/2    00:00:04 /usr/local/couchdb/bin/../erts-8.3/bin/beam.smp -K true -A 16 -Bd -- -root /usr/local/couchdb/bin/.. -progname couchdb -- -home /home/couchdb -- -boot /usr/local/couchdb/bin/../releases/2.0.0/couchdb -name couchdb@n1couchdb.aniu.so -setcookie monster -kernel error_logger silent -sasl sasl_error_logger false -noshell -noinput -kernel inet_dist_listen_min 9100 -kernel inet_dist_listen_max 9200 -config /usr/local/couchdb/bin/../releases/2.0.0/sys.config
couchdb   3928  3901  0 21:09 ?        00:00:00 erl_child_setup 1024
couchdb   3934  3928  0 21:09 ?        00:00:00 sh -s disksup
couchdb   3936  3928  0 21:09 ?        00:00:00 /usr/local/couchdb/bin/../lib/os_mon-2.4.2/priv/bin/memsup
couchdb   3937  3928  0 21:09 ?        00:00:00 /usr/local/couchdb/bin/../lib/os_mon-2.4.2/priv/bin/cpu_sup
couchdb   3938  3928  0 21:09 ?        00:00:00 inet_gethost 4
couchdb   3939  3938  0 21:09 ?        00:00:00 inet_gethost 4
root      3961  3945  0 21:12 pts/3    00:00:00 grep couchdb
[root@n1couchdb ~]# netstat -nlpt
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address               Foreign Address             State       PID/Program name
tcp        0      0 0.0.0.0:5984                0.0.0.0:*                   LISTEN      4355/beam.smp
tcp        0      0 0.0.0.0:5986                0.0.0.0:*                   LISTEN      4355/beam.smp
tcp        0      0 0.0.0.0:4369                0.0.0.0:*                   LISTEN      3582/epmd
```

## 检查couchdb是否正常工作

```
[root@n1couchdb ~]# curl -I http://0.0.0.0:5984/_utils/index.html
HTTP/1.1 200 OK
Cache-Control: private, must-revalidate
Content-Length: 1886
Content-Security-Policy: default-src 'self'; img-src 'self' data:; font-src 'self'; script-src 'self' 'unsafe-eval'; style-src 'self' 'unsafe-inline';
Content-Type: text/html
Date: Tue, 04 Jul 2017 13:26:40 GMT
last-modified: Tue, 04 Jul 2017 12:43:17 GMT
Server: CouchDB/2.0.0 (Erlang OTP/19)
```

##  单点情况下通过浏览器访问

> http://192.168.0.154:5984/_utils/#verifyinstall，进行初始化设置,如下图：

![这里写图片描述](http://img.blog.csdn.net/20170704222457219?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 这里初始设置 username: admin password: password ,方便记忆，后面需要再改

![这里写图片描述](http://img.blog.csdn.net/20170704222620446?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

-  登录成功，配置单节点

![这里写图片描述](http://img.blog.csdn.net/20170704222710122?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)


![这里写图片描述](http://img.blog.csdn.net/20170704222727592?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

> CouchDB管理页面还有许多操作，这里就不过多演示


## 安装过程中报错修复

> ERROR: compile failed while processing /usr/local/src/apache-couchdb-2.0.0/src/couch: rebar_abort

- 解决报错：

```
cd /usr/local/src/apache-couchdb-2.0.0
egrep -r js-1.8.5 *

vim +106 src/couch/rebar.config.script

{"linux",  CouchJSPath, CouchJSSrc, [{env, [{"CFLAGS", JS_CFLAGS ++ " -DXP_UNIX -I/usr/include/js"}, {"LDFLAGS", JS_LDFLAGS ++ " -lm"}]}]},
改为：
{"linux",  CouchJSPath, CouchJSSrc, [{env, [{"CFLAGS", JS_CFLAGS ++ " -DXP_UNIX -I/usr/local/include/js"}, {"LDFLAGS", JS_LDFLAGS ++ " -lm"}]}]},
# 根本原因就是couchdb编译的时候找到默认的js

# 还有种方式就是做软链接

ln -s /usr/local/include/js /usr/include/js  # 这种方法尚未尝试，修改完成就可以继续编译啦
```
> 安装依赖缺失报错

```
[root@localhost apache-couchdb-2.0.0]# make release
Uncaught error in rebar_core: {'EXIT',
                               {undef,
                                [{crypto,start,[],[]},
                                 {rebar,run_aux,2,
                                  [{file,"src/rebar.erl"},{line,212}]},
                                 {rebar,main,1,
                                  [{file,"src/rebar.erl"},{line,58}]},
                                 {escript,run,2,
                                  [{file,"escript.erl"},{line,760}]},
                                 {escript,start,1,
                                  [{file,"escript.erl"},{line,277}]},
                                 {init,start_em,1,[]},
                                 {init,do_boot,3,[]}]}}
make: *** [couch] Error 1
```

> 次报错是编译erlang前没安装openssl-devel，安装openssl-devel重新编译erlang

- 安装完成

```
WARN:  'generate' command does not apply to directory /usr/local/src/apache-couchdb-2.0.0
... done

    You can now copy the rel/couchdb directory anywhere on your system.
    Start CouchDB with ./bin/couchdb from within that directory.
```
> 下面是程序本身BUG

```
[notice] 2017-07-04T13:18:55.255565Z couchdb@n1couchdb.aniu.so <0.328.0> -------- chttpd_auth_cache changes listener died database_does_not_exist at mem3_shards:load_shards_from_db/6(line:327) <= mem3_shards:load_shards_from_disk/1(line:315) <= mem3_shards:load_shards_from_disk/2(line:331) <= mem3_shards:for_docid/3(line:87) <= fabric_doc_open:go/3(line:38) <= chttpd_auth_cache:ensure_auth_ddoc_exists/2(line:187) <= chttpd_auth_cache:listen_for_changes/1(line:134)
[error] 2017-07-04T13:18:55.255823Z couchdb@n1couchdb.aniu.so emulator -------- Error in process <0.9372.0> on node 'couchdb@n1couchdb.aniu.so' with exit value:
{database_does_not_exist,[{mem3_shards,load_shards_from_db,"_users",[{file,"src/mem3_shards.erl"},{line,327}]},{mem3_shards,load_shards_from_disk,1,[{file,"src/mem3_shards.erl"},{line,315}]},{mem3_shards,load_shards_from_disk,2,[{file,"src/mem3_shards.erl"},{line,331}]},{mem3_shards,for_docid,3,[{file,"src/mem3_shards.erl"},{line,87}]},{fabric_doc_open,go,3,[{file,"src/fabric_doc_open.erl"},{line,38}]},{chttpd_auth_cache,ensure_auth_ddoc_exists,2,[{file,"src/chttpd_auth_cache.erl"},{line,187}]},{chttpd_auth_cache,listen_for_changes,1,[{file,"src/chttpd_auth_cache.erl"},{line,134}]}]}
```

> 作为单个节点运行2.0时，它不会在启动时创建系统数据库,必须手动执行此操作：

```
curl -X PUT http://0.0.0.0:5984/_users
curl -X PUT http://0.0.0.0:5984/_replicator
curl -X PUT http://0.0.0.0:5984/_global_changes
```

# 参考教程

- http://guide.couchdb.org/draft/security.html
- http://docs.couchdb.org/en/latest/install/setup.html
- https://medium.com/linagora-engineering/setting-up-a-couchdb-2-cluster-on-centos-7-8cbf32ae619f
- http://docs.couchdb.org/en/2.0.0/install/unix.html
- https://issues.apache.org/jira/browse/COUCHDB-2995  # 最重要报错修复
- http://docs.couchdb.org/en/2.0.0/cluster/setup.html#the-cluster-setup-wizard
