#!/bin/bash -e

# Usage:
#  - Clone this repository and do `<path/to/repository>/deploy.sh`
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

# Installing Homebrew (cask) formula implementation.
# Usage:
#   - Install Homebrew formula
#       install_formula {formula-name}
#   - Install Homebrew cask formula
#       install_formula {formula-name} cask
install_formula (){
    if brew $2 list $1 &>/dev/null; then
        echo "Formula already installed. Skip: brew $2 install $1"
    else
        brew $2 install $1
    fi
}

brew_install (){
    install_formula $1
}

brew_cask_install (){
    install_formula $1 cask
}

# Get the user's passward at first for sudo.
read -sp "Your password: " password;



if ask "Do 'xcode-select --install?'"; then
    xcode-select --install
fi

# Install Homebrew if it doesn't exists.
if ! has_cmd brew ; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew update
    brew upgrade --all --cleanup
fi

# Give up to setup if installing Homebrew fails.
if ! has_cmd brew ; then
    echo 'Fatal: Failed to install homebrew. Exit.'
    exit 1
fi

if ( ! has_cmd git ) || ( ask "Install Homebrew's git?" ); then
    brew_install git
fi
brew_cask_install alacritty
brew_install zsh
if [ -f "/usr/local/bin/zsh" ]; then # Installing zsh successfully.
    echo $password | \
        sudo -S -- sh -c "echo '/usr/local/bin/zsh' >> /private/etc/shells"
    chsh -s /usr/local/bin/zsh
fi
brew_install the_silver_searcher

DOTFILES=$HOME/dotfiles
if [ ! -d "$DOTFILES" ]; then
    echo 'Cloning mityu/dotfiles'
    git clone --recursive https://github.com/mityu/dotfiles.git $DOTFILES
fi
$DOTFILES/deploy.sh

DOTFILES=$HOME/dotfiles
VIM_NIGHTLY_BUILD_DIR=$HOME/.vim_nightly_build
if [ ! -d "$VIM_NIGHTLY_BUILD_DIR" ]; then
    git clone --recursive --depth 1 \
        https://github.com/vim/vim.git $VIM_NIGHTLY_BUILD_DIR
    make
    make install
fi
