# xen使用常见错误归纳

- 1. guest can't start

```
[root@xen-2 ~]# virsh start api-1
error: Failed to start domain api-1
error: internal error: libxenlight failed to create new domain 'api-1'
```

- 2018-04-03 02:00:07.596+0000: 30477: error : virDomainSnapshotNum:358 : this function is not supported by the connection driver: virDomainSnapshotNum

```bash
# 使用virsh undefine vm 删除虚拟机报错
```

## 