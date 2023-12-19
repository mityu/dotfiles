vim9script

const dir = expand('~/.local/log/vim/')
const file = dir ..  strftime('profile_%Y-%m-%d_%H-%M-%S.log')
mkdir(dir, 'p')
execute $'profile start {file}'
execute $'profile! file */vimrc'
autocmd SourcePost vimrc ++once profile stop
execute $'autocmd VimEnter * ++once edit `={string(file)}`'
