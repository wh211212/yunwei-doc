#!/usr/bin/env python

# nc_mongo_check - Check mong serverstatus values
# nc_mongo_check.py <key>
# AUTHOR : stefan berder <stefan.berder@chinanetcloud.com>
# VERSION : 1.0

# --
# Error codes
# -0.9901   the file from cron job does not exist
# -0.9903   the first argument of this sub script is empty
# -0.9907   key is wrong
# -0.9908   malformed json file
# -0.9909   can't import simplejson module

import sys, os
os.environ['PYTHON_EGG_CACHE'] = '/var/lib/nc_zabbix/tmp'

try:
    import json
except ImportError:
    try:
        import simplejson as json
    except ImportError:
        print "-0.9909"
        sys.exit(1)

serverstatus = "/var/lib/nc_zabbix/tmp/mongodb.status"

if not os.path.isfile(serverstatus):
    print "-0.9901"
    sys.exit(1)

# --
# getjson
def getjson(file):
    fd = open(file)
    # remove two first lines to clean chell messages
    fd.readline() # MongoDB shell version: 1.6.4
    fd.readline() # connecting to: admin
    try:
        data = json.load(fd)
    except ValueError:
        print "-0.9908"
        sys.exit(1)
    return data

# check if the key was provided
if len(sys.argv) < 2:
    print "-0.9903"
    sys.exit(1)

key = sys.argv[1]

data = getjson(serverstatus)

# Handle globalLock.ratio
if key == 'globalLock.ratio':
    globalLock = data.get('globalLock', {})
    totalTime = globalLock.get('totalTime', False)
    lockTime = str(globalLock.get('lockTime', False))
    if not totalTime or not lockTime:
        # Something wrong .. should be an issue
        print "-0.9907"
        sys.exit(1)
    if lockTime.startswith('NumberLong(') and lockTime.endswith(')'):
        lockTime = lockTime.lstrip('NumberLong(').rstrip(')')
    # Return the ratio
    data = float(lockTime) / float(totalTime)
else:
    for item in key.split('.'):
        if data.has_key(item):
            data = data[item]
        else:
            print "-0.9907"
            sys.exit(1)

print data
