#!/bin/sh

# This batch scripts create symbolic links of the library files
# Library files containt version numbers, but the scripts calling them shall
# not containt version numbers. Therefore, symbolic links are used.

./WebUpdate-Symlink.py  --no-download $@
echo "Press key to exit"
read