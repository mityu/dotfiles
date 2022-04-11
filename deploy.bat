@echo off

openfiles > NUL 2>&1
if not %ERRORLEVEL% == 0 (
  echo Re-run this as administrator
  powershell start-process \"%~f0\" -Verb runas
  goto :EOF
)

setlocal
set PARENT_DIR=%~dp0
set PARENT_DIR=%PARENT_DIR:~0,-1%


rem Preperation
if not Exist %USERPROFILE%\.config mkdir %USERPROFILE%\.config

echo Deploying .vim
mklink /D %USERPROFILE%\vimfiles %PARENT_DIR%\dot_vim

echo Deploying wezterm
mklink /D %USERPROFILE%\.config\wezterm %PARENT_DIR%\wezterm
