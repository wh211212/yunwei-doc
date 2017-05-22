# tysx-prod-1

1、（192.168.76.100） 更改主机名为tysx-prod-1

2、执行cmd_track

3、挂载目录

lvcreate -n log -L 100G vg0
lvcreate -n data -L 100G vg0

mkfs.ext4 /dev/vg0/data
mkfs.ext4 /dev/vg0/log







# tysx-prod-2
