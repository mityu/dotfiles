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
REM HACK: Before "endlocal", changes of current working directory will be
REM discarded and we need to do "endlocal" before cd, but after "endlocal"
REM DOTFILES variable will be cleared to previous state and is no longer
REM available when do chdir.  In order to make it compatible use of "setlocal"
REM and chdir, use "for" statement to pass contents of DOTFILES variable for a
REM temporal variable, disable "setlocal" functionality, and then do chdir.
for %%d in (%DOTFILES%) do (
    endlocal
    cd %%d
)
goto :EOF
