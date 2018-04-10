#/bin/bash
#----------------
task_name=/data/scripts/spring-task.xml
portlist=(8082 8083)
function sync() {
  for port in  ${portlist[@]};
  do
  tomcat_port=tomcat-$port
  tomcat_home=/data/tomcats/${tomcat_port}
  \cp $task_name /data/tomcats/$tomcat_port/webapps/aniu-nkm-task/WEB-INF/classes/spring/spring-task.xml
  # restart tomcat
  ps -ef | grep $tomcat_port | grep -v grep | awk '{print $2}' | xargs kill -9
  /bin/bash $tomcat_home/bin/startup.sh
  done
}
# main funtion

function main () {
  main
        }
# call main
main