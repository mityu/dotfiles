@echo off
setlocal

set DOTFILES=%~dp0..

if "%1" == "update" goto :pull
if "%1" == "pull" goto :pull
if "%1" == "cd" goto :cd
if "%1" == "help" goto :show_usage
if "%1" == "--help" goto :show_usage
if "%1" == "-h" goto :show_usage

echo Invalid arguments: %*
goto :show_usage

:show_usage
echo Usage: %0 ^<commands^>
echo     update^|pull   Sync dotfiles with remote repository
echo     cd             Cd to dotfiles directory
echo     help           Show this help
goto :EOF

:pull
git -C %DOTFILES% pull
goto :EOF

:cd
cd %DOTFILES%
goto :EOF
