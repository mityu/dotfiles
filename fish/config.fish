set -l is_msys test (uname -o) = "Msys"
set -l in_vim_terminal string length -q -- $VIM_TERMINAL
set -l in_neovim_terminal string length -q -- $NVIM
set -l in_vscode_terminal test "$TERM_PROGRAM" = "vscode"

set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_CACHE_HOME $HOME/.cache
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_STATE_HOME $HOME/.local/state

function dotfiles-path
  # "realpath" is heavy so use some heuristic to detect dotfiles path faster.
  set -l path $HOME/dotfiles
  if string match -rq 'github\.com[/:]mityu/dotfiles' (git -C $path remote get-url origin)
    echo $path
    return
  end
  echo (path dirname (path dirname (realpath (status current-filename))))
end

# Re-define "dotfiles-path" function to return fixed dotfiles path.
eval "
function dotfiles-path
  echo $(dotfiles-path)
end"
set -l dotfiles_path (dotfiles-path)

if $in_vim_terminal || $in_neovim_terminal
  set -e VIM
  set -e VIMRUNTIME
end

if status is-login
  set -gx LANG en_US.UTF-8
  set -gx CLICOLOR auto
  set -gx LSCOLORS gxexfxdxcxahadacagacad

  # Make sure the $SHELL environmental variable is fish.
  string match -rq 'fish$' -- $SHELL || set -gx SHELL (status fish-path)

  if command -q xcrun && command -q brew
    set -l brew_prefix (brew --prefix)
    set -gx SDKROOT (xcrun --show-sdk-path)
    set -gx CPATH $CPATH:$SDKROOT/usr/include
    set -gx LIBRARY_PATH $LIBRARY_PATH:$SDKROOT/usr/lib
    set -gx DYLD_FRAMEWORK_PATH $DYLD_FRAMEWORK_PATH:$SDKROOT/System/Library/Frameworks

    if test -d "$brew_prefix/opt/llvm"
      fish_add_path --prepend $brew_prefix/opt/llvm/bin
    end

    if test -d "$brew_prefix/opt/gcc"
      fish_add_path --prepend $brew_prefix/opt/gcc/bin
      fish_add_path --prepend $dotfiles_path/bin/macos
    end
  end

  if command -q go
    set -l gobin "$(go env GOBIN)"
    string length -q -- $gobin || set -l gobin "$(go env GOPATH)"/bin
    fish_add_path --prepend $gobin
  end

  command -q opam && eval (opam env)
  test -f ~/.cargo/env.fish && source ~/.cargo/env.fish

  fish_add_path --prepend ~/.cache/vim/pack/minpac/opt/vim-themis/bin/
  fish_add_path --prepend ~/.nodebrew/current/bin
  fish_add_path --prepend ~/.roswell/bin
  fish_add_path --prepend /opt/homebrew/bin
  fish_add_path --prepend /opt/homebrew/opt/trash/bin
  fish_add_path --prepend $dotfiles_path/bin
  if command -q aqua
    fish_add_path --prepend --move "$(aqua root-dir)/bin"
    set -gx AQUA_GLOBAL_CONFIG $dotfiles_path/aqua/aqua.yaml
  end
  if test (uname) = "Darwin"
    fish_add_path --prepend --move /run/current-system/sw/bin
    fish_add_path --prepend --move ~/.nix-profile/bin
  end
  fish_add_path --prepend ~/.local/bin
end

