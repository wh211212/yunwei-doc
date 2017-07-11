# kvm vm 无法正常关机

> shutdown使用发送acpi指令来控制虚拟机的电源，而KVM虚拟机安装Linux系统时默认没有安装acpi服务，反以导致不能关闭虚拟机，需要安装acpi。

## 登录虚拟机安装acpid服务，并启动acpid

yum install -y acpid
/etc/init.d/acpid start
chkconfig acpid on

> 然后即可通过virsh shutdown vm-name 来正常变比虚拟机


#  

yum -y install policycoreutils-python
