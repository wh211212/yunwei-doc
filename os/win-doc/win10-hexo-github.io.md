# win10+hexo+github搭建个人博客

> 参考：https://hexo.io/，博客用于记录自己的学习工作历程

## 参考以下步骤安装

> 1、搭建环境准备（包括node.js和git环境，gitHub账户的配置）
> 2、安装 配置Hexo,配置将Hexo与github page结合起来
> 3、怎样发布文章 主题 推荐 主题
> 4、Net的简单配置 添加sitemap和feed插件
> 5、添加404 公益页面

## 安装并配置环境

> win10+Node.js+git+github

- Node.js下载地址：https://nodejs.org/en/download/
- Git下载地址：https://git-scm.com/
- Github 地址：https://github.com

> 安装node.js 和 git 步骤省略，按默认傻瓜式安装即可

## 注册github账号并创建一个以 github昵称.github.io 命名的仓库

![reg-github](http://img.blog.csdn.net/20170711215441177?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

> 根据图中，注册一个github账号，昵称自定义，然后创建一个新项目，名字为：github昵称.github.io

- 项目创建完成之后，本地生成ssh 私钥和公钥，用于连接github认证，使用上面下载的git，打开git bash

![ssh-shaonbean](http://img.blog.csdn.net/20170711215556298?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

```
ssh-keygen -t rsa -C "github注册邮箱（自定义）" -f .ssh/shaonbean
# -f 输出以昵称命名的公钥和私钥，方便记忆
```
- 公钥生成之后加到github上，方便后面的使用，用户本地和github进行ssh通信

![ssh-add-github](http://img.blog.csdn.net/20170711215846144?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

> 到这里github设置告一段落

## 安装配置hexo

> 注：hexo安装前提需安装node.js 和git

- hexo官网：https://hexo.io/
- hexo官方文档：https://hexo.io/docs/

> 文中以J盘为例，创建目录github并创建字目录（用于存放项目）

```
vdevops@shaon MINGW64 /j/github/shaonbean
# 注： 如果是linux环境下搭建的hexo博客，不建议使用root权限
```

- 下载安装hexo

```
npm install -g hexo-cli
# 等待片刻，执行hexo如下图表示安装成功
hexo
```

![这里写图片描述](http://img.blog.csdn.net/20170711222448718?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)


- 初始化博客

> 这里以shaonbean为博客目录，执行下面命令

```
hexo init shaonbean   # 创始化项目
cd shaonbean
npm install
```

- 测试本地建站是否成功，输入：

```
hexo s
INFO  Start processing
INFO  Hexo is running at http://localhost:4000/. Press Ctrl+C to stop.
# 出现上面两行，即表示本地建站成功
```

- 初始化博客以后，能看到下图：

![hexo](http://img.blog.csdn.net/20170711222510967?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

- 配置博客

> 博客根目录初始化完成之后进项自定义配置，这里用到_config.yml

### 自定义博客的相关信息

> 编辑_config.yml配置文件，进行修改，参考下面配置：

```
title: itdevops
subtitle: DevOps is everything
description: From Zero to the DevOps
author: shaonbean
language: zh-CN
timezone: Asia/Shanghai
# language和timezone 有规范，注意格式
```

### 配置个人域名

```
url: http://vdevops.com
```

### 配置部署

```
deploy:
  type: git
  repo: https://github.com/shaonbean/shaonbean.github.io.git
  branch: master
```
> repo项是之前Github上创建好的仓库的地址

```
exec ssh-agent bash
ssh-add MYKEY
# 这里是针对本地设置多个github账号进行操作
```

- 本地生成两对密钥对，然后在~/.ssh/目录下新建config文件，参考下面填入：

```
#————GitHub—————
Host github
    HostName github.com
    User git
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/id_rsa

# github.io
Host github.io
    HostName github.com
    User git
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/itdevops
```

- 测试本地ssh连接github是否正常

```
ssh -T git@github
ssh -T git@github.io
# 笔者这里第二个账号没设置成功，临时使用的https方式进行的通信
```

- 使用https，github账号加密码的方式来进行hexo的部署。配置如下：

```
deploy:
  type: git
  #repo: git@github.io:shaonbean/shaonbean.github.io.git
  repo: https://shaonbean:shaonbeanpassword@github.com/shaonbean/shaonbean.github.io.git
  branch: master
  message: devops
```

### 配置完成之后，现在可以进到设置的项目目录里面通过hexo部署到github

> 进到你的项目目录。命令行执行下面命令：

```
hexo g   # 本地生成数据库文件，目录等
hexo d   # 部署到远程
```

- 新建一篇博客

```
hexo new post "devops"
```

> 然后通过电脑编辑器（atom）对文章进行编辑，编辑完成之后，再次运行上面的生成，部署命令

```
hexo g   # 本地生成博客
hexo d   # 发布到远程
hexo d -g #在部署前先生成
```
> 注： 安装git扩展

```
npm install hexo-deployer-git --save
# 没安装插件可能报错：deloyer not found:git
```

- ssh key报错

```
Permission denied (publickey).
fatal: Could not read from remote repository.
Please make sure you have the correct access rights
and the repository exists.
```

> 后面笔者会专门写一篇添加ssh 密钥的文章

- 部署完成可以看到github上面shaonbean.github.io，已经存在文件，通过浏览器访问如下：

![github](http://img.blog.csdn.net/20170712085631907?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

![itdevops](http://img.blog.csdn.net/20170712085650532?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

> 从上面可以看出我们已经成功部署到远程，并能够正常访问。

### 配置博客主题

> 选择NexT，star最多，原因不多说
> 知乎主题推荐：https://www.zhihu.com/question/24422335

```
cd /j/github/shaonbean.github.io # 这里项目名可以自定义
git clone https://github.com/iissnan/hexo-theme-next themes/next
```
- 更换主题完成后，访问：

![next](http://img.blog.csdn.net/20170712093352566?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

### 参考链接

- http://blog.csdn.net/gdutxiaoxu/article/details/53576018
- http://www.jeyzhang.com/hexo-github-blog-building.html
- https://www.zrj96.com/post-471.html
