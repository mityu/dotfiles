set -l dotfiles_path $HOME/dotfiles
set -l is_msys test (uname -o) = "Msys"
set -l in_vim_terminal string length -q -- $VIM_TERMINAL
set -l in_neovim_terminal string length -q -- $NVIM
set -l in_vscode_terminal test $TERM_PROGRAM = "vscode"

if $in_vim_terminal || $in_neovim_terminal
  set -e VIM
  set -e VIMRUNTIME
end

if status is-login
  set -gx LANG en_US.UTF-8
  set -gx CLICOLOR auto
  set -gx LSCOLORS gxexfxdxcxahadacagacad
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
    end
  end

  if command -q go
    set -l gobin "$(go env GOBIN)"
    string length -q -- $gobin || set -l gobin "$(go env GOPATH)"/bin
    fish_add_path --prepend $gobin
  end

  command -q opam && eval (opam env)
  test -f ~/.cargo/env.fish && source ~/.cargo/env.fish

  fish_add_path --prepend ~/.nodebrew/current/bin
  fish_add_path --prepend ~/.roswell/bin
  fish_add_path --prepend /opt/homebrew/bin
  fish_add_path --prepend $dotfiles_path/bin
  fish_add_path --prepend ~/.local/bin
end

if status is-interactive
  abbr --add g git

  function fish_hybrid_key_bindings --description \
      "Vi-style bindings that inherit emacs-style bindings in all modes"
    for mode in default insert visual
      fish_default_key_bindings -M $mode
    end
    fish_vi_key_bindings --no-erase
  end
  set -g fish_key_bindings fish_hybrid_key_bindings

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

# alias dotfiles="source $dotfiles_path/bin/dotfiles"
alias zenn='deno run --unstable-fs -A npm:zenn-cli@latest'
alias zenn-update='deno cache --reload npm:zenn-cli@latest'
alias themis-nvim='THEMIS_VIM=nvim themis'

if command -q rlwrap
  command -q ocaml && alias ocaml='rlwrap ocaml'
end

command -q eza && alias ls='eza --group-directories-first --icons'
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
    cd "$cwd"
  end
else if $in_vscode_terminal
  function drop
    code --reuse-window "$(builtin realpath $argv[1])"
  end
end

if $is_msys
  alias pbpaste='command cat /dev/clipboard'
  alias pbcopy='command cat > /dev/clipboard'
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
