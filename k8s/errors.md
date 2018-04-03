# 记录kubernetes安装使用过程中遇到的错误



## kubelet init 初始化报错

[root@aniu-k8s ~]# kubelet init 
I0127 20:47:36.613913   19123 feature_gate.go:220] feature gates: &{{} map[]}
I0127 20:47:36.614057   19123 controller.go:114] kubelet config controller: starting controller
I0127 20:47:36.614077   19123 controller.go:118] kubelet config controller: validating combination of defaults and flags
W0127 20:47:36.620249   19123 cni.go:171] Unable to update cni config: No networks found in /etc/cni/net.d
I0127 20:47:36.625030   19123 server.go:182] Version: v1.9.2
I0127 20:47:36.625100   19123 feature_gate.go:220] feature gates: &{{} map[]}
I0127 20:47:36.625267   19123 plugins.go:101] No cloud provider specified.
W0127 20:47:36.625340   19123 server.go:328] standalone mode, no API client
W0127 20:47:36.685180   19123 server.go:236] No api server defined - no events will be sent to API server.
I0127 20:47:36.685234   19123 server.go:428] --cgroups-per-qos enabled, but --cgroup-root was not specified.  defaulting to /
I0127 20:47:36.685677   19123 container_manager_linux.go:242] container manager verified user specified cgroup-root exists: /
I0127 20:47:36.685739   19123 container_manager_linux.go:247] Creating Container Manager object based on Node Config: {RuntimeCgroupsName: SystemCgroupsName: KubeletCgroupsName: ContainerRuntime:docker CgroupsPerQOS:true CgroupRoot:/ CgroupDriver:cgroupfs KubeletRootDir:/var/lib/kubelet ProtectKernelDefaults:false NodeAllocatableConfig:{KubeReservedCgroupName: SystemReservedCgroupName: EnforceNodeAllocatable:map[pods:{}] KubeReserved:map[] SystemReserved:map[] HardEvictionThresholds:[{Signal:memory.available Operator:LessThan Value:{Quantity:100Mi Percentage:0} GracePeriod:0s MinReclaim:<nil>} {Signal:nodefs.available Operator:LessThan Value:{Quantity:<nil> Percentage:0.1} GracePeriod:0s MinReclaim:<nil>} {Signal:nodefs.inodesFree Operator:LessThan Value:{Quantity:<nil> Percentage:0.05} GracePeriod:0s MinReclaim:<nil>} {Signal:imagefs.available Operator:LessThan Value:{Quantity:<nil> Percentage:0.15} GracePeriod:0s MinReclaim:<nil>}]} ExperimentalQOSReserved:map[] ExperimentalCPUManagerPolicy:none ExperimentalCPUManagerReconcilePeriod:10s}
I0127 20:47:36.686046   19123 container_manager_linux.go:266] Creating device plugin manager: false
W0127 20:47:36.689640   19123 kubelet_network.go:139] Hairpin mode set to "promiscuous-bridge" but kubenet is not enabled, falling back to "hairpin-veth"
I0127 20:47:36.689730   19123 kubelet.go:571] Hairpin mode set to "hairpin-veth"
I0127 20:47:36.691668   19123 client.go:80] Connecting to docker on unix:///var/run/docker.sock
I0127 20:47:36.691713   19123 client.go:109] Start docker client with request timeout=2m0s
W0127 20:47:36.693469   19123 cni.go:171] Unable to update cni config: No networks found in /etc/cni/net.d
I0127 20:47:36.698482   19123 docker_service.go:232] Docker cri networking managed by kubernetes.io/no-op
I0127 20:47:36.718852   19123 docker_service.go:237] Docker Info: &{ID:43TY:M7EN:64T4:TA5D:4J6W:3LU7:CXYG:B3P2:DAER:CX5O:SZLR:UYUY Containers:8 ContainersRunning:0 ContainersPaused:0 ContainersStopped:8 Images:4 Driver:devicemapper DriverStatus:[[Pool Name docker-253:0-100737404-pool] [Pool Blocksize 65.54 kB] [Base Device Size 10.74 GB] [Backing Filesystem xfs] [Data file /dev/loop0] [Metadata file /dev/loop1] [Data Space Used 1.295 GB] [Data Space Total 107.4 GB] [Data Space Available 101.3 GB] [Metadata Space Used 3.121 MB] [Metadata Space Total 2.147 GB] [Metadata Space Available 2.144 GB] [Thin Pool Minimum Free Space 10.74 GB] [Udev Sync Supported true] [Deferred Removal Enabled false] [Deferred Deletion Enabled false] [Deferred Deleted Device Count 0] [Data loop file /var/lib/docker/devicemapper/devicemapper/data] [Metadata loop file /var/lib/docker/devicemapper/devicemapper/metadata] [Library Version 1.02.140-RHEL7 (2017-05-03)]] SystemStatus:[] Plugins:{Volume:[local] Network:[bridge host macvlan null overlay] Authorization:[] Log:[]} MemoryLimit:true SwapLimit:true KernelMemory:true CPUCfsPeriod:true CPUCfsQuota:true CPUShares:true CPUSet:true IPv4Forwarding:true BridgeNfIptables:true BridgeNfIP6tables:true Debug:false NFd:32 OomKillDisable:true NGoroutines:126 SystemTime:2018-01-27T20:47:36.703541366+08:00 LoggingDriver:json-file CgroupDriver:systemd NEventsListener:0 KernelVersion:3.10.0-693.5.2.el7.x86_64 OperatingSystem:CentOS Linux 7 (Core) OSType:linux Architecture:x86_64 IndexServerAddress:https://index.docker.io/v1/ RegistryConfig:0xc420a23ce0 NCPU:16 MemTotal:16641425408 GenericResources:[] DockerRootDir:/var/lib/docker HTTPProxy:http://master.k8s.samwong.im:8118 HTTPSProxy:127.0.0.1:8118 NoProxy:localhost,192.168.0.0/16,127.0.0.1,10.244.0.0/16 Name:aniu-k8s Labels:[] ExperimentalBuild:false ServerVersion:17.03.2-ce ClusterStore: ClusterAdvertise: Runtimes:map[runc:{Path:docker-runc Args:[]}] DefaultRuntime:runc Swarm:{NodeID:8dsysdk50g7pey46yeidxwtz7 NodeAddr:192.168.10.10 LocalNodeState:active ControlAvailable:true Error: RemoteManagers:[{NodeID:8dsysdk50g7pey46yeidxwtz7 Addr:192.168.10.10:2377}] Nodes:1 Managers:1 Cluster:0xc42046f680} LiveRestoreEnabled:false Isolation: InitBinary:docker-init ContainerdCommit:{ID:4ab9917febca54791c5f071a9d1f404867857fcc Expected:4ab9917febca54791c5f071a9d1f404867857fcc} RuncCommit:{ID:54296cf40ad8143b62dbcaa1d90e520a2136ddfe Expected:54296cf40ad8143b62dbcaa1d90e520a2136ddfe} InitCommit:{ID:949e6fa Expected:949e6fa} SecurityOptions:[name=seccomp,profile=default]}
error: failed to run Kubelet: failed to create kubelet: misconfiguration: kubelet cgroup driver: "cgroupfs" is different from docker cgroup driver: "systemd"


- Error adding network: open /run/flannel/subnet.env: no such file or directory


kubeadm init --pod-network-cidr=10.244.0.0/16




