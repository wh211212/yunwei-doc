# 忘记虚拟机root密码


# install guest

virt-install -d -n log_server -r 4096 --vcpus=2 --disk /dev/vg_fzxen4/log_server --nographics -p -l https://mirrors.aliyun.com/centos/6.9/os/x86_64/ --extra-args="text console=com1 utf8 console=hvc0"
