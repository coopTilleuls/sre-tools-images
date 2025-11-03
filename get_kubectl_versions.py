#!/usr/bin/python3
import os
import json
MIN_VERSION = 1.32
versions = os.getenv('ALL_VERSIONS').split('\n')
ret = {}
ret2 = []
for v in versions:
    vsplit = v.split('.')
    tag = float(".".join([vsplit[0],vsplit[1]]).lstrip("v"))
    if  tag >= MIN_VERSION:
        ret[tag] = v
print(json.dumps({ 
                  "tags" : [ str(t) for t in list(ret.keys())  ],
              "versions": ret
      }))
    
