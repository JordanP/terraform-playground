#!/usr/bin/env python3
import os

import requests
import yaml

me = os.path.dirname(os.path.realpath(__file__))

url = "https://raw.githubusercontent.com/poseidon/typhoon/master/addons/prometheus/rules.yaml"

resp = requests.get(url)
resp.raise_for_status()
resource = yaml.load(resp.content)

for name, content in resource["data"].items():
    with open(os.path.join(me, name), "w") as f:
        f.write(content)
