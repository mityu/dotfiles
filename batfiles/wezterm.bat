@echo off
@call %~dp0setenv.bat
cd %USERPROFILE%
%~dp0launch-wezterm.bat %*
