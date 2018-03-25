# 
Dell服务器常用管理命令总结
准备新版本的 MegaCli-8.07.14-1.noarch.rpm 会把程序安装在/opt下，可以自定义安装目录，例如：
rpm --relocate /opt/=/usr/sbin/ -i MegaCli-8.07.14-1.noarch.rpm
即把安装目录 /opt 替换成 /usr/sbin。

下载地址：http://www.lsi.com/downloads/Public/MegaRAID%20Common%20Files/8.07.14_MegaCLI.zip ;
(linux文件夹下有个MegaCli文件里面有I386 RPM）
    查看机器型号    # dmidecode | grep "Product"
    查看厂商    # dmidecode| grep  "Manufacturer"
    查看序列号    # dmidecode | grep  "Serial Number"
    查看CPU信息    # dmidecode | grep  "CPU"
    查看CPU个数    # dmidecode | grep  "Socket Designation: CPU" |wc –l
    查看出厂日期    # dmidecode | grep "Date"
    查看充电状态    # MegaCli -AdpBbuCmd -GetBbuStatus -aALL |grep "Charger Status"
    显示BBU状态信息    # MegaCli -AdpBbuCmd -GetBbuStatus –aALL
    显示BBU容量信息    # MegaCli -AdpBbuCmd -GetBbuCapacityInfo –aALL
    显示BBU设计参数    # MegaCli -AdpBbuCmd -GetBbuDesignInfo –aALL
    显示当前BBU属性    # MegaCli -AdpBbuCmd -GetBbuProperties –aALL
    查看充电进度百分比    # MegaCli -AdpBbuCmd -GetBbuStatus -aALL |grep "Relative State of Charge"
    查询Raid阵列数    # MegaCli -cfgdsply -aALL |grep "Number of DISK GROUPS:"
    显示Raid卡型号，Raid设置，Disk相关信息      # MegaCli -cfgdsply –aALL
    显示所有物理信息    # MegaCli -PDList -aALL
    显示所有逻辑磁盘组信息    # MegaCli -LDInfo -LALL –aAll
    查看物理磁盘重建进度(重要)    # MegaCli -PDRbld -ShowProg -PhysDrv [1:5] -a0
    查看适配器个数    #MegaCli –adpCount
    查看适配器时间    #MegaCli -AdpGetTime –aALL
    显示所有适配器信息    #MegaCli -AdpAllInfo –aAll
    查看Cache 策略设置    # MegaCli -cfgdsply -aALL |grep Polic
    
1、查看所有物理磁盘信息
MegaCli -PDList -aALL

Adapter #0

Enclosure Number: 1
Slot Number: 5
Device Id: 5
Sequence Number: 2
Media Error Count: 0
Other Error Count: 0
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
Raw Size: 140014MB [0x11177328 Sectors]
Non Coerced Size: 139502MB [0x11077328 Sectors]
Coerced Size: 139392MB [0x11040000 Sectors]
Firmware state: Hotspare
SAS Address(0): 0x5000c50008e5cca9
SAS Address(1): 0x0
Inquiry Data: SEAGATE ST3146855SS     S5273LN4Y1X0
.....
 
2、查看磁盘缓存策略
MegaCli -LDGetProp -Cache -L0 -a0

Adapter 0-VD 0: Cache Policy:WriteBack, ReadAheadNone, Direct
 
or
MegaCli -LDGetProp -Cache -L1 -a0

Adapter 0-VD 1: Cache Policy:WriteBack, ReadAheadNone, Direct
 
or
MegaCli -LDGetProp -Cache -LALL -a0

Adapter 0-VD 0: Cache Policy:WriteBack, ReadAheadNone, Direct
Adapter 0-VD 1: Cache Policy:WriteBack, ReadAheadNone, Direct
 
or
MegaCli -LDGetProp -Cache -LALL -aALL

Adapter 0-VD 0: Cache Policy:WriteBack, ReadAheadNone, Direct
Adapter 0-VD 1: Cache Policy:WriteBack, ReadAheadNone, Direct
 
or
MegaCli -LDGetProp -DskCache -LALL -aALL

Adapter 0-VD 0: Disk Write Cache : Disk's Default
Adapter 0-VD 1: Disk Write Cache : Disk's Default
 
3、设置磁盘缓存策略
缓存策略解释：
WT    (Write through
WB    (Write back)
NORA  (No read ahead)
RA    (Read ahead)
ADRA  (Adaptive read ahead)
Cached
Direct
 
例子：
MegaCli -LDSetProp WT|WB|NORA|RA|ADRA -L0 -a0
 
or
MegaCli -LDSetProp -Cached|-Direct -L0 -a0
 
or
enable / disable disk cache
MegaCli -LDSetProp -EnDskCache|-DisDskCache -L0 -a0
 
4、创建/删除 阵列
4.1 创建一个 raid5 阵列，由物理盘 2,3,4 构成，该阵列的热备盘是物理盘 5
MegaCli -CfgLdAdd -r5 [1:2,1:3,1:4] WB Direct -Hsp[1:5] -a0
 
4.2 创建阵列，不指定热备
MegaCli -CfgLdAdd -r5 [1:2,1:3,1:4] WB Direct -a0
 
4.3 删除阵列
MegaCli -CfgLdDel -L1 -a0
 
4.4 在线添加磁盘
MegaCli -LDRecon -Start -r5 -Add -PhysDrv[1:4] -L1 -a0
意思是，重建逻辑磁盘组1，raid级别是5，添加物理磁盘号：1:4。重建完后，新添加的物理磁盘会自动处于重建(同步)状态，这个 时候 fdisk -l是看不到阵列的空间变大的，只有在系统重启后才能看见。   
5、查看阵列初始化信息
5.1 阵列创建完后，会有一个初始化同步块的过程，可以看看其进度。
MegaCli -LDInit -ShowProg -LALL -aALL
 
或者以动态可视化文字界面显示
MegaCli -LDInit -ProgDsply -LALL -aALL
 
5.2 查看阵列后台初始化进度
MegaCli -LDBI -ShowProg -LALL -aALL
 
或者以动态可视化文字界面显示
MegaCli -LDBI -ProgDsply -LALL -aALL
 
6、创建全局热备
指定第 5 块盘作为全局热备
MegaCli -PDHSP -Set [-EnclAffinity] [-nonRevertible] -PhysDrv[1:5] -a0
 
也可以指定为某个阵列的专用热备
MegaCli -PDHSP -Set [-Dedicated [-Array1]] [-EnclAffinity] [-nonRevertible] -PhysDrv[1:5] -a0
 
7、删除全局热备
MegaCli -PDHSP -Rmv -PhysDrv[1:5] -a0
 
8、将某块物理盘下线/上线
MegaCli -PDOffline -PhysDrv [1:4] -a0
 
MegaCli -PDOnline -PhysDrv [1:4] -a0
 
9、查看物理磁盘重建进度
MegaCli -PDRbld -ShowProg -PhysDrv [1:5] -a0