: <<'EOL'
@echo off
setlocal
set MSYS2=C:\msys64\msys2_shell.cmd
if not exist "%MSYS2%" (
    echo %MSYS2% not found.
    goto :EOF
)
%MSYS2% -mingw64 -no-start %~dpnx0
goto :EOF
EOL
pacman -Syyu --noconfirm || read -p 'Error while updating softwares...'
