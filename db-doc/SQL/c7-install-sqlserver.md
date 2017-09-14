# CentOS7 安装并使用SQL Server

## Linux 上的 SQL Server 安装指南

- 参考：https://docs.microsoft.com/zh-cn/sql/linux/sql-server-linux-setup

### 笔者基于CentOS7进行安装操作

- 下载 Microsoft SQL Server Red Hat 存储库配置文件

```
   sudo curl -o /etc/yum.repos.d/mssql-server.repo https://packages.microsoft.com/config/rhel/7/mssql-server.repo
```
- 运行以下命令，安装 SQL Server

```
sudo yum update -y
sudo yum install -y mssql-server
```
- 安装完成之后，执行下面命令，根据提示设置SA密码，并选择相应的版本

```
sudo /opt/mssql/bin/mssql-conf setup
```
![图片描述][1]
  
> 确保SA账户密码轻度满足默认要求（最少 8 个字符，包括大写和小写字母、十进制数字和/或非字母数字符号）

- 配置完成后，请验证服务是否正在运行

```
systemctl status mssql-server
```
![图片描述][2]

- 开启防火墙上的 SQL Server 端口，默认为TCP 1433

```
sudo firewall-cmd --zone=public --add-port=1433/tcp --permanent
sudo firewall-cmd --reload
# firewall-cmd未启用不需要做此设置
```
> 到此，SQL Server已在CentOS7上正常运行

### 安装 SQL Server 命令行工具

> 要创建数据库，需要使用一种工具，可以在 SQL Server 上运行 TRANSACT-SQL 语句进行连接。 以下步骤安装 SQL Server 命令行工具：sqlcmd和bcp

- 下载 Microsoft Red Hat 存储库配置文件

```
sudo curl -o /etc/yum.repos.d/msprod.repo https://packages.microsoft.com/config/rhel/7/prod.repo
```
- 如果服务器以前安装过mssql，需要删除任何较旧的 unixODBC 程序包

```
sudo yum update
sudo yum remove unixODBC-utf16 unixODBC-utf16-devel
```
- 运行以下命令以安装mssql 工具与 unixODBC 开发人员包

```
sudo yum update
sudo yum install -y mssql-tools unixODBC-devel
```
- 添加/opt/mssql-tools/bin/路径到环境变量

```
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc
```
### 本地连接配置

> 以下步骤使用 sqlcmd 本地连接到新的 SQL Server 实例

- 使用 SQL Server 名称 (-S)，用户名 (-U) 和密码 (-P) 的参数运行 sqlcmd。 在本教程中，用户进行本地连接，因此服务器名称为 localhost。 用户名为 SA，密码是在安装过程中为 SA 帐户提供的密码。

```
sqlcmd -S localhost -U SA -P '<YourPassword>'
```
> 密码输入可以采用交互的方式

- 如果连接成功显示如下图：应会显示 sqlcmd 命令提示符：1>


![图片描述][3]

### 使用SQL Server创建和查询数据

> 新建数据库，创建一个名为`AniuDB`的数据库

- 在 sqlcmd 命令提示符中，粘贴以下 Transact-SQL 命令以创建测试数据库：

```
CREATE DATABASE AniuDB
```
- 在下一行中，编写一个查询以返回服务器上所有数据库的名称

```
SELECT Name from sys.Databases
```
- 前两个命令没有立即执行。 必须在新行中键入 `GO` 才能执行以前的命令：

```
GO
```






- 安装 SQL Server 和 CentOS7 上创建数据库

> 本文适用于：


  [1]: /img/bVUYnM
  [2]: /img/bVUYoj
  [3]: /img/bVUYq5