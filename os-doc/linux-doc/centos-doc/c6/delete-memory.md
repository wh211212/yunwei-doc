# linux 删除缓存

To free pagecache:

# echo 1 > /proc/sys/vm/drop_caches
To free dentries and inodes:

# echo 2 > /proc/sys/vm/drop_caches
To free pagecache, dentries and inodes:

echo 3 > /proc/sys/vm/drop_caches