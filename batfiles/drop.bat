@echo off
if "%VIM_TERMINAL%" == "" goto :EOF
vim --servername %VIM_SERVERNAME% --remote-send "<Cmd>call Tapi_drop(0, ['%cd%', '%1'])<CR>"
