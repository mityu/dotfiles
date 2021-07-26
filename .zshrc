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
        eval 'export' $path_expr
    done
fi

alias winecmd='wine cmd /k "C:\setenv"'
# alias pip3upgrade='pip3 list --outdated --format=legacy | awk '"'"'{print $1}'"'"' | xargs pip3 install -U'

# Enable smart completion
autoload -Uz compinit
compinit

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

if type "vim" > /dev/null 2>&1; then
    export MANPAGER="vim -M +MANPAGER -"
fi

if [ -n "$VIM_TERMINAL" ]; then
    function drop() {
        echo "\e]51;[\"drop\", \"$(pwd)/$1\"]\x07"
    }
fi

# WSL2
if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
    LOCAL_IP=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
    export DISPLAY=$LOCAL_IP:0
    if [ -n "$APPDATA" ]; then
        export SUMATRAPDF=$(dirname $APPDATA)/Local/SumatraPDF/SumatraPDF.exe
    else
        echo "\033[41m\$APPDATA is empty\033[m"
    fi
    cd ~
    function open() {
        cmd.exe /c start $(wslpath -w $1)
    }
fi

# Plugins
DOTZSH=$HOME/.zsh

function install_zsh_plugins() {
    if [ ! which git &> /dev/null ]; then
        echo -e '\033[41mgit command not found\033[m'
        return 1
    fi
    if [ ! -d "$DOTZSH/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting \
            $DOTZSH/zsh-syntax-highlighting
    fi

    if [ ! -d "$DOTZSH/pure" ]; then
        git clone https://github.com/sindresorhus/pure $DOTZSH/pure
    fi
}

function update_zsh_plugins() {
    local dir
    for dir in $(find $DOTZSH/* -maxdepth 0 -type d); do
        echo -e '\033[32m'$(basename $dir)'\033[m'
        git -C $dir pull
    done
}

if [ ! -d "$DOTZSH" ]; then
    printf "Install plugins? [y/N]: "
    if read -q; then
        mkdir -p $DOTZSH
        install_zsh_plugins
    fi
fi

# Add plugin directories to fpath (&runtimepath like variable)
function() {
    local dir
    for dir in $(find $DOTZSH/* -maxdepth 0 -type d); do
        fpath+=$dir
    done
}

if [ -d "$DOTZSH/pure" ]; then
    autoload -U promptinit; promptinit
    zstyle ':prompt:pure:git:stash' show yes
    zstyle ':prompt:pure:path' color yellow
    zstyle ':prompt:pure:prompt:*' color default
    prompt pure

    # Show $? value with color (green=succeeded, red=failed)
    prompt_newline=$' %{%(?.%F{green}.%F{red})%}$?%f\n%{\r%}'
else
    PROMPT='%c $ '
    RPROMPT='[%~]'
fi

if [ -d "$DOTZSH/zsh-syntax-highlighting" ]; then
    source $DOTZSH/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

if which fzf &> /dev/null; then
    export FZF_DEFAULT_COMMANDS="files -a \`pwd\`"
    export FZF_DEFAULT_OPTS="--reverse --no-sort"

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

function update_components(){
    brew upgrade
    brew cleanup
    brew upgrade --cask
    pip3 list --outdated --format freeze | sed -e 's/==.*//' | xargs pip3 install -U
    update_zsh_plugins
}
