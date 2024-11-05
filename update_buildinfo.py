#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov  4 20:31:26 2024

@author: sn157
"""


import urllib.request
import json
import os


BUILD_FILE_URL = ("https://raw.githubusercontent.com/factoriotools"
                  "/factorio-docker/refs/heads/master/buildinfo.json")


def ver_str_to_tuple(in_string):
    return tuple(list(map(int, in_string.split('.'))))


def fetch_build_json():
    with urllib.request.urlopen(BUILD_FILE_URL) as url:
        data = json.load(url)
    return data


def get_latest_build(data):
    relabeled_data = {}
    for key, val in data.items():
        relabeled_data[ver_str_to_tuple(key)] = val
    data = list(relabeled_data.items())
    ''' At this point, data is a list with entries that looks like:
        ((0, 12, 35), {'sha256': 'ab9...edd', 'tags': ['0.12.35', '0.12']})
    '''
    data = sorted(data, key = lambda x: x[0])
    ''' Since the list is sorted in increasing order by version,
        the most recent build is at the end.
    '''
    latest = data[-1]
    return latest


def write_template(latest):
    this_dir = os.path.dirname(__file__)
    build_file = os.path.join(this_dir, "buildinfo.json")
    major, minor, rev = latest[0]
    ver_str = f"{major}.{minor}.{rev}"
    data = {"sha256": latest[1]['sha256'],
            "tags": ["stable"]}
    template = {ver_str: data}
    with open(build_file, 'w') as f:
        f.write(json.dumps(template))


def main():
    data = fetch_build_json()
    latest = get_latest_build(data)
    write_template(latest)


if __name__ == '__main__':
    data = main()