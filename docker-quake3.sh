#!/bin/sh
arch="$(uname -m)"
if [ "$arch" = "x86_64" ]; then
    /home/ioq3srv/ioq3ded.x86_64 +exec server.cfg
elif [ "$arch" = "aarch64" ]; then
    /home/ioq3srv/ioq3ded.arm64 +exec server.cfg
fi