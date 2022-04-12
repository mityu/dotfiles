@echo off
set WSLENV=USERPROFILE/up:APPDATA/up
start alacritty.exe -e wsl -d Ubuntu-18.04
rem start %USERPROFILE%\WezTerm\wezterm-gui.exe start -- wsl -d Ubuntu-18.04
