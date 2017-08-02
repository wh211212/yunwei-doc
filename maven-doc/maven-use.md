#  maven website
https://maven.apache.org/index.html

# 本地将第三方JAR部署到远程存储库（nexus）

mvn deploy:deploy-file -DgroupId=gexin-rp-sdk \
                       -DartifactId=base \
                       -Dversion=2.0.0.3 \
                       -Dpackaging=jar \
                       -Dfile=E:/jar/base-2.0.0.3.jar \  # 本地jar包位置
                       -DrepositoryId=nexus \
                       -DgeneratePom=false \
                       -Durl=http://nexus.aniu.so/repository/maven-releases/

mvn deploy:deploy-file -DgroupId=cmbpay -DartifactId=cmbb2b -Dversion=1.0 -Dpackaging=jar -Dfile=D:/cmbB2B.jar -DrepositoryId=nexus -DgeneratePom=false -Durl=dav:http://nexus.aniu.so/repository/maven-central/                       

# mvn 打包优化


## 编译优化
设置java运行内存：-Xms2G -Xmx4G
设置maven运行内存：-Xms2G -Xmx4G #防止内存溢出
增加跳过测试代码的编译命令： -Dmaven.test.skip=true
指明多线程进行编译：-Dmaven.compile.fork=true
增加CPU核心参数：-T 2C
-pl project-module1,project-module2 # 针对父子项目指定子项目部署
#
mvn clean deploy -B -e -U -Dmaven.test.skip=true -Dmaven.compile.fork=true -T 4C -am -Ponline

