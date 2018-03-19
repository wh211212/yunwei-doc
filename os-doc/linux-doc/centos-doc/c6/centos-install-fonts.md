# Linux系统安装Windows字体步骤如下：

- 1.复制字体

》 在“C:\Windows\Fonts”目录下找到所要安装字体，这里以“simsun.ttf”为例。如果安装的字体找不到，就去网上下载。

- 2.上传字体至CentOS系统

> 在/usr/share/fonts目录下建立一个子目录，比如/winFonts。上传“simsun.ttf”字体至此目录。

- 3.进入此目录安装

```

cd /usr/share/fonts/winFonts
```

> 运行以下命令建立字体索引信息，更新字体缓存：：
```
# sudo mkfontscale
# sudo mkfontdir
# sudo fc-cache -fv
```

- 执行以下命令让字体生效
-
```
source /etc/profile
```

- 4.问题与解决

> 如果安装失败可以尝试更改权限：

# cd /usr/share/fonts/chinaese
# chmod 755 *.ttf

若提示 “ mkfontscale: command not found”，用yum安装：

# yum install mkfontscale
1
1
提示 “ fc-cache: command not found”

# yum install fontconfig

若需要重启服务器：

# reboot

查看已安装的字体：

# fc-list
fc-list :lang=zh