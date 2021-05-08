@echo off
@rem /mnt/c/Users/K/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json

setlocal
set PARENT_DIR=%~dp0
set PARENT_DIR=%PARENT_DIR:~0,-1%

mklink /D %USERPROFILE%\vimfiles %PARENT_DIR%\dot_vim
mklink /D %APPDATA%\alacritty %PARENT_DIR%\alacritty
