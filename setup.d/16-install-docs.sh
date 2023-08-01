#!/bin/bash

set -x
set -e

# Documentation

apt -y install python3-doc

# CPP Reference

$wget https://github.com/PeterFeicht/cppreference-doc/releases/download/v20220730/html-book-20220730.zip
mkdir -p /usr/share/doc/cppreference
unzip -o $cache/html-book-20220730.zip -d /usr/share/doc/cppreference
