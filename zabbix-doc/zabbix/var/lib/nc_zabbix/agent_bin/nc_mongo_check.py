#!/usr/bin/env python
#
# nc_mongo_check - Check mong serverstatus values
# nc_mongo_check.py <key>
# AUTHOR : stefan berder <stefan.berder@chinanetcloud.com>
# VERSION : 1.1
# 
# Changelog:
# 2012/03/21    AS    Revamped. Merge everything in one single script
#
# -0.9905    mongo bin not found
# -0.9906   the first argument of this script is empty
# -0.9907   key is wrong
# -0.9908   malformed json file
# -0.9909   can't import simplejson module
#
# Notes:
# 1. Module simplejson is required for this script. Installation: yum install python-simplejson 
# 2. The value should be quoted, like key = "value", NOT key = value !

import os
import sys
import time
import stat

os.environ["PYTHON_EGG_CACHE"] = "/var/lib/nc_zabbix/tmp/";

mongo_bin="/usr/bin/mongo"
port="27017"
username = ""
password = ""

now=time.time()
zabbix_req_data=sys.argv[1]
status_file='/var/lib/nc_zabbix/tmp/mongodb_new.tmp'

# need one argument
if len(sys.argv) < 2:
    print "-0.9906"
    sys.exit(1)

# try import simplejson module
try:
    import simplejson
except ImportError:
    print "-0.9909"
    sys.exit(1)

if not os.path.isfile(mongo_bin):
    print "-0.9905"
    sys.exit(1)

# Query data from mongodb status file 
def query_data(tmp_file):
    fd = open(tmp_file)
    try:
        data = simplejson.load(fd)
    except Exception,e:
        print "-0.9908"
        print e
        sys.exit(1)
    
    for item in zabbix_req_data.split('.'):
        if data.has_key(item):
            data = data[item]
        else:
            print "-0.9907"
            sys.exit(1)
    
    if str(str(data).find("e-")) != "-1":
        print '%.7f' % data
    else:
        print data

# Generate and parse mongodb status file
def status_generate(file,key):
    f = open(file, 'w')
    cmd="echo 'db.serverStatus()' | %s --port %s -u %s -p%s" %(mongo_bin,port,username,password)
    tmp =os.popen(cmd).readlines();
    if str(tmp[3].find('{')) != "-1":
        del tmp[0:3]
    else:
        del tmp[0:2]
    del tmp[-1]
    for i in tmp:
            # fix json format
            if str(i.find("ISODate")) != "-1":
                i=i.replace('ISODate("','"ISODate(')
                i=i.replace('")',')"')
            if str(i.find("NumberLong")) != "-1":
                i=i.replace('NumberLong("','')
                i=i.replace('")','')
            f.write(i)
    f.close()
    query_data(status_file)

# Use current status file without connecting to mongodb repeatly
if not os.path.isfile(status_file):
    status_generate(status_file,zabbix_req_data)
else:
    last_mtime=os.stat(status_file).st_mtime
    if now - last_mtime > 60:
        status_generate(status_file,zabbix_req_data)
    else:
        query_data(status_file)

sys.exit(0)
