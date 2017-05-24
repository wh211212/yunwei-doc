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
