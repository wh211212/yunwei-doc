#!/usr/bin/env python
##################################
# Zabbix Low Level Discovery monitoring script
#
# Info:
#  - Detect if the service is running in container via command "docker exec"
#  - Return the service name with json format
##################################
# Contact:
#  tina.zhang@chinanetcloud.com
##################################
# ChangeLog:
#  20160328    TZ    initial creation
##################################
VERSION=1.0

import os
import sys
import subprocess
import requests
import select
from cStringIO import StringIO

try:
    import json
except ImportError:
    import simplejson as json

PIPE = subprocess.PIPE
data = []
#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - items need to be of type "float" (allow negative + float)
#
error_bad_parameter = "-0.9901"
error_run_cmd = "-0.9902"

# Check if have correct number of arguments
if len(sys.argv) < 3:
    print error_bad_parameter
    exit(1) 

# Zabbix requested parameter
device_type = sys.argv[1]
container_name = sys.argv[2]

docker_bin = "/usr/bin/docker"

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

# Print the data to json format
def dump_json(data):

    print json.dumps({'data':data},sort_keys=True,indent=4,separators=(',',':'))    

# Check network interface of contianers
if device_type == "network":
    # Check the process ID of container is running
    cmd = "sudo docker inspect --format '{{ .State.Pid }}' %s" %(container_name)
    rcode, stdout, stderr = execute(cmd)
    # Exist if has any error when execute command
    if rcode != 0:
        print error_run_cmd
        exit(1)

    # Get the dev file according to PID 
    proc_file = '/proc/'+ stdout +'/net/dev'
    
    with open(proc_file) as f:
        for line in f:
           interface_name = line.split(':')
           if len(interface_name) >1:
              # Print to json type
              data += [{'{#CINTERFACE}':interface_name[0].strip()}]

    dump_json(data)
    
if device_type == "disk":

    # Check the container ID
    cmd = "sudo docker inspect --format '{{.Id}}' %s" %(container_name)
    rcode, stdout, stderr = execute(cmd)
    # Exist if has any error when execute command
    if rcode != 0:
        print error_run_cmd
        exit(1)

    # Get the disk list
    get_dev_cmd = "sudo lsblk | awk -F':' '/%s/{print $3}' | awk '{ print $1 }' | uniq" %(stdout)
    rcode, stdout, stderr = execute(get_dev_cmd)
    # Exist if has any error when execute command
    if rcode != 0:
        print error_run_cmd
        exit(1) 
    
    for l in stdout.split("\n"):
        if len(l) >0:
            # Print to json type
            disk_name = 'dm-' + l
            data += [{'{#CDISK}':disk_name}]

    dump_json(data)

if device_type == "filesystem":

    # Check the container ID
    cmd = "sudo docker exec -t %s df -h | grep '^/dev' | awk '{ print $6 }'" %(container_name)
    rcode, stdout, stderr = execute(cmd)
    # Exist if has any error when execute command
    if rcode != 0:
        print error_run_cmd
        exit(1)

    for filesystem in stdout.split("\n"):
        if len(filesystem) >0:
            # Print to json type
            data += [{'{#CFILESYSTEM}':filesystem.strip()}]

    dump_json(data)
