# nexus官网

https://www.sonatype.com/

# nexus安装

https://www.sonatype.com/oss-thank-you-tar.gz

tar xvzf nexus-3.3.0-01-unix.tar.gz -C /opt

NEXUS_HOME="/opt/nexus"
run_as_user="nexus"

sudo ln -s $NEXUS_HOME/bin/nexus /etc/init.d/nexus

cd /etc/init.d
sudo chkconfig --add nexus
sudo chkconfig --levels 345 nexus on
sudo service nexus start

## nexus access
http://localhost:8081

default:
admin
admin123

## nexus proxy nginx



##  nexus errors

 Return code is: 401, ReasonPhrase: Unauthorized.

maven settings.xml add:

<servers>
  <server>
    <id>nexus</id>
    <username>admin</username>
    <password>admin123</password>
  </server>
</servers>


Return code is: 405, ReasonPhrase: PUT


#

<distributionManagement>
  <repository>
    <id>nexus</id>
    <name>Releases</name>
    <url>http://nexus.aniu.so/repository/maven-releases</url>
  </repository>
  <snapshotRepository>
    <id>nexus</id>
    <name>Snapshot</name>
    <url>http://nexus.aniu.so/repository/maven-snapshots</url>
  </snapshotRepository>
</distributionManagement>


change pom.xml by wanghui, change nexus address

	<distributionManagement>
		<repository>
			<id>releases</id>
			<url>http://192.168.0.14:8081/nexus/content/repositories/releases</url>
		</repository>
		<snapshotRepository>
			<id>snapshots</id>
			<url>http://192.168.0.14:8081/nexus/content/repositories/snapshots</url>
		</snapshotRepository>
	</distributionManagement>


	<repositories>
		<repository>
			<id>repo1-maven</id>
			<url>http://repo1.maven.org/maven2</url>
		</repository>
		<repository>
			<id>mvnrepository</id>
			<url>http://mvnrepository.com/artifact</url>
		</repository>
		<repository>
			<id>spring-releases</id>
			<url>https://repo.spring.io/libs-release</url>
		</repository>
	</repositories>
#
  	<repositories>
        <repository>
            <id>aliyun</id>
            <name>aliyunrepo</name>
            <url>http://maven.aliyun.com/nexus/content/groups/public</url>
        </repository>	    
		<repository>
			<id>repo1-maven</id>
			<url>http://repo1.maven.org/maven2</url>
		</repository>
		<repository>
			<id>mvnrepository</id>
			<url>http://mvnrepository.com/artifact</url>
		</repository>
		<repository>
			<id>spring-releases</id>
			<url>https://repo.spring.io/libs-release</url>
		</repository>
		<repository>
            <id>nexus</id>
            <name>aniu repo</name>
            <url>http://nexus.aniu.so/repository/maven-releases</url>
        </repository>
	</repositories>






  
