# 使用virsh管理guests

> https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Virtualization_Administration_Guide/chap-Virtualization_Administration_Guide-Managing_guests_with_virsh.html

##  virsh常用命令

- virsh help command

> 使用virsh help，根据提示查看具体命令用法，以pool为例：

```
[root@xen-2 ~]# virsh help pool
 Storage Pool (help keyword 'pool'):
    find-storage-pool-sources-as   find potential storage pool sources
    find-storage-pool-sources      discover potential storage pool sources
    pool-autostart                 autostart a pool
    pool-build                     build a pool
    pool-create-as                 create a pool from a set of args
    pool-create                    create a pool from an XML file
    pool-define-as                 define a pool from a set of args
    pool-define                    define an inactive persistent storage pool or modify an existing persistent one from an XML file
    pool-delete                    delete a pool
    pool-destroy                   destroy (stop) a pool
    pool-dumpxml                   pool information in XML
    pool-edit                      edit XML configuration for a storage pool
    pool-info                      storage pool information
    pool-list                      list pools
    pool-name                      convert a pool UUID to pool name
    pool-refresh                   refresh a pool
    pool-start                     start a (previously defined) inactive pool
    pool-undefine                  undefine an inactive pool
    pool-uuid                      convert a pool name to pool UUID
    pool-event                     Storage Pool Events
```

> 使用virsh help + 单个命令 查看具体命令用法

```
[root@xen-2 ~]# virsh help pool-autostart
  NAME
    pool-autostart - autostart a pool

  SYNOPSIS
    pool-autostart <pool> [--disable]

  DESCRIPTION
    Configure a pool to be automatically started at boot.

  OPTIONS
    [--pool] <string>  pool name or uuid
    --disable        disable autostarting
```

> 使用quit，exit退出virsh交互命令行， vrish version 查看版本

- 显示基本信息

```
# 显示管理程序的系统信息
virsh sysinfo
```

## 使用virsh附加和更新设备

> 热插拔USB设备供guest虚拟机使用

```
# 安装lsusb
yum install usbutils -y
# 使用以下命令找到要附加的USB设备
# lsusb -v
idVendor           0x17ef Lenovo
idProduct          0x480f Integrated Webcam [R5U877]
```

> 创建一个XML文件并给它一个逻辑名称（例如usb_device.xml）。确保您复制供应商和产品ID，与您的搜索中显示的完全相同。

```
# cat usb_device.xml
<hostdev mode='subsystem' type='usb' managed='yes'>
     <source>
       <vendor id='0x17ef'/>
       <product id='0x480f'/>
     </source>
   </hostdev>
```
> 使用以下命令添加设备

```
virsh attach-device rhel6 --file usb_device.xml> --config
# rhel6 是guest name
```

> 移除usb设备

```
virsh detach-device rhel6 --file usb_device.xml>
```

- 配置虚拟机在启动时自动启动

```
virsh autostart rhel6  # 自启
virsh autostart rhel6 --disable #禁止自启
```

- 连接虚拟机

```
virsh console virtual_machine --safe
```
