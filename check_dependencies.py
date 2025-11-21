import requests

name='pyspark'
version=''   # if blank then dependencies check will happen for latest version


if version=='':
    url = f'https://pypi.org/pypi/{name}/json'   #lastest
else:
    url = f'https://pypi.org/pypi/{name}/{version}/json'    #specific_version

json = requests.get(url).json()
print(json['info']['requires_dist'])
print(json['info']['requires_python'])