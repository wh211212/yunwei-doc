# tomcat 监控

- 参考链接：https://wiki.apache.org/tomcat/FAQ/Monitoring

- 实验环境：

> Java Version 1.8.x + Tomcat Version: 8.x




Catalina:name=HttpRequest10,type=RequestProcessor,worker="http-nio2-8081"
Catalina:context=/aniu-nkm-task,host=localhost,type=Manager
java.lang:type=Runtime
java.lang:name=PS Scavenge,type=GarbageCollector
Catalina:context=/aniu-nkm-task,host=localhost,type=WebResourceRoot
Catalina:J2EEApplication=none,J2EEServer=none,WebModule=//localhost/aniu-nkm-task,j2eeType=Servlet,name=jsp
java.nio:name=mapped,type=BufferPool
org.apache.commons.pool2:name=pool1,type=GenericObjectPool
Catalina:host=localhost,name=AccessLogValve,type=Valve
java.lang:name=Compressed Class Space,type=MemoryPool
Catalina:context=/aniu-nkm-task,host=localhost,name=Cache,type=WebResourceRoot
java.util.logging:type=Logging
Catalina:J2EEApplication=none,J2EEServer=none,WebModule=//localhost/aniu-nkm-task,j2eeType=Filter,name=OpenSessionInViewFilter
Catalina:name=HttpRequest3,type=RequestProcessor,worker="http-nio2-8081"
Catalina:name=HttpRequest1,type=RequestProcessor,worker="http-nio2-8081"
Catalina:name="http-nio2-8081",type=GlobalRequestProcessor
java.lang:type=Compilation
org.apache.commons.pool2:name=pool2,type=GenericObjectPool
Catalina:type=Mapper
JMImplementation:type=MBeanServerDelegate
java.lang:type=ClassLoading
com.sun.management:type=HotSpotDiagnostic
Catalina:type=NamingResources
java.lang:name=CodeCacheManager,type=MemoryManager
Catalina:host=localhost,name=StandardHostValve,type=Valve
Catalina:name=HttpRequest6,type=RequestProcessor,worker="http-nio2-8081"
Catalina:realmPath=/realm0/realm0,type=Realm
Catalina:context=/aniu-nkm-task,host=localhost,type=ParallelWebappClassLoader
Catalina:type=Service
java.nio:name=direct,type=BufferPool
Catalina:J2EEApplication=none,J2EEServer=none,WebModule=//localhost/aniu-nkm-task,j2eeType=Servlet,name=springMvc
Catalina:context=/aniu-nkm-task,host=localhost,name=NonLoginAuthenticator,type=Valve
java.lang:name=PS MarkSweep,type=GarbageCollector
com.sun.management:type=DiagnosticCommand
Catalina:name=HttpRequest8,type=RequestProcessor,worker="http-nio2-8081"
Catalina:port=8081,type=Connector
java.lang:type=Memory
Catalina:type=MBeanFactory
java.lang:name=Metaspace,type=MemoryPool
Catalina:name=HttpRequest2,type=RequestProcessor,worker="http-nio2-8081"
java.lang:name=PS Old Gen,type=MemoryPool
Catalina:name=StandardEngineValve,type=Valve
java.lang:type=Threading
Catalina:J2EEApplication=none,J2EEServer=none,WebModule=//localhost/aniu-nkm-task,name=jsp,type=JspMonitor
Catalina:realmPath=/realm0,type=Realm
java.lang:name=PS Eden Space,type=MemoryPool
Catalina:name=tomcatThreadPool,type=Executor
Catalina:J2EEApplication=none,J2EEServer=none,WebModule=//localhost/aniu-nkm-task,j2eeType=Filter,name=Tomcat WebSocket (JSR356) Filter
Catalina:host=localhost,type=Deployer
Catalina:J2EEApplication=none,J2EEServer=none,WebModule=//localhost/aniu-nkm-task,j2eeType=Servlet,name=default
Catalina:class=org.apache.catalina.UserDatabase,name="UserDatabase",resourcetype=Global,type=Resource
Catalina:name="http-nio2-8081",type=ThreadPool
Catalina:J2EEApplication=none,J2EEServer=none,j2eeType=WebModule,name=//localhost/aniu-nkm-task
Catalina:name=HttpRequest4,type=RequestProcessor,worker="http-nio2-8081"
java.lang:name=PS Survivor Space,type=MemoryPool
Catalina:port=8081,type=ProtocolHandler
Catalina:context=/aniu-nkm-task,host=localhost,name=StandardContextValve,type=Valve
Catalina:context=/aniu-nkm-task,host=localhost,type=NamingResources
Catalina:type=Server
Users:database=UserDatabase,type=UserDatabase
Catalina:J2EEApplication=none,J2EEServer=none,WebModule=//localhost/aniu-nkm-task,j2eeType=Filter,name=characterEncodingFilter
java.lang:type=OperatingSystem
Catalina:type=StringCache
java.lang:name=Metaspace Manager,type=MemoryManager
Catalina:name=HttpRequest7,type=RequestProcessor,worker="http-nio2-8081"
java.lang:name=Code Cache,type=MemoryPool
Catalina:name=HttpRequest5,type=RequestProcessor,worker="http-nio2-8081"
Catalina:J2EEApplication=none,J2EEServer=none,WebModule=//localhost/aniu-nkm-task,j2eeType=Filter,name=springSecurityFilterChain
Catalina:name=HttpRequest9,type=RequestProcessor,worker="http-nio2-8081"
Catalina:host=localhost,name=ErrorReportValve,type=Valve
Catalina:host=localhost,type=Host
org.apache.commons.pool2:name=pool3,type=GenericObjectPool
Catalina:context=/aniu-nkm-task,host=localhost,type=Loader
Catalina:type=Engine
