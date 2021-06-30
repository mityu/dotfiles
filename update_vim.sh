cd $1
git fetch
if [ -n "$(git diff)" ]; then
    exit 0
fi
git merge FETCH_HEAD
make && make install
if [ $? -neq 0 ]; then
    make distclean && make && make install
fi
