#!/usr/bin/python
##################################
# Zabbix ElasticSearch Monitoring script
#
# Info:
#  - Call ElasticSearch API to get status
##################################
# Contact:
#  tina.zhang@ChinaNetCloud.com
##################################
# ChangeLog:
#  20160615   TZ    initial creation
##################################

import os
import sys
import json
import urllib2
import time

zbx_req_data = sys.argv[1]

ttl = 300
es_default_port = "9200"
es_default_host = "localhost"

try:
    sys.argv[2]
except IndexError:
    api = "health"
else:
    api = sys.argv[2]

try:
    sys.argv[3]
except IndexError:
    es_port = es_default_port
else:
    es_port = sys.argv[3]

try:
    sys.argv[4]
except IndexError:
    es_host = es_default_host
else:
    es_host = sys.argv[4]

# Define different URL for different metrics
stats = {
    'cluster': 'http://%s:%s/_cluster/stats' % (es_host,es_port),
    'nodes'  : 'http://%s:%s/_nodes/_local/stats' % (es_host,es_port),
    'indices': 'http://%s:%s/_stats' % (es_host,es_port),
    'health' : 'http://%s:%s/_cluster/health' % (es_host,es_port)
}

# Get the status data and write to temp file
def get_cache(api):
    cache = '/var/lib/nc_zabbix/tmp/elastizabbix-{0}.json'.format(api)
    lock = '/var/lib/nc_zabbix/tmp/elastizabbix-{0}.lock'.format(api)
    jtime = os.path.exists(cache) and os.path.getmtime(cache) or 0
    if time.time() - jtime > ttl and not os.path.exists(lock):
        open(lock, 'a').close() 
        with open(cache, 'w') as f: f.write(urllib2.urlopen(stats[api]).read())
        os.remove(lock)
    ltime = os.path.exists(lock) and os.path.getmtime(lock) or None
    if ltime and time.time() - ltime > 300:
        os.remove(lock)
    return json.load(open(cache))

# Read data from temp file basd on given key parameter
def get_stat(api, stat):
    d = get_cache(api)
    keys = []
    for i in stat.split('.'):
        keys.append(i)
        key = '.'.join(keys)
        if key in d:
            d = d.get(key)
            keys = []
    return d

# Only get local elasticsearch node id
def get_node_id():
    for k,v in get_stat('nodes', 'nodes').iteritems():
        return k

if __name__ == '__main__':
    if api == 'nodes':
        zbx_req_data = 'nodes' + '.' + get_node_id() + '.' + zbx_req_data
    stat = get_stat(api, zbx_req_data)
    if isinstance(stat, dict):
        print '-0.9901'
    else:
        print stat
