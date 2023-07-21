@echo off
if "%VIM_TERMINAL%" == "" goto :EOF
vim --servername %VIM_SERVERNAME% --remote-send "<Cmd>split %~dp0%1<CR>"
