<p>write on : 2021.12.1</p>

# CodingAir云服务开发平台-EMap使用技巧

> CodingAir云服务开发平台上线啦！地址：[http://codingair.com](http://codingair.com)
>
> 欢迎大家免费试用提意见哦！（测试账号：823143047@qq.com （我的邮箱）  密码：123456 , 也可以自行注册哦！)


### 介绍

EMap 是 HashMap的子类，为的是更方便的操作map。扩充map的特性，将map, list, string 三者结合一起，基本上可代表所有的类型。



```java

		/*
         * 请求数据获取示例
         */

        //1.【推荐！！】请求体为 jsonobject 或form 格式 (query上的参数也可以直接用input.get获取到)
        //假设请求体json形式为: {"age":10,"name":"abc","subObj":{"prop":"val"}}
        int age = input.get("age");
        String name = input.get("name");
        EMap subObj = input.get("subObj");
        String prop=input.jsonPath("$.subObj.prop"); //按jsonpath路径获取，更多json-path相关参考:http://goessner.net/articles/JsonPath/, https://blog.csdn.net/koflance/article/details/63262484

        //2.请求体为json array形式，考虑到特殊性，单独提供方法获取
        List list = input.list();

        //2.请求体为 raw string原生格式 (query上的参数可以直接用input.get获取到)
        String rawBody = input.string();


        /*
         * 响应体构造示例
         */

        //1.【推荐！！】响应体为json object
        //可以这样构造一个map
        EMap resp=EMap.mapOf(
                "abc", "ddd",
                "sddd", "sdf"
        );

        //可以这样构造一个map
        EMap resp2=new EMap(jsonObj(S(
         /*
            {
                "aaa":"bbb",
                "ccc":{
                    "ddd":"eeee"
                }
            }
         */
        )));

        //还可以这样
        EMap resp3=new EMap()
                .put("abc", "dddd")
                .put("ddd", "sdf");



        //2. 响应体为json array
        EMap resp4=new EMap().list(new ArrayList());

        //3. 响应体为raw string
        EMap resp5=new EMap().string("abcdefg");


```


<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/social-share.js/1.0.16/css/share.min.css">
<div class="social-share"></div>
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/social-share.js/1.0.16/js/social-share.min.js"></script>