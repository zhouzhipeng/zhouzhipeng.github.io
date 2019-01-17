# 时序数据库InfluxDB初体验

> 什么是时间序列数据？最简单的定义就是数据格式里包含timestamp字段的数据。比如股票市场的价格，环境中的温度，主机的CPU使用率等。但是又有什么数据是不包含timestamp的呢？几乎所有的数据都可以打上一个timestamp字段。时间序列数据更重要的一个属性是如何去查询它。在查询的时候，对于时间序列我们总是会带上一个时间范围去过滤数据。同时查询的结果里也总是会包含timestamp字段。



## 基本概念

| influxDB中的名词 | 传统数据库中的概念 |
| ------------ | --------- |
| database     | 数据库       |
| measurement  | 数据库中的表    |
| points       | 表里面的一行数据  |



### Point

Point由时间戳（time）、数据（field）、标签（tags）组成。

Point相当于传统数据库里的一行数据，如下表所示：

| Point属性 | 传统数据库中的概念                    |
| ------- | ---------------------------- |
| time    | 每个数据记录时间，是数据库中的主索引(会自动生成)    |
| fields  | 各种记录值（没有索引的属性）也就是记录的值：温度， 湿度 |
| tags    | 各种有索引的属性：地区，海拔               |





## 快速安装

### influxdb docker容器运行

```bash
 docker run -p 8086:8086   -d   --name influxdb    -v /data/docker_volumes/influxdb:/var/lib/influxdb   influxdb
```

关于docker操作可以参考我之前的文章：[https://blog.zhouzhipeng.com/tag/docker](https://blog.zhouzhipeng.com/tag/docker)

## 基本操作

### 控制台命令

shell命令官方文档参考：https://docs.influxdata.com/influxdb/v1.5/tools/shell/

`docker exec -it influxdb influx` 在上面运行的容器中执行influx命令，进入influxdb交互式命令行，如下所示：

```bash
[zhipeng.zhou@instance-1 ~]$ docker exec -it influxdb influx
Connected to http://localhost:8086 version 1.5.1
InfluxDB shell version: 1.5.1
>
>
```

跟mysql差不多，我们先使用`create database test` 创建一个测试库, 接着用`show databases` 查看已有数据库列表:

```bash
> create database test
> show databases
name: databases
name
----
_internal
mydb
test
```



### 数据表操作

在InfluxDB当中，并没有表（table）这个概念，取而代之的是MEASUREMENTS，MEASUREMENTS的功能与传统数据库中的表一致，因此我们也可以将MEASUREMENTS称为InfluxDB中的表。

> MEASUREMENTS 翻译：
>
>   英['meʒəm(ə)nts]   美['mɛʒɚmənts]
>
> - n. 测量值，尺寸（measurement的复数）



1）显示所有表 `SHOW MEASUREMENTS`

```bash
> SHOW MEASUREMENTS
ERR: database name required
Warning: It is possible this error is due to not setting a database.
Please set a database with the command "use <database>".
```

出错了，提示要先`use <database>` , 跟mysql一样：

```bash
> use test
Using database test
> SHOW MEASUREMENTS
>
```

目标没有任何表，接着我们尝试创建一个.



2)  创建表  （`create ??` )

由于InfluxDB中没有显式的新建表的语句，所以只能通过insert数据的方式来建立新表。如下所示：

```bash
insert  cpu_usage,ip=192.168.0.1 value=30 15226580942111
```

** 注意这里的 insert后面没有into !!

其中 cpu_usage 就是表名，ip是tag索引，value=xx是记录值键值对，记录值可以有多个，最后是指定的时间, 查询下刚插入的数据:

```bash
> select * from cpu_usage
name: cpu_usage
time           ip          value
----           --          -----
15226580942111 192.168.0.1 30
```





3） 删除表 (`drop measurement cpu_usage`)



### 数据操作

1) 添加数据

一行数据代表一个`Point`  (见上面的基本概念)  ,  `insert` 语法总结:

`insert <measurement>[,<tag-key>=<tag-value>...] <field-key>=<field-value>[,<field2-key>=<field2-value>...][unix-nano-timestamp]`

> 说明：我们在写入的时候可以不包含时间戳，当没有带时间戳的时候，InfluxDB会自动添加本地的当前时间作为它的时间戳。



2）查询操作

查询语句与SQL一样，在此不再赘述。



3）修改和删除数据

InfluxDB属于时序数据库，没有提供修改和删除数据的方法。

但是删除可以通过InfluxDB的数据保存策略（Retention Policies）来实现。在后续教程中单独说明。



## 总结

以上只是初步体验了一下，更多关于关于influxdb 的其他特性，在后续文章中将一一介绍.

