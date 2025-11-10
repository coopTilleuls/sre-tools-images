#!/usr/bin/python3
import os
import json
MIN_VERSION = 1.32
versions = os.getenv('KUBECTL_TAGS', '').split('\n')
our_current_tags = os.getenv('OUR_CURRENT_TAGS', '').split('\n') # tags in our repository
base_image= os.getenv('BASE_IMAGE' ,'')
ret = {}  # to store k:v  with for exemple  {"1.28": "v1.28.9" ...}
for v in versions:
    vsplit = v.split('.')
    tag = float(".".join([vsplit[0],vsplit[1]]).lstrip("v"))
    if  tag >= MIN_VERSION:
        image_tags =  ",".join([ ":".join([base_image, str(t)])  for t in [ v , v.strip('v'), tag]])
        ret[tag] = {'base': v, 'image_tags': image_tags }

# do not rebuild exiting image tag
todo = {k:v for k,v in ret.items()  if not v['base'] in our_current_tags}
print(json.dumps(todo))

