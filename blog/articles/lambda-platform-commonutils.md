# CodingAir云服务开发平台-CommonUtils

> CodingAir云服务开发平台上线啦！地址：[http://codingair.com](http://codingair.com)
>
> 欢迎大家免费试用提意见哦！（测试账号：823143047@qq.com （我的邮箱）  密码：123456 , 也可以自行注册哦！)




## 说明
一些平台自创的和比较常用的工具方法都会放在这个类中

```java

/**
 * 通用工具类
 * User: zhouzhipeng
 * Date: 2018/7/29:22:26
 */
public class CommonUtils {

	/**
     * 多行字符串
     * 入参括号中传入，使用 /* ....* /  形式注释
     *
     * @return
     */
    public static String S();

		/**
     * sql操作
     * @param sqlTemplate
     * @param contexts
     * @param <T>
     * @return
     */
    public static <T> T sql(String sqlTemplate, Map<String, Object>... contexts) ;


		 /**
     * sql操作
     *
     * @param <T>
     * @param sqlTemplate
     * @return
     */
    public static <T> T sql(String sqlTemplate);


		/**
     * 把json格式的字符串转为 fastjson的 json对象
     *
     * @param strTemplate json字符串
     * @param context 模板上下文参数
     * @return fastjson的 json对象
     */
    public static JSONObject jsonObj(String strTemplate, HashMap<String, Object> context)


		/**
     * 把json格式的字符串转为 fastjson的 json对象
     *
     * @param jsonStr json字符串
     * @return fastjson的 json对象
     */
    public static JSONObject jsonObj(String jsonStr)


	 /**
     * json path 查询
     *
     * @param jsonStr
     * @return
     */
    public static <T> T jsonPath(String jsonStr, String path)


		/**
     * base64编码
     * @param src 原文
     * @return 密文
     */
    public static String base64Encode(String src)


		/**
     * base64解码
     * @param base64Str 密文
     * @return 原文
     */
    public static String base64Decode(String base64Str)


		/**
     * base64解码
     * @param base64Str 密文
     * @return 原文的字节数组
     */
    public static byte[] base64DecodeBytes(String base64Str)


		 /**
     * 设置缓存值
     * @param name
     * @param value
     * @param ttl
     */
    public static void set(String name, String value, long ttl)


		/**
     * 查询缓存值
     * @param name
     * @return
     */
    public static String get(String name)


}



```
