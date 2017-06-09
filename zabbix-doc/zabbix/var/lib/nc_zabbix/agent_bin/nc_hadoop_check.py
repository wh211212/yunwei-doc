#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Twemproxy monitor script
##############################
# Contact:
#  angus.wang@chinanetcloud.com
##############################
# Requirements:
#  - Json module
##############################
# CHANGELOG
# May 27, 2015  MD: * Initial create

import sys
import os
import json
#import commands
#import StringIO
try:
    if sys.argv[1] == 'NameNode':
        HadoopItem=json.load(os.popen('curl http://localhost:50070/jmx 2>/dev/null'))
    elif sys.argv[1] == 'ResourceManager':
        HadoopItem=json.load(os.popen('curl http://localhost:8088/jmx 2>/dev/null'))
    else:
        print '-0.9902'
except ValueError:
    print '-0.9903'
else:
    for entry in HadoopItem['beans']:
        if sys.argv[2] in entry:
            print entry[sys.argv[2]]
            break
    else:
        print '-0.9902'
