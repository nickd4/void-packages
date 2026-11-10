#!/bin/bash

# to run mkrootfs.sh, dracut we need the following:

./xbps-src -A x86_64-musl binary-bootstrap && \
./build.sh base-container-full && \
./build.sh binutils && \
./build.sh dracut && \
./build.sh linux-base && \
./build.sh linux7.3 && \
./build.sh zstd

# to run mklive.sh we also need the following, which takes time and adds
# a lot of bloat, for instance it compiles the un-needed linux6.12 package:

# note: it is not clear where binutils, dhclient, openresolv come from,
# they get installed as dependencies of: jq base-system linux7.3 linux-base
# perhaps because it installed jq from repositories and it is outdated?

# ./build.sh jq
# ./build.sh base-system
# ./build.sh binutils
# ./build.sh dhclient
# ./build.sh openresolv
