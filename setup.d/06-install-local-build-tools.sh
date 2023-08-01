#!/bin/bash

set -x
set -e

# Install local build tools

apt -y install build-essential autoconf autotools-dev python-is-python3 clangd
