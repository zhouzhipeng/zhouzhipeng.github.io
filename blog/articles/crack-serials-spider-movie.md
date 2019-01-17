# 薅羊毛系列之蜘蛛网电影抢票分析

说明：以下内容从我的个人博客 blog.zhouzhipeng.com 复制过来，两边同步发布。

首先声明一下，这里并不是给蜘蛛网打广告。自己平时也比较喜欢看电影，刚好蜘蛛网电影app上有一个周六建行5元抢票活动，由于活动很火爆，几乎很少能抢到！ 所以想借用程序手段，自动提交抢票接口，来试图能抢到5元电影票。

虽然没有技术含量的东西，主要是想记录一下，方便自己日后来回忆一下，同时也是一个思路的整理。
好了，废话不多说，下面开始hack之旅！

<!--more-->


## 前言

和所有电影app一样，在经过选电影-> 选场次-> 选桌位 之后，来到了确认提交页面，如下：

![](/wp-content/uploads/2018/02/蜘蛛网活动抢票页面.jpg)


可以看到上图中活动优惠有很多，我想"破"的就是`龙卡星期六 5元看电影` 这个 （因为活动时间已过，可以看到它显示的是灰色,我是上午完成的抓包分析以及写代码，图片现在补上的）

理想情况是，你选好要看的电影只有进来这个页面，刚好上午10点整的时候，`5元`这个活动就可以开始抢了！ 现实情况是到了9：59 分快到10点差不多的时候，进来这个页面你会发现被
告知已经"抢完了"！

现实很残酷，考验网速和手速以及运气！  但是身为一名小码农，怎能像一般人一样也在哪里拼手气呢！（?)

## 第一步：抓包分析

不出意外的话，它的这个订单提交页面应该是http(s) 请求的，既然如此，当时就是先来抓包分析下http请求咯！

因为我的用的是mac电脑，所以用的`Charles`来抓包，略过配置步骤，直接贴一下抓包的请求：

![](/wp-content/uploads/2018/02/蜘蛛网抢票抓包.png)

经过初步的分析和体验（我自己选了一个其他可用的活动提交了一个真实订单）， 发现最终提交订单的接口的是
```bash
https://film.spider.com.cn/huayins/lockSeatList.html?insBirthday=&insId=&token=455FBE5EF0A0ED9545231547BB3050C6&userId=5da71497b4160d20c806c0568e535e07&hallId=17&feePrice=2.0%257C2.0&cinemaId=31070901&currentVersion=4.9.0&channelId=sfVivo&appVersion=460&version=410&activityId=101511&showId=0170100000000000060598689&userName=xxxxxxxxxxx&partnerPrice=59.00&sign=e3277328f9fa9434efcec30e8259ad23&filetype=json&mobile=13080669828&insName=&filmId=201709909870&fpCount=&parorderId=610024803&seatId=6%253A9%257C6%253A8&key=huayins&fpId=
```
其中真实的`userName` 已被我和谐掉了。

用`postman` 工具把参数展开看一下：

![](/wp-content/uploads/2018/02/蜘蛛网抢票url参数.png)

凭借这多年的web开发经验（? 装下b）, 会发现破案的难点在于上图红框中的两个参数`token` `sign`， 一般而已`token`是登陆用的，而`sign`则为请求合法性的校验值 （一般sign是多个参数值按照一定顺序拼接之后再用md5加密得来.  ? 对的，一般是)

### 简化问题

上面的`lockSeatList` 链接中，有很多参数都是相对固定的，像什么活动优惠`5元看电影` 这个`activityId`很容从其他抓包得到的查询接口中获取，在此不一一追溯.
而关键参数`token`通过我刷了几次接口会发现，它在一段时间内也是不会变的，暂时不考虑其生成方式。

那么剩下的最后一个难点问题在于我们怎么能知道`sign`的生成算法呢？！

对的，靠猜！ （☺️） 开玩笑啦，当时是通过反编译看代码！！

## 第二步：反编译apk

没错，我们先假设蜘蛛网电影安卓app没有很变态的加固、混淆之类的。 （如果有的话，就直接放弃得了，太花时间了。。。）

先到蜘蛛网官网弄一个apk文件（这个很容易!) 这里我不会贴任何下载链接，需要的实践的朋友请自己去找。

