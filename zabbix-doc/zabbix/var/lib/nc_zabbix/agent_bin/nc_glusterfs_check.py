#!/usr/bin/env python
#
#create by MD 20140423
import os
import sys
import re
import commands

GLUSTER_BIN='sudo /usr/sbin/gluster'
MOUNT_INFO="sudo cat /proc/mounts"

def peer_status(server):
    '''
    Now monitor the status of the trusted storage pool
    '''
    code, output = commands.getstatusoutput(GLUSTER_BIN + " peer status")
    if server == 'status':
        m = re.search(r'(\(Connected\))', output)
        if m:
            print "OK"
            return True

    if code == 0:
        for line in output.splitlines():
            m = re.search(r"Hostname:\s+"+server, line)
            if m:
                print "Up"
                return True
    print "Down"
    return False

def volume_info(chkitem):
    '''
    Now let's  check the status of the volume
    '''
    code, output = commands.getstatusoutput(GLUSTER_BIN + " volume info")
    if code == 0:
        for line in output.splitlines():
            m = re.search(chkitem + r":\s*(\S*)", line)
            if m:
                print "Started"
                return True
    print "-0.9902"
    return False

def mount_info(chkitem):
    """
    Now let's check mount info,make sure glusterfs already mounted
    """
    code, output = commands.getstatusoutput(MOUNT_INFO)
    if code == 0:
        m = re.search(chkitem, output)
        if m:
            print "Ok"
            return True

def main():
    if len(sys.argv) != 3:
        print "-0.9901"
        sys.exit(0)
    if sys.argv[1] == 'peer':
        peer_status(sys.argv[2])
    elif sys.argv[1] == 'volume':
        volume_info(sys.argv[2])
    elif sys.argv[1] == 'mount':
        mount_info(sys.argv[2])
    else:
        print "-0.9903"
        return False

if __name__ == '__main__':
    main()
