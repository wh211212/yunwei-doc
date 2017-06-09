#!/usr/bin/python
#coding: utf-8
def __virtual__():
   '''The name of the call'''
   return "local_return"
def returner(ret):
    f=open('/var/log/salt/local_returner.log','a+')
    f.write(str(ret)[1:-1]+'\n')
    f.close()