if status is-interactive
  abbr --add g git
  abbr --add --command git s status
  abbr --add --command git sw switch
  abbr --add --command git a add
  abbr --add --command git c commit

  set -gx SQLITE_HISTORY $XDG_CACHE_HOME/sqlite_history

  function fish_hybrid_key_bindings --description \
      "Vi-style bindings that inherit emacs-style bindings in all modes"
    for mode in default insert visual
      fish_default_key_bindings -M $mode
    end
    fish_vi_key_bindings --no-erase
  end
  set -g fish_key_bindings fish_hybrid_key_bindings
  bind --user -M insert ctrl-n down-or-search

  # Use block cursor in the normal and visual mode.
  # Also use block cursor while executing commands.
  set fish_cursor_default block
  set fish_cursor_external block

  # Use line cursor in the insert mode.
  set fish_cursor_insert line

  # Use underscore cursor in the replace mode.
  set fish_cursor_replace_one underscore
  set fish_cursor_replace underscore

  string match -q "WezTerm" -- $TERM_PROGRAM && set fish_vi_force_cursor true
  string match -q "alacritty" -- $TERM_PROGRAM && set fish_vi_force_cursor true

  function cd --description "enhanced interactive cd"
    if test (count $argv) -eq 0
      set -l path (interactive-cd-selector)
      if string length -q -- "$path"
        history append "cd $(fishrc_format_path $path)"
        builtin cd "$path"
      end
    else
      builtin cd $argv
    end
  end

  alias repos=repo
  function repo --description 'interactively select and cd repository from "ghq list"'
    set -l opt (if test (count $argv) = 0; echo ''; else echo "-q $argv"; end)
    set -l path (interactive-ghq-selector $opt)
    if string length -q -- "$path"
      set path "$(ghq root)/$path"
      history append "cd $(fishrc_format_path $path)"
      builtin cd "$path"
    else
      echo 'Canceled.'
    end
  end

  alias repo-print=repo-echo
  function repo-echo --description 'interactively select repositories from "ghq list"'
    set -l path (interactive-ghq-selector)
    if string length -q -- "$path"
      echo "$(ghq root)/$path"
    else
      echo 'Canceled.' 1>&2
      return 1
    end
  end

  function repo-new --description 'Create a new repository under a "ghq" managed directory'
    set -l out (repo-new-base "$argv" | string collect)
    set -l retval $pipestatus[1]

    if test $retval -ne 0
      return $retval
    else
      set -l repository (echo $out | jq -r '.repository // ""')
      string length -q -- "$repository"; and builtin cd "$repository"
      echo $out | jq -r '.output | .[]' | string replace "repo-new-base" "repo-new"
      return (echo $out | jq -r '.status')
    end
  end

  function dotfiles --description "Manage dotfiles"
    switch $argv[1]
      case cd
        builtin cd (dotfiles-path)
      case update pull
        git -C (dotfiles-path) pull
      case '' 'help' '-h' '--help'
        echo 'Usage: dotfiles <cmds>'
        echo ''
        echo '<cmds>:'
        echo '  cd     Change the cwd to the dotfiles directory.'
        echo '  pull   Pull the upstream changes.'
        echo '  help   Show this help.'
      case '*'
        echo "Invalid argument: $argv"
        dotfiles --help
    end
  end
end

# Replace $HOME at the head of path into "~", and then escape white-spaces,
# etc, in order to make the argument be treated as strictly one argument.
function fishrc_format_path
  set -l len (string length -- $HOME)
  if test (string sub --length $len -- $argv) = $HOME
    set -l subpath (string trim --left --chars '/' (string sub --start (math $len + 1) $argv))
    echo "~/$(string escape --no-quoted -- $subpath)"
  else
    echo (string escape --no-quoted -- $argv)
  end
end

function fishrc_ask_yesno
  while true
    read -l -P "$argv[1] [y/N]: " confirm

    switch $confirm
      case Y y
        return 0
      case '' N n
        return 1
    end
  end
end

set fish_color_cwd yellow
set fish_color_command blue

alias zenn='deno run --unstable-fs -A npm:zenn-cli@latest'
alias zenn-update='deno cache --reload npm:zenn-cli@latest'
alias themis-nvim='THEMIS_VIM=nvim themis'
alias nix-run='nix run --extra-experimental-features nix-command --extra-experimental-features flakes'
alias update-aqua='aqua update -c $AQUA_GLOBAL_CONFIG'
alias gemini-cli='deno run -A npm:@google/gemini-cli@latest'

