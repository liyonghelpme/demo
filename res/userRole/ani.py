import os
f = open('userRole.json')
import json
con = f.read()
jc = json.loads(con)
#print jc['animation_data']
print len(jc['animation_data'])
pd = jc['animation_data'][0]
print len(pd['mov_data'])
for i in pd['mov_data']:
    print i['name']

