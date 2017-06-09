#!/usr/bin/python
##################################
# Zabbix RabbitMQ Monitoring script
#
# Info:
#  - Enable RabbitMQ plugin rabbitmq_management
#  - Call RabbitMQ API to get status
##################################
# Contact:
#  tina.zhang@ChinaNetCloud.com
##################################
# ChangeLog:
#  20160622   TZ    initial creation
##################################

import os
import sys
import json
import urllib2
import time

zbx_req_data = sys.argv[1]

ttl = 300
mq_default_port = "15672"
mq_default_host = "localhost"
mq_user = "guest"
mq_passwd = "guest"

try:
    sys.argv[2]
except IndexError:
    api = "overview"
else:
    api = sys.argv[2]

try:
    sys.argv[3]
except IndexError:
    mq_port = mq_default_port
else:
    mq_port = sys.argv[3]

try:
    sys.argv[4]
except IndexError:
    mq_host = mq_default_host
else:
    mq_host = sys.argv[4]

# Get the status data and write to temp file
def get_cache(api, node_name=''):
    cache = '/var/lib/nc_zabbix/tmp/rabbitmqzabbix-{0}.json'.format(api)
    lock = '/var/lib/nc_zabbix/tmp/rabbitmqzabbix-{0}.lock'.format(api)
    url = 'http://{0}:{1}/api/{2}/{3}'.format(mq_host, mq_port, api, node_name)
    password_mgr = urllib2.HTTPPasswordMgrWithDefaultRealm()
    password_mgr.add_password(None, url, mq_user, mq_passwd)
    handler = urllib2.HTTPBasicAuthHandler(password_mgr)
    jtime = os.path.exists(cache) and os.path.getmtime(cache) or 0
    if time.time() - jtime > ttl and not os.path.exists(lock):
        open(lock, 'a').close() 
        with open(cache, 'w') as f: f.write(urllib2.build_opener(handler).open(url).read())
        os.remove(lock)
    ltime = os.path.exists(lock) and os.path.getmtime(lock) or None
    if ltime and time.time() - ltime > 300:
        os.remove(lock)
    return json.load(open(cache))

# Read data from temp file basd on given key parameter
def get_stat(api, stat, node_name=''):
    d = get_cache(api,node_name)
    keys = []
    for i in stat.split('.'):
        keys.append(i)
        key = '.'.join(keys)
        if key in d:
            d = d.get(key,{})
            keys = []
    return d


if __name__ == '__main__':

    if api == "nodes":
        # Only get local node status
        node_name = get_stat('overview', 'node')
        stat = get_stat(api, zbx_req_data, node_name)
    else:
        stat = get_stat(api, zbx_req_data)

    if isinstance(stat, dict):
        print '-0.9901'
    else:
        print stat
