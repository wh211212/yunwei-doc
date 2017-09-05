# tomcat8 

- org.apache.coyote.http11.Http11Processor.service Error parsing HTTP request header

- java.lang.IllegalArgumentException: Invalid character found in the request target. The valid characters are defined in RFC 7230 and RFC 3986

- [2017-08-18 10:54:50,375] [WARN] [org.springframework.jms.listener.DefaultMessageListenerContainer#0-1] [org.springframework.jms.listener.AbstractMessageListenerContainer] Execution of JMS message listener failed, and no ErrorHandler has been set.
java.lang.NoSuchMethodError: redis.clients.jedis.Jedis.psetex([BJ[B)Ljava/lang/String;

- Failed to create a session, as response has been committed. Unable to store SecurityContext


- Tomcat8启动报there was insufficient free space available after evicting expired cache entries - consider increasing the maximum size of the cache

tomcat 中context.xml 配置文件加入
<Resources cachingAllowed="true" cacheMaxSize="100000" />



# Tomcat启动/关闭时的几个问题

tomcat.util.scan.StandardJarScanFilter.jarsToSkip=*.jar


consider increasing the maximum size of the cache

<Resources
    cachingAllowed="false"
/>