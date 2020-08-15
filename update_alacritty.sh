cd $1
git fetch
if [ -n "$(git diff)" ]; then
    exit 0
fi
git merge FETCH_HEAD
make app
rm -r /Applications/Alacritty.app
mv ./target/release/osx/Alacritty.app /Applications/Alacritty.app
