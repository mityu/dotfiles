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

alias winecmd='wine cmd /k "C:\setenv"'
# alias pip3upgrade='pip3 list --outdated --format=legacy | awk '"'"'{print $1}'"'"' | xargs pip3 install -U'

# autoload -U compinit
# compinit

# The file to save history
export HISTFILE=${HOME}/.zhistory
# How many zsh records history to memory.
export HISTSIZE=1000
# How many zsh records history to the history file.
export SAVEHIST=100000
# Remove history duplicates
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt share_history
# Do not record `history` to command history
setopt hist_no_store
# Enable completion
setopt menu_complete


bindkey -d # Reset keybinds
bindkey -v # Use vi like keybinds

# textobjects
autoload -U select-bracketed
zle -N select-bracketed
for m in visual viopp; do
    for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
        bindkey -M $m $c select-bracketed
    done
done
autoload -U select-quoted
zle -N select-quoted
for m in visual viopp; do
    for c in {a,i}{\',\",\`}; do
        bindkey -M $m $c select-quoted
    done
done

# operator-surround
autoload -Uz surround
zle -N delete-surround surround
zle -N change-surround surround
zle -N add-surround surround
bindkey -M vicmd '_sr' change-surround
bindkey -M vicmd '_sd' delete-surround
bindkey -M vicmd '_sa' add-surround
bindkey -M visual '_sr' change-surround
bindkey -M visual '_sd' delete-surround
bindkey -M visual '_sa' add-surround

# if [ -n "$VIM_TERMINAL" ]; then
#     function edit-line-in-vim(){
#         printf '\e]51;["call", "Tapi_edit_line", ["%s", "%s"]]\x07' \
#             "$BUFFER" "$CURSOR"
#     }
# elif [ which vim &> /dev/null ]; then
#     function edit-line-in-vim(){
#     }
# else
#     function edit-line-in-vim(){
#         # Do nothing.
#     }
# fi
# zle -N edit-line-in-vim
# bindkey -M vicmd '^o' edit-line-in-vim


# Plugins for zsh
# NOTE: To install zplug (A plugin manager for zsh):
# curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
export ZPLUG_HOME=~/.zplug
source $ZPLUG_HOME/init.zsh
zplug "b4b4r07/enhancd", use:init.sh
zplug "junegunn/fzf-bin", from:gh-r, as:command, rename-to:fzf #, frozen:1
zplug "b4b4r07/zsh-gomi", as:command, use:bin/gomi, on:junegunn/fzf-bin
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
        local bufsave
        bufsave=$BUFFER
        BUFFER=$(history -n 1 | fzf --tac +m)
        if ! [ -n "$BUFFER" ]; then
            BUFFER=$bufsave
        fi
        CURSOR=$#BUFFER
        zle redisplay
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
    brew cask upgrade
    pip3 list --outdated --format freeze | sed -e 's/==.*//' | xargs pip3 install -U
    zplug update
}
