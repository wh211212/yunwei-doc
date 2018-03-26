# CentOS7 安装openstack quees版本

## Openstack服务

### （1）OpenStack的主要组件

- 服务	代码名称	描述
- 身份服务	Keystone	用户管理
- 计算服务	Nova	虚拟机管理
- 图像服务	Glance	管理像内核映像或磁盘映像这样的虚拟映像
- 仪表板	Horizon		通过Web浏览器提供GUI控制台
- 对象存储	Swift	提供云端存储
- 块存储	Cinder	虚拟机的存储管理
- 网络服务	Neutron	虚拟网络管理
- 编排服务	Heat	为虚拟机提供编排功能
- 计量服务	Ceilometer	提供会计用法测量功能
- 数据库服务	Trove	数据库资源管理
- 数据处理服务	Sahara	提供数据处理功能
- 裸金属供应	Ironic	提供裸机供应功能
- 消息服务	Zaqar	提供消息传递服务功能
- 共享文件系统	Manila	提供文件共享服务
- DNS服务 Designate	提供DNS服务器服务
- 密钥管理器服务 Barbican	提供密钥管理服务

### 逻辑体系结构

OpenStack是有几个独立的部分组成，OpenStack服务都通过普通身份服务进行身份认证，各个服务通过公共API相互交互，除非使用特权管理员命令。

在内部，OpenStack服务由多个进程组成，所有服务都至少有一个API进程，它监听API请求，预处理它们并将它们传递给服务的其他部分。除身份服务外，实际工作有不同的流程完成。

对于一个服务的进程之间的通信，使用AMQP消息代理，该服务的状态存储在数据库中，部署和配置OpenStack时，可以选择多种消息代理和数据库解决方案，例如：rabbitmq、MySQL，mariadb和SQLite。

用户通过Horizon Dashboard实现的基于Web的用户操作界面，可以通过命令行客户端、curl等工具发布API请求来访问OpenStack。所有访问请求都会对OpenStack服务发出RESTAPI调用。

- OpenStack 通过各种补充服务提供基础架构即服务（IaaS）解决方案,每项服务都提供了一个 应用程序编程接口（API），以促进这种集成。

### Keystone