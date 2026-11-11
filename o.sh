#!/bin/bash

# to run mkrootfs.sh, dracut we need the following:

# note: the first xbps-src pkg command is run without -1 -N -n switches,
# allowing it to update the repositories and download needed host packages

./xbps-src -A x86_64-musl -a armv7hf-musl binary-bootstrap && \
./xbps-src -A x86_64-musl -a armv7hf-musl pkg base-container-full && \
./build.sh armv7hf-musl base-container-full && \
./build.sh armv7hf-musl binutils && \
./build.sh armv7hf-musl dracut && \
./build.sh armv7hf-musl linux-base && \
./build.sh armv7hf-musl linux7.3 && \
./build.sh armv7hf-musl zstd
