#!/bin/bash -x
cd $1
HASH=$(git rev-parse HEAD)
git pull
if [ $HASH == $(git rev-parse HEAD) ]; then
    exit 0
fi
make -j4 && make install
if [ $? -ne 0 ]; then
    make distclean && make -j4 && make install
fi
