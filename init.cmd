@echo off

REM ref: https://mattn.kaoriya.net/software/why-i-use-cmd-on-windows-2020.htm

doskey ls=ls --color=auto --show-control-chars -N $*
doskey grep=grep --color=auto $*
doskey wezterm=%USERPROFILE%\WezTerm\wezterm-gui.exe %*
doskey pwd=echo %CD%

if "%LOADED_INIT_CMD%" neq "" goto :eof
set LOADED_INIT_CMD=1

set PATH=%USERPROFILE%\dotfiles\batfiles;%USERPROFILE%\.cache\vimbuild\src;%USERPROFILE%\go\bin;C:\msys64\mingw64\bin;C:\msys64\usr\bin;C:\msys64\usr\local\bin;%PATH%;
set GOROOT=C:\msys64\mingw64\lib\go
set EDITOR=vim
set GIT_EDITOR=vim

cd %USERPROFILE%
