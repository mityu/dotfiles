@echo off
set WSLENV=USERPROFILE/up:APPDATA/up
start %USERPROFILE%\WezTerm\wezterm-gui.exe start -- wsl -d Ubuntu-18.04
