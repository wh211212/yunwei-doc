# kvm虚拟机挂载lvm卷

```
virsh attach-disk kvm-3 /dev/vg_shkvm3/kvm-3-data vdb --driver qemu --mode shareable
```

## 登录到kvm-3

```
[root@sh-kvm-3-3 ~]# fdisk -l

Disk /dev/vda: 21.5 GB, 21474836480 bytes
16 heads, 63 sectors/track, 41610 cylinders
Units = cylinders of 1008 * 512 = 516096 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00002155

   Device Boot      Start         End      Blocks   Id  System
/dev/vda1   *           3        1018      512000   83  Linux
Partition 1 does not end on cylinder boundary.
/dev/vda2            1018       41611    20458496   8e  Linux LVM
Partition 2 does not end on cylinder boundary.

Disk /dev/mapper/VolGroup-lv_root: 18.8 GB, 18798870528 bytes
255 heads, 63 sectors/track, 2285 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000


Disk /dev/mapper/VolGroup-lv_swap: 2147 MB, 2147483648 bytes
255 heads, 63 sectors/track, 261 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000


Disk /dev/vdb: 53.7 GB, 53687091200 bytes
16 heads, 63 sectors/track, 104025 cylinders
Units = cylinders of 1008 * 512 = 516096 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000
[root@sh-kvm-3-3 ~]# fdisk /dev/vdb #分区 
Device contains neither a valid DOS partition table, nor Sun, SGI or OSF disklabel
Building a new DOS disklabel with disk identifier 0x93edb871.
Changes will remain in memory only, until you decide to write them.
After that, of course, the previous content won't be recoverable.

Warning: invalid flag 0x0000 of partition table 4 will be corrected by w(rite)

WARNING: DOS-compatible mode is deprecated. It's strongly recommended to
         switch off the mode (command 'c') and change display units to
         sectors (command 'u').

Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
p
Partition number (1-4): 1
First cylinder (1-104025, default 1): 
Using default value 1
Last cylinder, +cylinders or +size{K,M,G} (1-104025, default 104025): 
Using default value 104025

Command (m for help): p

Disk /dev/vdb: 53.7 GB, 53687091200 bytes
16 heads, 63 sectors/track, 104025 cylinders
Units = cylinders of 1008 * 512 = 516096 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x93edb871

   Device Boot      Start         End      Blocks   Id  System
/dev/vdb1               1      104025    52428568+  83  Linux

Command (m for help): t
Selected partition 1
Hex code (type L to list codes): 8e
Changed system type of partition 1 to 8e (Linux LVM)

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.
```

- 挂载lvm 到data目录

```
mkfs.ext4 /dev/vdb1
pvcreate /dev/vdb1
vgextend VolGroup /dev/vdb1
lvcreate -n data -L 30G VolGroup
mkdir /data
mkfs.ext4 /dev/VolGroup/data
mount /dev/VolGroup/data  /data/
echo "/dev/mapper/VolGroup-data    /data                   ext4    defaults        1 1"  >> /etc/fstab
```

- 扩容根目录

```
# lvextend -l +100%FREE /dev/mapper/VolGroup-lv_root
# resize2fs /dev/mapper/VolGroup-lv_root
# df -h
Filesystem            Size  Used Avail Use% Mounted on
/dev/mapper/VolGroup-lv_root
                      103G   40G   58G  41% /
tmpfs                 4.9G   12K  4.9G   1% /dev/shm
/dev/xvda1            477M  153M  299M  34% /boot
```