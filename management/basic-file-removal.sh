#!/bin/bash

cd ../
find . -name ".DS_Store" -exec rm -f {} \;

cd stable/interface/source/
find . -name "*.pro.user" -exec rm -f {} \;

if [ -d "interface-build-desktop" ]; then
    rm -R "interface-build-desktop"
fi