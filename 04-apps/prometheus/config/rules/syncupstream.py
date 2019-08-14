#!/usr/bin/env python3
import os

import requests
import yaml

me = os.path.dirname(os.path.realpath(__file__))

url = "https://raw.githubusercontent.com/poseidon/typhoon/68d8717924a16d8ea6306b1ef9a401fdb0020cd6/addons/prometheus/rules.yaml"

resp = requests.get(url)
resp.raise_for_status()
resource = yaml.load(resp.content)

for name, content in resource["data"].items():
    with open(os.path.join(me, name), "w") as f:
        f.write(content)
