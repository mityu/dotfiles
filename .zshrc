# Set environmental variables (Only when outside of vim.)
if ! [ -n "$VIM_TERMINAL" ] && [ -f ~/.envrc ]; then
    cat ~/.envrc | while read path_expr
    do
        # Ignore blank line.
        if [ -z ${path_expr} ]; then
            continue
        fi

        # Ignore comment.
        if [ ${path_expr:0:1} = "#" ]; then
            continue
        fi
        export $(eval echo ${path_expr})
    done
fi

alias mvim=$VIMBINARY
alias vim='mvim'
alias winecmd='wine cmd /k "C:\setenv"'
# alias pip3upgrade='pip3 list --outdated --format=legacy | awk '"'"'{print $1}'"'"' | xargs pip3 install -U'

# autoload -U compinit
# compinit

# The file to save history
export HISTFILE=${HOME}/.zhistory
# How many does zsh record history to memory.
export HISTSIZE=1000
# How many does zsh record history to a history file.
export SAVEHIST=100000
# Remove history duplicates
setopt hist_ignore_all_dups
setopt hist_ignore_dups
# historyを共有
setopt share_history
# Do not record `history`
setopt hist_no_store
# Enable completion
setopt menu_complete

# Use vi like keybinds
bindkey -d # Reset keybinds
bindkey -v
bindkey -M viins '^j' vi-cmd-mode
bindkey -M vicmd '^e' vi-end-of-line
bindkey -M vicmd '^a' vi-first-non-blank

# NOTE: $luarocks --lua-dir=/usr/local/opt/lua@5.1 {args}
# if [ -n "$VIM_TERMINAL" ] && [ -n "$VIM_SERVERNAME" ]; then
#     function mvim(){
#         $VIMBINARY --servername $VIM_SERVERNAME --remote-tab-wait $@
#     }
# else
#     function mvim(){
#         $VIMBINARY $@
#     }
# fi

# Plugins for zsh
# NOTE: To install zplug (A plugin manager for zsh):
# curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
export ZPLUG_HOME=~/.zplug
source $ZPLUG_HOME/init.zsh
zplug "b4b4r07/enhancd", use:init.sh
zplug "b4b4r07/gomi", as:command, from:github
zplug "junegunn/fzf-bin", from:gh-r, as:command, rename-to:fzf
zplug "mafredri/zsh-async", from:github
zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme
zplug "zplug/zplug", hook-build:"zplug --self-manage"
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# Install uninstalled plugins.
if ! zplug check; then
    printf "Install plugins? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi
zplug load --verbose

# Plugin settings
if zplug check sindresorhus/pure; then
    autoload -U promptinit; promptinit
    # prompt pure
else
    PROMPT='%c $ '
    RPROMPT='[%~]'
fi
if zplug check junegunn/fzf-bin; then
    export FZF_DEFAULT_COMMANDS="files -a \`pwd\`"
    export FZF_DEFAULT_OPTS="--reverse"

    function select-history(){
        BUFFER=$(history -n 1 | fzf --tac +m)
        CURSOR=$#BUFFER
    }
    zle -N select-history
    bindkey '^r' select-history
fi
# if zplug check b4b4r07/enhancd; then
#     export ENHANCD_FILTER=peco:fzf
# fi

function update_components(){
    brew upgrade
    brew cleanup
    pip3 list --outdated --format freeze | sed -e 's/==.*//' | xargs pip3 install -U
    zplug update
    vim --noplugin -c PackUpdate -c quit
}