拿到apk之后，不要慌张，善于利用一些大牛弄的反编译工具，这里给大家介绍一个 ，真的挺不错的 [javadecompilers.com](http://javadecompilers.com/apk) (国外的网站，打开可能有点慢)

进去之后，基本上傻瓜式的操作，直接上传apk文件，点一下`Upload and Decompile` 按钮，剩下的就是等待了几分钟了。直接可以下载反编译之后的源代码文件！

![](/wp-content/uploads/2018/02/蜘蛛网apk反编译网站.png)

得到源代码之后，剩下的事情就是分析代码，找出sign的生成算法了！！


## 第三步：分析代码

用你熟悉的工具代开源代码文件夹，这里我用的是`Intellij IDEA` ，打开之后如下所示：

![](/wp-content/uploads/2018/02/蜘蛛网apk源代码.png)


有没有。。。。  很懵逼的感觉！！！  特么这么多的文件，从哪找起啊！！！


### 寻找入口很重要

在做任何事情都不能太盲目，我们要淡定、从容（? ）。 先回忆下`第一步：抓包分析` 中发现的url `https://film.spider.com.cn/huayins/lockSeatList.html?xxxx`
是的，它就是入口！

找到发起该url请求的地方必定是我们要的，而这里的关键字符串`lockSeatList.html` 如果不出意外的话肯定是在代码中某个地方写死的！

好的，我们先搜索一下`lockSeatList.html`在哪里出现:
![](/wp-content/uploads/2018/02/蜘蛛网代码分析值lockSeatList搜索.png)

如上图所示，一共有三处地方，我们一个个的试一下。 先接着搜索第一处 `ae` 或 `C4767f.ae` 静态字段出现的地方:
![](/wp-content/uploads/2018/02/蜘蛛网代码分析之搜索ae.png)

出现了很多处，但是经过简单的分析判断，它并不是我们要的， "第一处" 排除.

接着，看下"第二处":
![](/wp-content/uploads/2018/02/蜘蛛网代码分析之lockSeatList第二处.png)

恩，很高端的样子，android界出了很多类似这种retrofit的框架，把http调用弄得用注解搞一下就完成了。。 鉴于有点复杂，可以先放一放这个，后面如果"第三处"也不是我们
要的，再回头来分析下这个方法的调用方。

是的 ，直接突击"第三处"疑似点：
![](/wp-content/uploads/2018/02/蜘蛛网代码分析值lockSeatList搜索第三处.png)

接着再搜索`f7910W` 出现的地方:
![](/wp-content/uploads/2018/02/Snip20180113_115.png)

刚好只有一处地方出现（第二个是它自己本身，不算），注意看上图红框的地方，是不是有点像！ 估计就是它了！！


### 水落石出
好的，我们进去看一看：
![](/wp-content/uploads/2018/02/Snip20180113_116.png)

注意我标的红箭头的地方，这些并不是直接字符串，还得一个个的去搜索这些变量的字符串是个啥！
为了节省点大家的阅读时间，这里就不一一上搜索的截图了，搜索变量的方法与上面类似，直接晒一下我们最终要找的`sign`字段的面貌：
![](/wp-content/uploads/2018/02/04166F5C-9A82-4CE0-BC12-CBBC5CA95613.png)

![](/wp-content/uploads/2018/02/Snip20180113_118.png)

不难发现，正如我们一开始猜想的，`sign`就是多个参数值拼接起来再加密的！ 重点是下面的`stringBuffer2`

```java
StringBuffer stringBuffer2 = new StringBuffer();
stringBuffer2.append(str).append(str2).append(str3).append(str4).append(k).append(m).append(str5).append(str6).append(stringBuffer).append(str7).append(q).append(str8).append(str9).append(str10).append(str11).append(str13).append(str14).append(str15).append("huayins").append("0779257096").append(v);


```

好的，接下来的事情就很简单了，按照上面`append`的顺序，它其实是每个url上的参数的值。 最终`sign`的拼接顺序为：

```bash
showId cinemaId hallId filmId userName userId mobile urldecode(seatId) urldecode(feePrice) parorderId channelId partnerPrice activityId insName insBirthday insId fpId fpCount "huayins" "0779257096" token
```


### 模拟请求

有了以上过程后，我们只需要在原来的url参数上，对需要变更的`activityId`活动编号等做以下更新，动态算出对应的`sign`值接口。 我自己用
`python`实现了一版，在此可能不方便直接公开贴出，需要的小伙伴可以 fork 一份：https://git.io/vNbMh





