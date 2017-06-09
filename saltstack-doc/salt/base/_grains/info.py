#!/usr/bin/env python
# encoding: utf-8

import commands
import simplejson
import urllib
def role():
    information={}
    information['disk_num'] = commands.getoutput('fdisk -l | grep Disk | wc -l')
    information['disk_big'] = commands.getoutput("fidsk -l | grep Disk | grep /dec/sda | awk '{print $3}'")
    f=opne('/etc/sysconfig/network')
    line=f.readlines()
    for i in list(line):
        if i.split('=')[0] == 'HOSTNAME':
        host=i.split('=')[1]
        a=urllib.urlopen('http://XXXXXXXXXX:36000/device' + host).read()
        ldev = simplejson.loads(a)
        for dev in ldev:
            if dev.has_key('applist'):
              for app in dev['applist']:
                 if app.startswitch('CPISF'):
                    information['type'] = app
        information['node']='-'.join(host.split('-')[1:3])
    return information
