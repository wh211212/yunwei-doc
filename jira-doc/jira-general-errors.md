# jira安装使用常见错误解决

- Caused by: sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target

> 故障原因是笔者更改了jira 的base url，更改前世http，更改后为https，导致jira自身去检测base url时候报错

- 解决办法： 将证书（笔者通过在线证书生成工具自己颁发的）拷贝到$JAVA_HOME/jre/lib/security目录下：默认安装目录为：/opt/atlassian/jira/jre/lib/security

jira.aniu.so.crt
jira.aniu.so.csr
jira.aniu.so.key

> 拷贝自己颁发的证书报错并未解决，有可能和证书不被认可有关。


##
