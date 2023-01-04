#!/bin/bash -e

# Usage:
#  - Clone this repository and do `<path/to/repository>/setup_mac.sh`
#  - `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mityu/dotfiles/master/setup_mac.sh)"`

has_cmd (){
    which $1 &> /dev/null;
}
ask (){
    while true; do
        read -p "${1} [Y/n] " answer
        case $answer in
            '' | [Yy]*) return 0;;
            [Nn]*)      return 1;;
            *)          echo "Please answer Yes or No.";;
        esac
    done
}

brew_install (){
    if brew list $1 &>/dev/null; then
        echo "Formula already installed. Skip: $ brew install $1"
    else
        brew install $@
    fi
}

# Get the user's passward at first for sudo.
read -sp "Your password: " password;



if ask "Do 'xcode-select --install?'"; then
    xcode-select --install
fi

# Install Homebrew if it doesn't exists.
if ! has_cmd brew ; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew update
    brew upgrade --all --cleanup
fi

# Give up to setup if installing Homebrew fails.
if ! has_cmd brew ; then
    echo 'Fatal: Failed to install homebrew. Exit.'
    exit 1
fi

if ! has_cmd git; then
    brew_install git
fi

brew_install zsh
if brew list zsh &> /dev/null; then
    echo $password | \
        sudo -S -- sh -c "echo '$(brew --prefix)/bin/zsh' >> /private/etc/shells"
    chsh -s $(brew --prefix)/bin/zsh
fi

brew_install wezterm
brew_install ripgrep

DOTFILES=$HOME/dotfiles
if [ ! -d "$DOTFILES" ]; then
    echo 'Cloning mityu/dotfiles'
    git clone --recursive https://github.com/mityu/dotfiles.git $DOTFILES
fi
$DOTFILES/deploy.sh
echo $password | $DOTFILES/bin/update-vim.sh
