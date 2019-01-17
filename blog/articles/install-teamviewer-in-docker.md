# 【未解决】在docker里面安装teamviewer ？

## 简介

最近跟远程桌面较上劲了！
目前在docker里面装vnc服务器的方案是有的，而且用起来还可以， 但是帧率很低，即时在网速很好的情况下，仍然感觉画面撕裂较严重。 相比而言，在用过teamviewer之后，发现这玩意简直是黑科技啊！  远程桌面画面非常流畅！ 甩vnc 桌面几条街不止！

## 正文

前提你得有一个docker版的vnc镜像，推荐使用这个： `dorowu/ubuntu-desktop-lxde-vnc`

启动后(docker run的时候建议加上 --net host )使用vnc viewer 客户端即可连接了，看到的ubuntu系统的桌面，剩下的事情相对简单。

### teamviewer 安装

安装教程参见官方文档： [https://community.teamviewer.com/t5/Knowledge-Base/How-to-install-TeamViewer-for-Linux/ta-p/6318?_ga=2.88151135.551851422.1527682289-1753742288.1527577184](https://community.teamviewer.com/t5/Knowledge-Base/How-to-install-TeamViewer-for-Linux/ta-p/6318?_ga=2.88151135.551851422.1527682289-1753742288.1527577184)

接着可以用命令 `teamviewer setup` 或者 在开始菜单中点击`teamviewer` 的程序图标启动，

执行`teamviewer setup`  后，它会提示你先同意协议，然后接着输入账号、密码，接着。。。。

接着过了几分钟，就报出下面的错：

```bash
There was a connectivity issue. Please check your internet connection and try again.
```

试了很多种方法，也查了几天的资料，仍然没法解决。期间偶尔能显示连上一小会，又直接断了，其中有一个办法好像有点用：

在 ` /etc/nsswitch.conf` 文件中，找到 `hosts` 这一行，在这一行的值的后面加一项：`mdns4` 。

然后`teamviewer setup` 的时候，输入错误的账号密码，再次输入的时候会提示能连得上一下了.


这个错误
```bash
There was a connectivity issue. Please check your internet connection and try again.
```

如果你知道怎么解决，烦请在评论区告知一下，感谢！


