# 创建虚拟机报错

openstack server create --flavor m1.small --image CentOS7 --security-group default --nic net-id=$netID --key-name mykey CentOS_7

# More than one SecurityGroup exists with the name 'default'

[root@controller ~(keystone)]# neutron security-group-list
neutron CLI is deprecated and will be removed in the future. Use openstack CLI instead.
+--------------------------------------+---------+----------------------------------+----------------------------------------------------------------------+
| id                                   | name    | tenant_id                        | security_group_rules                                                 |
+--------------------------------------+---------+----------------------------------+----------------------------------------------------------------------+
| 4417dd67-df0d-4f04-9294-d70dfce3f8b5 | default | 74eeb2aab1e94fbf91ba9754c330e3c9 | egress, IPv4                                                         |
|                                      |         |                                  | egress, IPv6                                                         |
|                                      |         |                                  | ingress, IPv4, remote_group_id: 4417dd67-df0d-4f04-9294-d70dfce3f8b5 |
|                                      |         |                                  | ingress, IPv6, remote_group_id: 4417dd67-df0d-4f04-9294-d70dfce3f8b5 |
| 7a4c6575-c577-48c4-a0dc-7a45b01d22ab | default | feed463f287f4362a31f3e43adfeba8f | egress, IPv4                                                         |
|                                      |         |                                  | egress, IPv6                                                         |
|                                      |         |                                  | ingress, IPv4, remote_group_id: 7a4c6575-c577-48c4-a0dc-7a45b01d22ab |
|                                      |         |                                  | ingress, IPv6, remote_group_id: 7a4c6575-c577-48c4-a0dc-7a45b01d22ab |
+--------------------------------------+---------+----------------------------------+----------------------------------------------------------------------+

# 新建neutron安全组
[root@controller ~(keystone)]# neutron security-group-create yunwei
openstack server create --flavor m1.small --image CentOS7 --security-group yunwei --nic net-id=$netID --key-name mykey CentOS_7

[root@controller ~(keystone)]# openstack server create --flavor m1.small --image CentOS7 --security-group yunwei --nic net-id=$netID --key-name mykey CentOS_7
+-------------------------------------+------------------------------------------------+
| Field                               | Value                                          |
+-------------------------------------+------------------------------------------------+
| OS-DCF:diskConfig                   | MANUAL                                         |
| OS-EXT-AZ:availability_zone         |                                                |
| OS-EXT-SRV-ATTR:host                | None                                           |
| OS-EXT-SRV-ATTR:hypervisor_hostname | None                                           |
| OS-EXT-SRV-ATTR:instance_name       |                                                |
| OS-EXT-STS:power_state              | NOSTATE                                        |
| OS-EXT-STS:task_state               | scheduling                                     |
| OS-EXT-STS:vm_state                 | building                                       |
| OS-SRV-USG:launched_at              | None                                           |
| OS-SRV-USG:terminated_at            | None                                           |
| accessIPv4                          |                                                |
| accessIPv6                          |                                                |
| addresses                           |                                                |
| adminPass                           | iNanss8Jx5bA                                   |
| config_drive                        |                                                |
| created                             | 2018-03-13T06:27:26Z                           |
| flavor                              | m1.small (0)                                   |
| hostId                              |                                                |
| id                                  | 91614335-9224-407a-a3b1-d46e2ace7774           |
| image                               | CentOS7 (1bd9e34e-c56f-45b0-bde8-cb9fd8b93778) |
| key_name                            | mykey                                          |
| name                                | CentOS_7                                       |
| progress                            | 0                                              |
| project_id                          | feed463f287f4362a31f3e43adfeba8f               |
| properties                          |                                                |
| security_groups                     | name='4b0354c2-7298-40ef-be09-22e9fcbed710'    |
| status                              | BUILD                                          |
| updated                             | 2018-03-13T06:27:26Z                           |
| user_id                             | 0d2fa36656314ccd98ac52702deca71b               |
| volumes_attached                    |                                                |
+-------------------------------------+------------------------------------------------+
# 或者使用tenant_id

openstack server create --flavor m1.small --image CentOS7 --security-group 74eeb2aab1e94fbf91ba9754c330e3c9 --nic net-id=$netID --key-name mykey CentOS_7

#
openstack security group rule create --protocol icmp --ingress yunwei # 使用创建的虚拟机通局域网


# 创建虚拟机报错

错误： 实例 "vm2" 执行所请求操作失败，实例处于错误状态。: 请稍后再试 [错误: Build of instance 4c64cbd2-4c57-40f3-95f5-09abaad8ceb7 aborted: Unable to establish connection to http://127.0.0.1:9696/v2.0/networks?id=b522591d-637c-41cb-9fd1-a3ede5d7bc7f: HTTPConnectionPool(host='127.0.0.1', port=9696): Max retries exceeded with url: ].

lvdisplay | grep "8580f464-02e1-411c-bd94-a4af35e499a3"

lsof| grep "8580f464-02e1-411c-bd94-a4af35e499a3"

lvremove /dev/cinder-volumes/volume-8580f464-02e1-411c-bd94-a4af35e499a3

dmsetup info -c /dev/cinder-volumes/volume-8580f464-02e1-411c-bd94-a4af35e499a3

fuser -m /dev/cinder-volumes/volume-8580f464-02e1-411c-bd94-a
