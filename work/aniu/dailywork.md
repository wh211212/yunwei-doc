# 运维工作每天记录

- 2018-06-11：

```
1、每天web更新（平均20次，每次一分钟左右），接口部署（平均6次，平均6分钟），sql处理（平均6次，平均3分钟）
2、配合开发接口报错故障排查，（平均3次，平均时长15分钟）
3、监控系统告警处理优化（平均三次，平均10分钟）
4、keepass每天更新（十分钟），新增虚拟机环境初始化（平均30分钟）
5、巡检服务器状态及处理突发性事故（时间平均30分钟到1个小时）
```


- 2018-06-12：

```
1、迁移crmadmin，新增两台虚拟机，配置crmadmin运行环境，迁移完成后测试运行状态(两个小时)，迁移过程出现出现的问题：jdk8启动crmadmin导致合同发送不了，改回oracle jdk7,crmadmin项目对jdk版本有要求
2、新增的两台虚拟机添加监控，时间同步及crmadmin状态检测（30分钟）
3、新增虚拟机同步到jumpserver，给辰鸣创建查看日志权限，添加实时日志输出到logio.aniu.so（50分钟）
3、接口部署（zjtapi三次）（15分钟），（productapi一次）（5分钟）
4、帮助钟总安装vpn，十分钟
5、jumpserver上同步Redis集群资产信息（20分钟）
6、jumpserver上资产管理同步，更新虚拟机状态，新增添加，废弃删除（30分钟）


7、新增crmadmin下午运行出现内存溢出故障，优化tomcat启动jvm参数，从运维层面暂时解决问题
8、迁移0.8上服务，预计50分钟，迁移mmsadmin,nkmadmin.aniuadmin
9、处理sql（一次）
10、测试环境安装jenkins，配置打包环境
11、nkmapi更新上线（10分钟），提供nkm测试环境（进行中）

```

- 2018-06-13：

```
1、机房迁移业务并重装三台服务器，然后加入到ovirt私有云平台进行管理
2、迁移个别节点上负载高的业务
3、中午接口上线，aniuapi/zjtapi/wxapi/userapi
4、帮助伍敏查找日志
5、合并23次merge请求
6、worldcup域名配置，php、wx环境安装pdo
```

- 2018-06-14：

```
1、昨天新装服务器添加监控agent
2、添加服务器到jumpserver进行资产管理，梳理资产，删除停用虚拟机资产信息
3、迁移njdxapi1从ovirt1到ovirt5,减少ovirt1节点的负载及内存占用
4、牛客觅测试环境redis集群以及tomcat环境准备
5、合并merge请求43次
```

- 2018-06-15：

```
1、帮助同事重装系统
2、新增一台虚拟机安装redis集群，提供给清算项目使用
3、redis单实例数据迁移到redis集群测试
4、productadmin添加监控agent，并解决目录占满问题
5、排查解决crmadmin项目连接productapi接口故障
6、aniuapi接口更新
7、合并发布请求3次
```


- 2018-06-19

```
1、监控系统告警处理
2、利用新增ovirt5节点和ovirt4的ssd硬盘，创建一个新的glusterfs服务，添加到ovirt作为存储域，给redis集群使用，提高IO，现redis集群的数据盘为机械硬盘
3、查看nkmapi报错日志，及查看messageapi运行状态
4、gitlab添加mfeng@aniu.tv权限，能够开发dzcj-ott
5、解决专家团接口由于数据库字段长度问题异常报错，增加aniu_msg_channel_req表mediaId长度为100

```

- 2018-06-20

```
1、机房ovirt节点启用em2网卡
2、ovirt平台迁移多个虚拟机的网卡走新增的vmnet，即em2
3、接口部署，jira任务处理，web更新
4、机房ovirt1重启导致卡死修复，方案;断电10分钟左右，拔插内存重启，然后其自动加到ovirt平台
```

- 2018-06-22

```
1、行情接口故障排查
2、替换dzcj.apk
3、行情接口慢排查
4、aniuadmin故障排查
5、crmadmin上线
6、帮杨风仙重置vpn密码
7、修文sql处理
8、配合查看njdxapi鉴权问题
```

