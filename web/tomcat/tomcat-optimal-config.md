# Tomcat 8 优化配置使用

## Tomcat website： http://tomcat.apache.org/

- 下载最新版本（当前最新）

```
wget http://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-8/v8.5.16/bin/apache-tomcat-8.5.16.tar.gz
tar zxvf apache-tomcat-8.5.16.tar.gz && mv apache-tomcat-8.5.16 tomcat-8081

# 根据个人习惯设置
```

- 更改配置文件

<?xml version="1.0" encoding="UTF-8"?>
<Server port="8016" shutdown="SHUTDOWN">
  <Listener className="org.apache.catalina.startup.VersionLoggerListener" />
  <Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />
  <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
  <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />
  <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />

  <GlobalNamingResources>
    <Resource name="UserDatabase" auth="Container"
              type="org.apache.catalina.UserDatabase"
              description="User database that can be updated and saved"
              factory="org.apache.catalina.users.MemoryUserDatabaseFactory"
              pathname="conf/tomcat-users.xml" />
  </GlobalNamingResources>

  <Service name="Catalina">

        <Executor name="tomcatThreadPool" 
               namePrefix="catalina-exec-"
               maxThreads="500" 
               minSpareThreads="25"
               prestartminSpareThreads="true" 
               maxQueueSize="100"
               maxIdleTime="10000" />

    <Connector executor="tomcatThreadPool"
               port="8082" 
               protocol="org.apache.coyote.http11.Http11Nio2Protocol"
               connectionTimeout="20000"
               redirectPort="8443"
               maxHttpHeaderSize="8192"
               processorCache="1000"
               acceptCount="1000"
               acceptorThreadCount="8"
               URIEncoding="UTF-8"
               enableLookups="false"
               keepAliveTimeout="12000"
               maxKeepAliveRequests="65535"
               disableUploadTimeout="true"
               compression="on"
               compressionMinSize="4096"
               noCompressionUserAgents="gozilla, traviata"
               server="API SERVER"
               compressableMimeType="text/html,text/xml,text/javascript,text/css,text/plain,application/json,application/x-javascript"/>

    <Engine name="Catalina" defaultHost="localhost">

      <Realm className="org.apache.catalina.realm.LockOutRealm">
        <Realm className="org.apache.catalina.realm.UserDatabaseRealm"
               resourceName="UserDatabase"/>
      </Realm>

      <Host name="localhost"  appBase="webapps"
            unpackWARs="true" autoDeploy="true">

        <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
               prefix="localhost_access_log" suffix=".txt"
               pattern="%h %l %u %t &quot;%r&quot; %s %b %T" />

      </Host>
    </Engine>
  </Service>
</Server>
