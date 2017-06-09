#!/usr/bin/env python
# encoding: utf-8
#
import os
def disk():

  grains={}
  disk = os.statvfs("/")
  grains['disk'] = (disk.f_bsize * disk.f_blocks)/1024/1024/1024
  return grains
if __name__ == '__main__':
    print disk()
