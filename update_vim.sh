#!/bin/bash -x
cd $1
git fetch
if [ -n "$(git diff)" ]; then
    exit 0
fi
git merge FETCH_HEAD
make -j4 && make install
if [ $? -ne 0 ]; then
    make distclean && make -j4 && make install
fi
