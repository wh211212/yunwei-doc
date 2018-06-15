# 日常工作问题总结

- 1、牛客觅接口使用redis集群timeout问题？

```
排查发现由于redis集群中的redis实例进行AOF持久化过长，导致redis这个时间段不提供服务

报错：30351:S 15 Jun 18:28:22.079 * Asynchronous AOF fsync is taking too long (disk is busy?). Writing the AOF buffer without waiting for fsync to complete, this may slow down Redis.

临时解决：关闭redis集群中三个master节点的AOF持久化，降低redis实例所在服务器的IO，以便加快AOF持久化


解决方案：redis集群全部采用物理机，硬盘使用固态硬盘 （现在没有资源，需申请）

现在redis集群方案： 三台虚拟机：

16G 内存， 2个CPU，30G硬盘系统盘，20G磁盘数据盘

磁盘从 存储域划来。存储域本身是通过两个相同大小的机械硬盘，安装特定存储服务而来的。 本身不提供高IO操作的业务

```
