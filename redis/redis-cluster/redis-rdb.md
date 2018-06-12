# Redis持久化

- RDB持久性以指定的间隔执行数据集的时间点快照。
- AOF持久性记录服务器接收到的每一个写操作，在服务器启动时将再次播放，重新构造原始数据集。命令使用与Redis协议本身相同的格式进行日志记录，这是一种附加的方式。Redis能够在它变得太大的时候重写日志。
- 可以在同一个实例中组合AOF和RDB。请注意，在这种情况下，当Redis重新启动时，AOF文件将被用于重建原始数据集，因为它保证是最完整的。

## RDB 优点

- RDB是一个非常紧凑的单文件点实时表示您的Redis数据。RDB文件非常适合备份。例如，您可能希望在最新的24小时内每小时存档您的RDB文件，并在30天内每天保存一个RDB快照。这允许您在灾难发生时轻松地恢复不同版本的数据集。
- RDB非常适合灾难恢复，可以将单个紧凑文件传输到远程数据中心
- 与AOF相比，RDB允许使用大数据集更快地重新启动。

## RDB 缺点

- RDB经常需要使用子进程来持久化磁盘。如果数据集很大，那么Fork()可能会耗费大量时间，如果数据集非常大，而CPU性能不太好，那么可能导致Redis停止为客户机提供一些毫秒甚至一秒的服务。AOF还需要fork()，但您可以调整您想要重写日志的频率，而不需要权衡持久性

## AOF 优点

- 使用Redis更耐用:您可以有不同的fsync策略:不需要fsync，每秒钟都要同步，在每个查询中都是fsync。在fsync的默认策略下，每一秒都写得很好(fsync是使用后台线程执行的，主线程在没有fsync的情况下会尝试执行写入操作)，但只能丢失一秒的写值。

- AOF包含了一个接一个的日志，一个接一个的操作很容易理解和解析格式。您甚至可以轻松导出AOF文件。例如，即使您使用FLUSHALL命令对所有的错误进行了刷新，如果在此期间不重写日志，您仍然可以保存您的数据集，以停止服务器，删除最新的命令，重新启动Redis。

## AOF 缺点

- 对于同一数据集，AOF文件通常比相同的RDB文件大。
- 根据正确的fsync策略，AOF可以比RDB慢。一般来说，fsync设置的每一秒的性能都非常高，而对于fsync的残障，它应该和RDB一样快，即使在高负载下也是如此。即使在巨大的写入负载情况下，RDB仍然能够提供更多的最大延迟保证。



