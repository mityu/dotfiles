cd $1
git fetch
if [ -n "$(git diff)" ]; then
    exit 0
fi
git merge FETCH_HEAD
make CONF_OPT_NLS=--disable-nls
make install
