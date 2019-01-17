# 巧用Docker Volume：数据备份的新潮流！

## 前言

数据备份一直是网站运维中最最重要的一件事，大家都知道数据的宝贵！

而数据备份通常主要包括：文件备份以及数据库备份。

下面，将主要针对较为频繁`数据库备份` 进行讨论，对比一下其传统备份方式与现代[Docker](https://blog.zhouzhipeng.com/category/docker) 备份方式的差别, 带您体会在容器时代，新的“潮流” 数据备份方式！



## 传统数据库备份方式

以关系型数据库`mysql` 为例，抛开其主从架构、冷备热备不谈，一般而言，如果需要手动用命令备份数据，可以用如下命令：

```bash
mysqldump -h your_mysql_host -P your_mysql_port -uuser -p db_name > db_name_`date +%Y%m%d`.sql
```

直接用的`mysql`自带命令`mysqldump`, 看起来还不错，这种方式有点缺陷在于：

> 当数据量较大时，dump 生成sql会比较慢，毕竟需要一定的逻辑运算

（当然，您肯定有比mysqldump更好的备份方式，这里不做延伸, 重在与后文进行对比:) ）



当然，有备份就有还原，上述备份方式对应的还原方式也很容易：

```bash
mysql -u root -h your_mysql_host -P your_mysql_port -p   db_name < db_name_20180212.sql
```

看似也不错，唯一一点小小的缺陷是：

> 被还原的数据库db_name 需要事先创建好

（当然，您也许有不用事先创建db_name的更优雅方式，这里不做延伸 , 重在与后文进行对比:) )



## Docker Volume备份方式

好的，终于要进入正题了！

![](../static/images/2018/02/可爱docker.png)



