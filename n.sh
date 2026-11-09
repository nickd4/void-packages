#!/bin/bash
./xbps-src -A x86_64-musl binary-bootstrap && \
./build.sh base-container-full && \
./build.sh linux-base && \
./build.sh linux-7.3
