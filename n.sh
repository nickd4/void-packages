#!/bin/bash

# to run mkrootfs.sh, dracut we need the following:

# note: the first xbps-src pkg command is run without -1 -N -n switches,
# allowing it to update the repositories and download needed host packages

./xbps-src -A x86_64-musl binary-bootstrap && \
./xbps-src -A x86_64-musl pkg base-container-full && \
./build.sh x86_64-musl base-container-full && \
./build.sh x86_64-musl binutils && \
./build.sh x86_64-musl dracut && \
./build.sh x86_64-musl linux-base && \
./build.sh x86_64-musl linux7.3 && \
./build.sh x86_64-musl zstd

# to run mklive.sh we also need the following, which takes time and adds
# a lot of bloat, for instance it compiles the un-needed linux6.12 package:

# note: it is not clear where binutils, dhclient, openresolv come from,
# they get installed as dependencies of: jq base-system linux7.3 linux-base
# perhaps because it installed jq from repositories and it is outdated?

# ./build.sh x86_64-musl jq
# ./build.sh x86_64-musl base-system
# ./build.sh x86_64-musl binutils
# ./build.sh x86_64-musl dhclient
# ./build.sh x86_64-musl openresolv