相信大家对上面这个可爱的卡通logo一定不会陌生，如果您还不知道什么是`Docker` 的话，可以先阅读下我的另一篇文章：[走进docker的世界之入门篇](https://blog.zhouzhipeng.com/walk-in-docker-beginning.html)



> 预备知识
>
> 1. Docker Volume 数据卷: [官方文档](https://docs.docker.com/storage/volumes/)
> 2. Docker Registry 仓库: [Docker 私有仓库搭建](https://blog.zhouzhipeng.com/install-docker-private-registry.html)



以下操作的前提是：

> 你的数据库是以Docker容器方式运行的！

为了与传统模式进行鲜明的对比，我们也运行一个`mysql`的容器。



### 创建数据卷

在运行容器之前，先使用`docker volume create` 创建一个数据卷，用于挂载映射mysql容器数据文件:

```bash
[root@localhost ~]# docker volume create mysql_data
mysql_data
```

用`docker volume inspect` 命令看下刚创建的`mysql_data` 数据卷的详细信息:

```bash
[root@localhost ~]# docker volume inspect mysql_data
[
    {
        "CreatedAt": "2018-02-12T09:14:45+08:00",
        "Driver": "local",
        "Labels": {},
        "Mountpoint": "/var/lib/docker/volumes/mysql_data/_data",
        "Name": "mysql_data",
        "Options": {},
        "Scope": "local"
    }
]
```

大家注意到这一行`        "Mountpoint": "/var/lib/docker/volumes/mysql_data/_data"`

这是数据卷`mysql_data` 在宿主机上的目录路径 , 我们先`cd`进去看一看：

```bash
[root@localhost ~]# cd /var/lib/docker/volumes/mysql_data/_data
[root@localhost _data]# ls
[root@localhost _data]# pwd
/var/lib/docker/volumes/mysql_data/_data
[root@localhost _data]#
```

对的，目前是空空如也！因为还没有容器会挂载它。



### 运行mysql容器

mysql版本选用较为流行的5.x 系列， 使用`docker run `  运行mysql容器:

```bash
[root@localhost _data]# docker run -d --name mysql5.7 -e MYSQL_ROOT_PASSWORD=123456  -p 3307:3306 -v mysql_data:/var/lib/mysql  mysql:5.7
7e971e3a80c8b3235230417a76387a61ad86c7de68fa6086bde3cbd8f162691a
```

注意上面命令中的 `-v mysql_data:/var/lib/mysql`  ，它会将前面我们创建好的数据卷`mysql_data` 挂载到mysql容器内部的`/var/lib/mysql` 目录。  （具体可参考[docker hub mysql]( https://hub.docker.com/_/mysql/)）



首先，还是先检查下刚创建的`mysql`容器正常与否，使用`docker exec` 命令连到mysql服务器：

```bash
[root@localhost ~]# docker exec -it mysql5.7 mysql -uroot -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 3
Server version: 5.7.20 MySQL Community Server (GPL)

Copyright (c) 2000, 2017, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```

连接ok, 接着 创建一张表并造点数据：

```bash
mysql> use mysql;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> create table person(name varchar(100),age int);
Query OK, 0 rows affected (0.33 sec)

mysql> insert into person(name,age) values('zhouzhipeng.com',18);
Query OK, 1 row affected (0.02 sec)

mysql> select * from person;
+-----------------+------+
| name            | age  |
+-----------------+------+
| zhouzhipeng.com |   18 |
+-----------------+------+
1 row in set (0.00 sec)

mysql>
```



到目前为止，数据已准备ok。 接下来，我们将备份mysql数据库，并在另一台机器上还原我们的数据！

>  客官，请接着往下看!



## 备份数据库

有了数据卷`mysql_data` ，剩下的事情就会变得异常简单，此时此刻，再也不用关心我们的数据库时什么类型的，mysql?  postgresql? ....

>  数据库类型这些都不重要！ 用`docker` 数据卷，我们只用关心`文件`！

很简单的备份方式，将`mysql_data` 目录打包，并上传到ftp或者docker仓库（我们选用后者)。

```bash
# 0.先停掉mysql5.7 (可选)
docker stop mysql5.7

# 1. 将mysql_data数据卷挂载到另一个容器(alpine镜像)
# 以下这条命令只需要执行一次，为了防止容器启动后终止掉(alpine入口命令为sh)，使用 入口命令ping 127.0.0.1 可以使其一直挂载后台运行
docker run -d --name mysql-backup -v mysql_data:/volume alpine ping 127.0.0.1


# 2. 在上面创建的mysql-backup容器上，使用tar命令打包目录
docker exec -it mysql-backup tar -cjf /mysql_data.tar.bz2 -C /volume ./

# 3.可以进到容器check下文件是否有
[root@localhost ~]# docker exec -it mysql-backup sh
/ # ls -lh mysql_data.tar.bz2
-rw-r--r--    1 root     root        5.2M Feb 12 02:39 mysql_data.tar.bz2


# ok，一切正常
```



> 这样就完了吗？没有！

要知道，数据备份如果放在本地，仍然是不安全的，我们要把它传到我们的仓库存起来，方便归档，方便迁移！

这里使用docker全家桶之`docker registry` , docker仓库的搭建可以参考：

 [Docker 私有仓库搭建](https://blog.zhouzhipeng.com/install-docker-private-registry.html)



因为我比较穷（没钱买服务器做docker仓库），所以这里为了方便直接用某云的免费docker仓库。

###

###备份上传到docker仓库

还记得前面为了打个`tar`包创建的一个alpine容器吗？

`docker run -d --name mysql-backup -v mysql_data:/volume alpine ping 127.0.0.1`

（你以为真的就为了打包个目录，就花费这么大力气运行个容器来做？）

> docker化一切，包括你的数据！

```bash
# 1. 提交容器变更到新的镜像(就想你用git一样)
[root@localhost ~]# docker commit  -m "我的mysql数据备份" mysql-backup registry.cn-shanghai.aliyuncs.com/zhouzhipeng/mysql-backup:20180212
sha256:263c779bc7ff489e8a5c01bd95d0901e98f3f7c29b2f2ff51388be36983e593d

# 2. 将镜像push到仓库(就想你用git一样)
[root@localhost ~]# docker push registry.cn-shanghai.aliyuncs.com/zhouzhipeng/mysql-backup:20180212
The push refers to a repository [registry.cn-shanghai.aliyuncs.com/zhouzhipeng/mysql-backup]
fe0aee4fcfed: Pushed
5bef08742407: Pushed
20180212: digest: sha256:a1cc7fb06b11baf6376be550620e60fb2dcc29abf154ffd4564487a09c56d8d7 size: 739
[root@localhost ~]#

# 3. 完成
```



好了，终于，我们的数据算是“安全” 了！

接下来，我们换一台机器演示下如何还原数据库！



## 还原数据库

曾经也许你和运维是这样交流还原数据库细节的：

> 你：可以帮我还原下xxx业务的postgres数据库吗？
>
> 运维大叔：啥？postgres是个啥数据库？我没用过啊，命令不会敲!
>
> 你： 额。。。
>
> （结局：你和运维大叔一起花了数小时完成了还原工作！）

（运维不会某些数据库命令很正常，但是他不会docker命令就很诡异了！）



真正展现docker威力的地方可能是在这里！终于，你可以大声跟运维大叔说

> 你：可以帮我还原下xxx业务的xxx数据库吗？镜像名称我发你消息了。
>
> 运维大叔：好的
>
> 一分钟后.....
>
> 运维大叔： all done!



啥也不说了，我们来操作：

```bash
# 1. 为了测试效果，我换了一台机器
# 2. 创建数据卷
[zhipeng.zhou@instance-2 ~]$ docker volume create mysql_data
mysql_data

# 3. 用前面做好的数据镜像：registry.cn-shanghai.aliyuncs.com/zhouzhipeng/mysql-backup:20180212
docker run  --rm  -v mysql_data:/volume   registry.cn-shanghai.aliyuncs.com/zhouzhipeng/mysql-backup:20180212 sh -c "rm -rf /volume/* /volume/..?* /volume/.[!.]* ; tar -C /volume/ -xjf  /mysql_data.tar.bz2 ;"

## 简单解释下上面的命令: 这里用前面创建好的备份镜像 挂载到mysql_data数据卷目录,使用tar命令将之前做好的tar包进行解压

# 4. check下文件是否正常(mysql_data数据卷目录)
[zhipeng.zhou@instance-2 ~]$ sudo ls /var/lib/docker/volumes/mysql_data/_data
auto.cnf    client-cert.pem  ibdata1      ibtmp1              private_key.pem  server-key.pem
ca-key.pem  client-key.pem   ib_logfile0  mysql               public_key.pem   sys
ca.pem      ib_buffer_pool   ib_logfile1  performance_schema  server-cert.pem


# 5. 运行mysql
[zhipeng.zhou@instance-2 ~]$ docker run -d --name mysql5.7 -e MYSQL_ROOT_PASSWORD=123456  -p 3307:3306 -v mysql_data:/var/lib/mysql  mysql:5.7

# 6. 连接测试
[zhipeng.zhou@instance-2 ~]$ docker exec -it mysql5.7 mysql -uroot -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 2
Server version: 5.7.21 MySQL Community Server (GPL)

Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> use mysql;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> select * from person;
+-----------------+------+
| name            | age  |
+-----------------+------+
| zhouzhipeng.com |   18 |
+-----------------+------+
1 row in set (0.00 sec)

mysql>

# 7. all done

```



## 总结

>  以上全过程为本人实际操作，仅仅是抛砖引玉，有些细节可能考虑不周，敬请见谅。

仔细体会全过程，你会发现当一切围绕docker展开时，我们就不用关心ftp文件服、数据库类型、数据库命令特性、以及其他细节。。。



容器化的时代确实来了，有状态的数据库容器、无状态的应用容器，在docker化的世界里争相斗艳！你可以保留传统的操作方式、运维模式，但请不要拒绝任何能提升生产力，解放双手的终极信仰！



