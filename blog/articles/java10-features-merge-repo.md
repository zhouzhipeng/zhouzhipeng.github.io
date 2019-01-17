# 抢先体验java10的新特性之jdk源码仓库统一


此特性为java10特性列表编号：`296 - jdk多个代码仓库将合并为一个综合仓库`

> 286: [Local-Variable Type Inference](http://openjdk.java.net/jeps/286)
> 296: [Consolidate the JDK Forest into a Single Repository](http://openjdk.java.net/jeps/296)
> 304: [Garbage-Collector Interface](http://openjdk.java.net/jeps/304)
> 307: [Parallel Full GC for G1](http://openjdk.java.net/jeps/307)
> 310: [Application Class-Data Sharing](http://openjdk.java.net/jeps/310)
> 312: [Thread-Local Handshakes](http://openjdk.java.net/jeps/312)
> 313: [Remove the Native-Header Generation Tool (javah)](http://openjdk.java.net/jeps/313)
> 314: [Additional Unicode Language-Tag Extensions](http://openjdk.java.net/jeps/314)
> 316: [Heap Allocation on Alternative Memory Devices](http://openjdk.java.net/jeps/316)
> 317: [Experimental Java-Based JIT Compiler](http://openjdk.java.net/jeps/317)
> 319: [Root Certificates](http://openjdk.java.net/jeps/319)
> 322: [Time-Based Release Versioning](http://openjdk.java.net/jeps/322)

在上一篇中介绍了特性286：[局部变量类型推断](https://blog.zhouzhipeng.com/java10-features-local-variable-infer.html) , 还没看过的小伙伴可以先看一下哦:)



因为这一特性主要是`jdk` 内部仓库优化，并没有涉及到编译器等特性。所以这里主要以翻译和解释为主，下面让我们一起先睹为快！



## 特性概括

> Combine the numerous repositories of the JDK forest into a single repository in order to simplify and streamline development.

为了简化开发流程，将`jdk`的数个代码仓库汇集到一个代码仓库中.



## 动机

多年来，JDK的完整代码库已被分解成多个代码仓库。在JDK 9中有八个仓库：root，corba，hotspot，jaxp，jaxws，jdk，langtools和nashorn。

虽然这种多仓库模式提供了一些优点，但它也有许多缺点，并且在源代码管理操作方面做得不好。特别是，不可能跨越相互依赖的变更集的仓库执行原子提交。



## 具体描述

为了解决上面这些问题，已经开发了一个综合仓库的原型。原型可在：

>  仓库： http://hg.openjdk.java.net/jdk10/consol-proto/

一些用于创建原型的支持转换脚本附加为unify.zip。

在原型仓库中，八个存储库已经使用自动转换脚本合并到一个仓库中，该脚本在每个文件级别上保留了历史记录，并且在用于标记JDK的一些变更。变更集注释和创建日期也被保留。

原型有另一个代码重组的水平。在合并后的仓库中，Java模块的代码通常组合在单个顶级src目录下。例如，今天在JDK综合仓库中就有基于模块的目录

```bash
$ROOT/jdk/src/java.base
...
$ROOT/langtools/src/java.compiler
...
```



在综合仓库中，代码组织形式如下：

```bash
$ROOT/src/java.base
$ROOT/src/java.compiler
...
```



因此，在代码仓库的根目录中，合并和src目录组合之后，将保留模块中源文件的相对路径。

测试目录组织形式发生如下变更：

从

```bash
$ROOT/jdk/test/Foo.java
$ROOT/langtools/test/Bar.java
```

转为

```bash
$ROOT/test/jdk/Foo.java
$ROOT/test/langtools/Bar.java
```



由于目前在做的仅仅是一个原型，并不是所有部分都完全完成，并且在一些地方需要调整兼容性和适当性。 HotSpot C / C ++源代码与模块化Java代码一起被移至共享src目录。

回归测试将与原型的当前状态一起运行，但jtreg配置文件的进一步整合是可能的，并且可能在将来完成。
