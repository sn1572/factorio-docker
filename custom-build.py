#!/usr/bin/env python3

import os
from build import (
    build_and_push,
    login,
)


def main(push_tags=True, multiarch=False):
    with open(os.path.join(os.path.dirname(__file__), "buildinfo.json")) as file_handle:
        builddata = json.load(file_handle)
    if push_tags:
        login()
    for version, buildinfo in sorted(builddata.items(), key=lambda item: item[0], reverse=True):
        sha256 = buildinfo["sha256"]
        tags = buildinfo["tags"]
        if 'latest' in tags:
            build_and_push(sha256, version, tags, push_tags, multiarch)
            break


if __name__ == '__main__':
    main()
