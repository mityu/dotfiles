@echo off
if "%VIM_TERMINAL%" == "" goto :EOF
vim --servername %VIM_SERVERNAME% --remote-send "<Cmd>split %1<CR>"
