# 基于浏览器交互式学习Docker和容器

- 参考：https://www.katacoda.com/courses/docker

## 部署第一个Docker容器

> Docker是什么？

- Docker将自己描述为“开发者和系统管理员构建，发布和运行分布式应用程序的开放平台”。
- Docker允许你运行容器。容器是运行应用程序及其对主机操作系统的依赖性的沙盒进程。容器内的应用程序认为自己是机器上运行的唯一进程，而机器可以独立运行多个容器。

- Docker环境

```
[root@aniu-k8s ~]# docker -v
Docker version 1.12.6, build 85d7426/1.12.6
```

### 运行容器

> 第一个任务是确定配置为运行Redis的Docker Image的名称。使用Docker，所有容器都是基于Docker镜像启动的。这些镜像包含启动过程所需的一切;主机不需要任何配置或依赖关系

- 可以通过 registry.hub.docker.com 搜索到已经存在的镜像，使用 **docker search `name`** 

```bash
# 搜索redis镜像
docker search redis
```
![这里写图片描述](http://img.blog.csdn.net/20171122103614744?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 通过搜索我们已经看到Redis Docker 镜像名称也叫redis，同时我们想后台运行redis镜像，使用-d参数，如下：

```
docker run -d redis
```
> 默认情况下，Docker将运行可用的最新版本。如果需要特定版本，则可以将其指定为标记，例如，版本3.2将是docker run -d redis：3.2

### 查看运行的容器

- 运行在后台的容器，可以通过docker ps查看

```
docker ps
```
> 通过docker ps 我们可以看到相关容器的名称和ID，可以通过下面的命令查看容器的详细信息

```
# 查看容器详细信息
docker inspect <friendly-name|container-id>
# 查看容器日志输出
docker logs <friendly-name|container-id>
```
- 查看容器详细信息

```
[root@aniu-k8s ~]# docker inspect 79cb270bb2c7
[
    {
        "Id": "79cb270bb2c7a979f194b9cb8e54713329d7cdd2e19ee74d9188424d5560c748",
        "Created": "2017-11-22T02:52:53.116046248Z",
        "Path": "docker-entrypoint.sh",
        "Args": [
            "redis-server"
        ],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 26811,
            "ExitCode": 0,
            "Error": "",
            "StartedAt": "2017-11-22T02:52:53.764478447Z",
            "FinishedAt": "0001-01-01T00:00:00Z"
        },
        "Image": "sha256:8f2e175b3bd129fd9416df32a0e51f36632e3ab82c5608b4030590ad79f0be12",
        "ResolvConfPath": "/var/lib/docker/containers/79cb270bb2c7a979f194b9cb8e54713329d7cdd2e19ee74d9188424d5560c748/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/79cb270bb2c7a979f194b9cb8e54713329d7cdd2e19ee74d9188424d5560c748/hostname",
        "HostsPath": "/var/lib/docker/containers/79cb270bb2c7a979f194b9cb8e54713329d7cdd2e19ee74d9188424d5560c748/hosts",
        "LogPath": "",
        "Name": "/amazing_kirch",
        "RestartCount": 0,
        "Driver": "devicemapper",
        "MountLabel": "",
        "ProcessLabel": "",
        "AppArmorProfile": "",
        "ExecIDs": null,
        "HostConfig": {
            "Binds": null,
            "ContainerIDFile": "",
            "LogConfig": {
                "Type": "journald",
                "Config": {}
            },
            "NetworkMode": "default",
            "PortBindings": {},
            "RestartPolicy": {
                "Name": "no",
                "MaximumRetryCount": 0
            },
            "AutoRemove": false,
            "VolumeDriver": "",
            "VolumesFrom": null,
            "CapAdd": null,
            "CapDrop": null,
            "Dns": [],
            "DnsOptions": [],
            "DnsSearch": [],
            "ExtraHosts": null,
            "GroupAdd": null,
            "IpcMode": "",
            "Cgroup": "",
            "Links": null,
            "OomScoreAdj": 0,
            "PidMode": "",
            "Privileged": false,
            "PublishAllPorts": false,
            "ReadonlyRootfs": false,
            "SecurityOpt": null,
            "UTSMode": "",
            "UsernsMode": "",
            "ShmSize": 67108864,
            "Runtime": "docker-runc",
            "ConsoleSize": [
                0,
                0
            ],
            "Isolation": "",
            "CpuShares": 0,
            "Memory": 0,
            "CgroupParent": "",
            "BlkioWeight": 0,
            "BlkioWeightDevice": null,
            "BlkioDeviceReadBps": null,
            "BlkioDeviceWriteBps": null,
            "BlkioDeviceReadIOps": null,
            "BlkioDeviceWriteIOps": null,
            "CpuPeriod": 0,
            "CpuQuota": 0,
            "CpusetCpus": "",
            "CpusetMems": "",
            "Devices": [],
            "DiskQuota": 0,
            "KernelMemory": 0,
            "MemoryReservation": 0,
            "MemorySwap": 0,
            "MemorySwappiness": -1,
            "OomKillDisable": false,
            "PidsLimit": 0,
            "Ulimits": null,
            "CpuCount": 0,
            "CpuPercent": 0,
            "IOMaximumIOps": 0,
            "IOMaximumBandwidth": 0
        },
        "GraphDriver": {
            "Name": "devicemapper",
            "Data": {
                "DeviceId": "9",
                "DeviceName": "docker-253:0-100737404-4b0140c6e10674c4a85def2225daf00cfc25dadf2b3123c4403acc3a3f82f2b6",
                "DeviceSize": "10737418240"
            }
        },
        "Mounts": [
            {
                "Name": "3be1234313d2565859457c0cf94a482dc7c97fb3bf6d29667238d98f38bae95e",
                "Source": "/var/lib/docker/volumes/3be1234313d2565859457c0cf94a482dc7c97fb3bf6d29667238d98f38bae95e/_data",
                "Destination": "/data",
                "Driver": "local",
                "Mode": "",
                "RW": true,
                "Propagation": ""
            }
        ],
        "Config": {
            "Hostname": "79cb270bb2c7",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": false,
            "AttachStderr": false,
            "ExposedPorts": {
                "6379/tcp": {}
            },
            "Tty": false,
            "OpenStdin": false,
            "StdinOnce": false,
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "GOSU_VERSION=1.10",
                "REDIS_VERSION=4.0.2", # redis版本，当前最新
                "REDIS_DOWNLOAD_URL=http://download.redis.io/releases/redis-4.0.2.tar.gz",
                "REDIS_DOWNLOAD_SHA=b1a0915dbc91b979d06df1977fe594c3fa9b189f1f3d38743a2948c9f7634813"
            ],
            "Cmd": [
                "redis-server"
            ],
            "Image": "redis",
            "Volumes": {
                "/data": {}
            },
            "WorkingDir": "/data", # 容器内定义的redis数据存储目录，后面会用到
            "Entrypoint": [
                "docker-entrypoint.sh"
            ],
            "OnBuild": null,
            "Labels": {}
        },
        "NetworkSettings": {
            "Bridge": "",
            "SandboxID": "e918f1364391a1c363b9e6326063edf22f4c70b0e34b78cdc324aa33694994f7",
            "HairpinMode": false,
            "LinkLocalIPv6Address": "",
            "LinkLocalIPv6PrefixLen": 0,
            "Ports": {
                "6379/tcp": null
            },
            "SandboxKey": "/var/run/docker/netns/e918f1364391",
            "SecondaryIPAddresses": null,
            "SecondaryIPv6Addresses": null,
            "EndpointID": "5dc4c696ce52cb4e8a2efa89db2ea474f51401428b24119a3123858315c6941b",
            "Gateway": "172.17.0.1",
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "IPAddress": "172.17.0.2",
            "IPPrefixLen": 16,
            "IPv6Gateway": "",
            "MacAddress": "02:42:ac:11:00:02",
            "Networks": {
                "bridge": {
                    "IPAMConfig": null,
                    "Links": null,
                    "Aliases": null,
                    "NetworkID": "06b25246573a6add4f7a4a57a235aa21b749572dde479ed13e7d5fe8ed873119",
                    "EndpointID": "5dc4c696ce52cb4e8a2efa89db2ea474f51401428b24119a3123858315c6941b",
                    "Gateway": "172.17.0.1",
                    "IPAddress": "172.17.0.2",
                    "IPPrefixLen": 16,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
                    "MacAddress": "02:42:ac:11:00:02"
                }
            }
        }
    }
]
```

-  查看容器日志输出

```
docker logs <friendly-name|container-id>
```
![这里写图片描述](http://img.blog.csdn.net/20171122112559969?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)


### 访问redis

> 访问容器中运行的redis，需要进行端口转换，参考Docker官方文档：

```
# 强制删除我们上面启动的容器
docker rm 79cb270bb2c7 -f

# 从新启动redis容器，并指定被访问的端口
docker run -d -h redisHostPort -p 6379:6379 redis:latest

> [root@aniu-k8s ~]# docker run -d -h redisHostPort -p 6379:6379 redis:latest
0f216b7c4089cb036b9da379fb3ab420474080b98e09c741849d400f4e6c9d78
/usr/bin/docker-current: Error response from daemon: driver failed programming external connectivity on endpoint adoring_poincare (d3bdf0067c7f1bd476f0ab4c4e3cbd0023b56535cc483b1dca8475fae6289bca): Error starting userland proxy: listen tcp 0.0.0.0:6379: bind: address already in use.
# 执行报错由于我本机启动了redis实例，更改暴露的端口，重新测试

docker run -d -h redisHostPort -p 6380:6379 redis:latest
```

> 默认情况下，主机上的端口映射为0.0.0.0，即全部为IP地址。您可以在定义端口映射时指定特定的IP地址，例如-p 127.0.0.1:6379:6379

- 有时候会忘记暴露的端口是多少，可以通过下面命令查看：

```
docker port 2e44fa9309ff
[root@aniu-k8s ~]# docker port 2e44fa9309ff
6379/tcp -> 0.0.0.0:6380
# 可以看出暴露的端口也是6380，
```

### 容器数据持久化

> 当我们删除并重新创建一个容器时，存储的数据会一直被删除，我们需要在重新创建容器时保留并重用数据。可以通过对容器绑定目录（卷组），使用-v <host-dir>:<container-dir>选项来完成,当挂载一个目录时，主机上该目录中存在的文件可以被容器访问，任何写入容器内目录的数据都将被存储在主机对应的目录上，这样我们升级或者更改容器的时候可以防止数据丢失问题。

- 通过Docker Hub文档，看出redis镜像的日志和数据默认目录是/data,需要把redis数据和日志存储到本机的/opt/docker/data/redis.

```
docker run -d -name redisMapped -v /opt/docker/data/redis:/data redis
# 笔者使用的Docker版本，不支持-name参数

[root@aniu-k8s ~]# docker run -d -h redisMapped -p 6380:6379 -v /opt/docker/data/redis:/data redis:latest
56d8437879cf9f53c4a5a0b16f00a7637f1222291fea8f2127369b400ee05823

# 通过docker logs 56d8437879cf 查看启动redis时的报错，然后更改重启，完成之后，在客户端对容器中的redis进行操作，查看数据及日志的存储情况
[root@aniu-fz-1 ~]# redis-cli -h 192.168.10.10 -p 6380 # 客户端操作，笔者的docker环境ip为192.168.10.10
192.168.10.10:6380> set key value
OK
# 在运行容器的主机上查看redis持久化文件
[root@aniu-k8s redis]# pwd
/opt/docker/data/redis  # 我们启动容器时挂载的目录被自动创建，并且目录下面已经有了redis持久化的rdb文件
[root@aniu-k8s redis]# ll
total 4
-rw-r--r-- 1 systemd-bus-proxy input 175 Nov 22 11:42 dump.rdb
```

### 前台运行容器

> 前面我们通过-d是容器在前台运行，没有指定这个，容器将在前台运行，如果我们想与容器交互（例如，访问一个bash shell）

- 例如：

```
docker run centos ps # 启动一个centos容器，并执行ps查看容器内运行的进程

docker run -it centos bash # 允许我们访问容器内的 bash shell
```
