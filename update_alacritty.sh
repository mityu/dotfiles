cd $1
git fetch
if [ -z "$(git diff)" ]; then
    echo "Alacritty is already up-to-date."
    exit 0
fi
git merge FETCH_HEAD
make app
if [ $? -eq 0 ]; then
    rm -r /Applications/Alacritty.app
    mv ./target/release/osx/Alacritty.app /Applications/Alacritty.app
fi
