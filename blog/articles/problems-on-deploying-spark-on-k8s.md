# 【未解决】在Kubernetes 上部署Spark遇到的一些问题？

## 简介
这是一篇学习spark的笔记类的文章，途中遇到了问题，先简单记录下来，问题虽然还没解决，但是后面解决了会持续更新下的。


## 正文

最近在学习spark，感觉阻力还是不少，听说最新的spark 2.3.0 可以直接跑在 kubernetes 集群上，于是便想试试。手里头刚好还有google的免费试用300美刀，快速创建一个k8s集群搞起！(不会弄的可以在评论区留言)

按照spark 官方文档： [https://spark.apache.org/docs/2.3.0/running-on-kubernetes.html](https://spark.apache.org/docs/2.3.0/running-on-kubernetes.html)

这里简要说明总结一下：

1.  下载spark文件
下载地址： [http://spark.apache.org/downloads.html](http://spark.apache.org/downloads.html)


2.  一行命令启动
```bash
bin/spark-submit \
    --master k8s://https://107.167.187.109\
    --deploy-mode cluster \
    --name spark-pi \
    --class org.apache.spark.examples.SparkPi \
    --conf spark.executor.instances=3 \
    --conf spark.kubernetes.container.image=zhouzhipeng/my-spark \
        local:///opt/spark/examples/jars/spark-examples_2.11-2.3.0.jar
```

*说明*
--master k8s://https://107.167.187.109  这个地址使用 `kubectl cluster-info ` 可以查看。

本来以为很简单的就能跑起来，但是上面的命令跑完后，一直卡在下面这个地方：

```bash
2018-05-28 14:38:56 INFO  Client:54 - Waiting for application spark-pi to finish...
```

查了很多资料都没解决，不知道是不是因为spark版本的问题，各位客官，有知道怎么解决的麻烦帮忙在评论区留个言，感谢！


