#!/usr/bin/env python
# encoding: utf-8

def grains():
  local={}
  test={'key': 'value','name': 'deploy','project':'docker'}
  local['list'] = [1,2,3]
  local['string'] = test
  local['dict'] = test
  return local
