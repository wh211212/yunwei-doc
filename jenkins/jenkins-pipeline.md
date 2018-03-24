# Jenkins + Pipeline 构建流水线发布

- 利用Jenkins的Pipeline配置发布流水线

> 参考： https://jenkins.io/doc/pipeline/tour/deployment/

![pipeline](http://img.blog.csdn.net/20170822162946271?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

> 新建一个名为pipeline-loop的 pipeline项目，然后配置，关键配置如下：

- 生成pipeline可以用的git连接（通过此链接，从私有gitlab拉取代码）

> Pipeline生成： https://jenkins.aniu.so/view/Pipeline/job/pipeline-loop/pipeline-syntax/

![pipeline-syntax](http://img.blog.csdn.net/20170822163222136?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

> 生成的pipeline代码如下，后面配置会用到： 

```
checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '500378f5-a6e4-4255-984e-61537fe0e455', url: 'git@gitlab.aniu.so:aniu-yunwei/game-of-life.git']]])
```

- 配置pipeline-loop项目

```
pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                echo 'Checkout'
                checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '500378f5-a6e4-4255-984e-61537fe0e455', url: 'git@gitlab.aniu.so:aniu-yunwei/game-of-life.git']]])
            }
        }        
        stage('Build') {
            steps {
                echo 'Building'
                sh 'mvn clean install' # 可以用自己的 mvn clean deploy + 参数替代
            }
        }
        stage('Test') {
            steps {
                echo 'Testing'
                sh 'mvn clean verify sonar:sonar' # 此处可以使用mvn test替代，笔者这步是检测代码的质量同步到自己的代码质量检测平台。
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying'
                sh 'mvn clean deploy'  # 此处调用脚本或者ansible、saltstak，部署到远程
            }
        }
    }
}
```
> 配置完成保存，然后build此项目，查看结果如下：

![pipeline-test](http://img.blog.csdn.net/20170822163550280?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2gyMTEyMTI=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)



