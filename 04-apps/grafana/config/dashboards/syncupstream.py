#!/usr/bin/env python3
import os

import requests
import yaml

me = os.path.dirname(os.path.realpath(__file__))
urls = [
    "https://raw.githubusercontent.com/poseidon/typhoon/master/addons/grafana/dashboards-etcd.yaml",
    "https://raw.githubusercontent.com/poseidon/typhoon/68d8717924a16d8ea6306b1ef9a401fdb0020cd6/addons/grafana/dashboards-k8s-nodes.yaml",
    "https://raw.githubusercontent.com/poseidon/typhoon/68d8717924a16d8ea6306b1ef9a401fdb0020cd6/addons/grafana/dashboards-k8s-resources.yaml",
    "https://raw.githubusercontent.com/poseidon/typhoon/68d8717924a16d8ea6306b1ef9a401fdb0020cd6/addons/grafana/dashboards-k8s.yaml",
    "https://raw.githubusercontent.com/poseidon/typhoon/68d8717924a16d8ea6306b1ef9a401fdb0020cd6/addons/grafana/dashboards-prom.yaml",
    "https://raw.githubusercontent.com/poseidon/typhoon/master/addons/grafana/dashboards-nginx-ingress.yaml"
]

for url in urls:
    resp = requests.get(url)
    resp.raise_for_status()
    resource = yaml.load(resp.content)

    dir = url.split("/")[-1][:-len(".yaml")]
    os.makedirs(os.path.join(me, dir), exist_ok=True)
    for name, content in resource["data"].items():
        with open(os.path.join(me, dir, name), "w") as f:
            f.write(content)
