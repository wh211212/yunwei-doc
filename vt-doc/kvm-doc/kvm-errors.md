# kvm vm 无法正常关机

> shutdown使用发送acpi指令来控制虚拟机的电源，而KVM虚拟机安装Linux系统时默认没有安装acpi服务，反以导致不能关闭虚拟机，需要安装acpi。

## 登录虚拟机安装acpid服务，并启动acpid

yum install -y acpid && /etc/init.d/acpid start && chkconfig acpid on

> 然后即可通过virsh shutdown vm-name 来正常变比虚拟机

# warning : qemuDomainObjStart:6253 : Unable to restore from managed state /var/lib/libvirt/qemu/save/kvm-2.save. Maybe the file is corrupted?

> 分析：此问题是Selinux策略导致，参考redhat官网解决：

- https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/5/html/Virtualization/sect-Virtualization-Security_for_virtualization-SELinux_and_virtualization.html

##

#  semanage SELinux Command Not Found

yum -y install policycoreutils-python


# error: Refusing to undefine while domain managed save image exists

/var/lib/libvirt/qemu(/.*)?     system_u:object_r:qemu_var_run_t:s0

# test


# Couldn't find device with uuid hbjilq-T2b2-W289-p9T8-1ZZQ-4y6x-gIKnyi

# Setting up Logical Volume Management:   Couldn't find device with uuid lvHEVT-1BZ3-4CAZ-tYXe-e1g1-nbqK-4CHFlk.

## kvm 虚拟机启动不了

- 内存溢出，降低虚拟机最大启动内存