if command -q trash
  function trash
    if command trash | grep 'http://hasseg.org/trash' &> /dev/null
      # Homebrew's trash.
      function trash
        if test (count $argv) -eq 0
          command trash
        else
          command trash -F $argv
        end
      end
    else
      # macOS's built-in trash.
      functions -e trash
    end

    trash $argv
  end
  alias gomi='trash'
  alias rm='echo "Use \"trash\" instead."; false'
else if command -q gtrash
  alias gomi='gtrash put'
  alias rm='echo "Use \"gtrash\" instead."; false'
end

if command -q rlwrap
  command -q ocaml && alias ocaml='rlwrap ocaml'
  command -q cargo && alias cargo='rlwrap cargo'
  command -q dune && alias dune='rlwrap dune'
  set -gx RLWRAP_HOME $XDG_STATE_HOME/rlwrap
end

if command -q uutils-coreutils
  set __fishrc_coreutils_overrides \
    arch base32 base64 basename date df dirname groups head id nproc readlink \
    realpath seq tail tr tty uname uniq uptime wc who whoami yes

  function coreutils-alias
    for cmd in $__fishrc_coreutils_overrides
      eval "alias $cmd='uutils-coreutils $cmd'"
    end
    set -g __fish_ls_command uutils-coreutils ls
    set -g __fish_ls_color_opt --color
    set -g __fish_ls_indicators_opt -F
  end
  coreutils-alias

  function coreutils-unalias
    if test (count $argv) -eq 0
      for cmd in $__fishrc_coreutils_overrides
        functions -e $cmd
      end
      coreutils-unalias ls
    else
      for cmd in $argv
        if test $cmd = 'ls'
          set -e -g __fish_ls_command
        else
          functions -e $cmd
        end
      end
    end
  end
else if command -q eza
  function ls
    if test -t 1
      eza --group-directories-first --icons $argv
    else
      command ls $argv
    end
  end
end

command -q bat && alias cat='bat --style plain --theme ansi'
command -q sudoedit || alias sudoedit='sudo -e'

if $in_vim_terminal
  function drop
    printf "\e]51;[\"call\", \"Tapi_drop\", [\"$(pwd)\", \"$argv[1]\"]]\x07"
  end

  function synccwd
    set -l cwd
    printf "\e]51;[\"call\", \"Tapi_getcwd\", []]\x07"
    read cwd
    builtin cd "$cwd"
  end
else if $in_neovim_terminal
  function drop
    nvim -u NONE --server $NVIM --headless --remote-expr "v:lua.require('vimrc').tapi_drop(0, ['$(pwd)', '$argv[1]'])"
  end
else if $in_vscode_terminal
  function drop
    code --reuse-window "$(builtin realpath $argv[1])"
  end
end

if $is_msys
  alias pbpaste='command cat /dev/clipboard'
  alias pbcopy='command cat > /dev/clipboard'
else if command -q xsel
  alias pbpaste='xsel -b'
  alias pbcopy='xsel -bi'
end

if command -q vim
  alias vi="vim -u $dotfiles_path/vim/vimrc_stable"
  alias vim-stable='vi'
  alias profile-vimrc="vim --cmd 'source $dotfiles_path/vim/misc/profile_vimrc.vim'"
  set -gx MANPAGER 'vim -M +MANPAGER -'
  set -gx EDITOR vim
  set -gx GIT_EDITOR vim
end

function gitinit
  if git rev-parse 2> /dev/null
    fishrc_ask_yesno 'In a git repository. continue?' || return 1
  end
  git init --initial-branch main
  git commit --allow-empty -m "Initial commit"
end

# `with` command fixes a prefix of prompt.  E.g.
# $ with 'ENV=XXX'
# $ ENV=XXX  <-- Automatically inserted
#
# To remove prefix, just run `with` with no arguments.
set -g ___fish_prompt_prefix

function with
  set ___fish_prompt_prefix $argv ""
end

function __with_hook --on-event fish_prompt
  commandline --replace "$___fish_prompt_prefix"
end
