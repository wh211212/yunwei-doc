# Ansible 性能优化

> 使用Ansible管理服务器当数量增加到一定数量后，就会出现执行效率下降的问题，本文介绍优化ansible使用的一些方案

## 优化准备

> 进行性能优化前需要收集一些统计数据，用于对比优化前后的数据对比。Github上有开源的一个Ansible任务计时插件，安装插件会显示ansible-playbook执行每个任务所花费的时间。
- 插件地址：https://github.com/jlafon/ansible-profile

> 安装并使用插件：

```
# 参考github
cd /etc/ansible
mkdir plugins
wget https://raw.githubusercontent.com/jlafon/ansible-profile/master/callback_plugins/profile_tasks.py
echo "<callback_white></callback_white>list = profile_tasks" >> /etc/ansible/ansible.cfg
```

>安装完成，执行playbook暂未显示任务执行完成花费时间。

## 优化Ansible速度

- 1. 开启SSH长连接

> OpenSSH 5.6版本以后SSH就支持了Multiplexing，修改ansible.cfg文件中设置SSH长连接,设置参数如下:

```
sh_args = -o ControlMaster=auto -o ControlPersist=5d
```
