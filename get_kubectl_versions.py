#!/usr/bin/python3
import os
import json
MIN_VERSION = 1.32
versions = os.getenv('ALL_VERSIONS').split('\n')
ret = {}
ret2 = []
for v in versions:
    vsplit = v.split('.')
    short_version = float(".".join([vsplit[0],vsplit[1]]).lstrip("v"))
    if  short_version >= MIN_VERSION:
        ret[vsplit[1]] = v
        ret2.append(v)
print(json.dumps(ret2))
