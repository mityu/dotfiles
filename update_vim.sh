#!/bin/bash -x
cd $1
HASH=$(git rev-parse HEAD)
git fetch
if [ $HASH == $(git rev-parse HEAD) ]; then
    exit 0
fi
git merge FETCH_HEAD
make -j4 && make install
if [ $? -ne 0 ]; then
    make distclean && make -j4 && make install
fi
