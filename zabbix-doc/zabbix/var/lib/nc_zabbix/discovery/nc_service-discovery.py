#!/usr/bin/env python
##################################
# Zabbix Low Level Discovery script
#
# Info:
#  - Auto Discovery Services listening Port
##################################
# Contact:
#  tina.zhang@ChinaNetCloud.com
##################################
# ChangeLog:
#  20160421   TZ    initial creation
#  20160708   TZ    add mysql discovery
#  20160906   TZ    add haproxy discovery
##################################

import os
import sys
import subprocess
import select
from cStringIO import StringIO

try:
    import json
except ImportError:
    import simplejson as json

service_name = sys.argv[1]

if len(sys.argv) > 2:
    zbx_req_data = sys.argv[2]

PIPE = subprocess.PIPE

error_run_cmd = "-0.9901"
error_dump_json = "-0.9902"
error_wrong_paras = "-0.9903"

class LineReader(object):
    def __init__(self, fd):
        self._fd = fd
        self._buf = ''

    def fileno(self):
        return self._fd

    def readlines(self):
        data = os.read(self._fd, 4096)
        if not data:
            # EOF
            return None
        self._buf += data
        if '\n' not in data:
            return []
        tmp = self._buf.split('\n')
        lines, self._buf = tmp[:-1], tmp[-1]
        return lines

def execute(params, display=False):
    '''
    Execute a command, Popen wrapper
    '''
    if type(params) in (str, unicode):
        params = [params]

    if type(params) != list:
        raise Exception('Invalid params type, need to be string or a list')

    try:
        p = subprocess.Popen(params, stdout=PIPE, stderr=PIPE, shell=True)
    except OSError as e:
        return 1, '', e

    proc_stdout = LineReader(p.stdout.fileno())
    proc_stderr = LineReader(p.stderr.fileno())

    readable = [proc_stdout, proc_stderr]

    stdout = []
    stderr = []
    results = [stdout, stderr]

    while readable:
        ready = select.select(readable, [], [], 10.0)[0]
        if not ready:
            continue
        for idx, stream in enumerate(ready):
            lines = stream.readlines()
            if lines is None:
                # got EOF on this stream
                readable.remove(stream)
                continue
            results[idx].extend(lines)
            if display:
                for line in lines:
                    if idx == 0:
                        sys.stdout.write(line +'\n')
                    else:
                        sys.stderr.write(line +'\n')

    # Wait until completion of the process
    while p.returncode == None:
        p.poll()

    # return a tuple (code, stdout, stderr)
    return p.returncode, '\n'.join(results[0]), '\n'.join(results[1])

def jmx_discovery():
    # Get Java bin
    get_java_bin = "ps -e -o command | grep -v grep | grep -E 'java.*jmxremote.port' | awk '{ print $1 }' | head -n1"
    rcode, stdout, stderr = execute(get_java_bin)
    java_bin = stdout

    # Get the JMX port from running java/tomcat processes. 
    cmd = "ps -e -o command | grep %s | grep 'jmxremote.port' | grep -v grep | awk -F'jmxremote.port=' '{ print $2 }' | awk '{ print $1 }'" %(service_name)
   
    # java/tomcat both use the JMX name.
    macro = 'JMXPORT'
        
    # Discovery object name or Description or Description set on Mean Name.
    if len(sys.argv) > 2:
        zbx_req_data = sys.argv[2].replace("][",",")
        ports = []
        rcode, stdout, stderr = execute(cmd)
        for i in stdout.split('\n'):
            cmd_jmx = "%s -jar /var/lib/nc_zabbix/bin/jmx_discovery.jar %s 127.0.0.1:%s zabbix_check zabbix_check" %(java_bin, zbx_req_data,i)
            rcode, stdout, stderr = execute(cmd_jmx)
            if rcode !=0:
                continue
            stdout = stdout.replace("\\","\\\\\\")
            ports_tmp = json.loads(stdout)['data']
            ports += ports_tmp
        print json.dumps({'data':ports},sort_keys=True,indent=4,separators=(',',':'))
        exit(0)

    run(cmd,macro)

def disk_discovery():
    cmd = "iostat -d | awk '{ print $1 }' | sed '1,3d' "
    macro = 'DISKNAME'
    run(cmd,macro)

def mysqld_discovery():

    if len(sys.argv) >= 3 and zbx_req_data == 'slave': 
        cmd = "sudo ss -4ntlp | awk -F: '/%s/&&/LISTEN/{print $2}' | awk '{print $1}' " %(service_name)
        rcode, stdout, stderr = execute(cmd)
        
        macro_name = '{' + '#' + service_name.upper() + 'PORT' + '}'
        ports = []

        for port in stdout.split('\n'):
            mysql_conn = "mysql --defaults-extra-file=/var/lib/nc_zabbix/conf/mysql_credentials -P %s" %(port)
            cmd = "echo 'show slave status \G' | %s | awk -F': ' '/Slave_(IO|SQL)_Running:/{print $2 }' | wc -l" %(mysql_conn)
            rcode, stdout, stderr = execute(cmd)
            if int(stdout) > 0:
                ports += [{macro_name:port}]
                continue
        print json.dumps({'data':ports},sort_keys=True,indent=4,separators=(',',':'))
        exit(0)
            
    elif len(sys.argv) == 2:
       default_discovery()
    else:
        print error_wrong_paras 

def haproxy_discovery():

    # Discovery HaProxy list via socat
    cmd = "echo \"show stat\" | sudo socat unix-connect:/tmp/haproxy stdio"
    rcode, stdout, stderr = execute(cmd)

    # Exist if has any error when execute command
    if rcode != 0:
        print error_run_cmd
        exit(1)

    dump_data = []
    macro_name = macro_name = '{' + '#' + zbx_req_data.upper() + '}'

    for line in stdout.split('\n'):
        line_ex = line.split(',')
        if(len(line_ex) > 1):
            if line_ex[1] == 'FRONTEND' and zbx_req_data == 'frontend':
                dump_data += [{macro_name:line_ex[0]}]
            elif line_ex[1] == 'BACKEND' and zbx_req_data == 'backend':
                dump_data += [{macro_name:line_ex[0]}]
            elif line_ex[1] != 'svname' and line_ex[1] != 'FRONTEND' and line_ex[1] != 'BACKEND' and zbx_req_data == 'server':
                dump_data += [{macro_name:line_ex[1],'{'+'#'+'BACKEND'+'}':line_ex[0]}]
    print json.dumps({'data':dump_data},sort_keys=True,indent=4,separators=(',',':'))


def default_discovery():
    # Discovery service via ss
    cmd = "sudo ss -4ntlp | awk -F: '/%s/&&/LISTEN/{print $2}' | awk '{print $1}' " %(service_name)
    run(cmd)

## Print to json type
def run(cmd, macro=service_name + 'PORT'):

    rcode, stdout, stderr = execute(cmd)

    # Exist if has any error when execute command
    if rcode != 0:
        print error_run_cmd
        exit(1)

    macro_name = '{' + '#' + macro.upper() + '}'
    ports = []

    for port in str(stdout).split('\n'):
            if len(port) > 0:
                ports += [{macro_name:port}]

    try:  
        print json.dumps({'data':ports},sort_keys=True,indent=4,separators=(',',':'))
    except TypeError:
        print error_dump_json 

if __name__ == '__main__':    
     
    if service_name == 'java' or service_name == 'tomcat':
    	jmx_discovery() 
    elif service_name == "disk":
        disk_discovery()
    elif service_name == "mysqld":
        mysqld_discovery()
    elif service_name == "haproxy":
        haproxy_discovery()
    else:
        default_discovery()

