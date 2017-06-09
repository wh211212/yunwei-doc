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

try:
    import json
except ImportError:
    import simplejson as json

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
container_name = sys.argv[1]
service_name = sys.argv[2]

docker_bin = "/usr/bin/docker"

# Check if the service is running in contianer 
cmd = "sudo %s exec -i %s ps aux | grep -ci %s" %(docker_bin,container_name,service_name)

# Run the command
child = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

# Wait the command finish
child.wait()

# Get the error output
errors = child.stderr.read()

# If there are any errors, exit
if errors.strip(): 
    print error_run_cmd 
    exit(1)
else:
    # Get the number of service process 
    num = int(child.stdout.read())

    # if number of process is more than 0, then service is running.
    if num > 0:
        services = service_name 
    else:
        services = ""

    # Print to json type
    container = [{'{#SERVICENAME}':services}]
    print json.dumps({'data':container},sort_keys=True,indent=4,separators=(',',':'))
