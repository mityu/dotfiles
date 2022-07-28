: <<'EOL'
@echo off
setlocal
where /Q cygpath
if %ERRORLEVEL% == 0 (
    for /f "usebackq" %%A in (`cygpath -w /msys2_shell.cmd`) do set MSYS2=%%A
) else (
    set MSYS2=C:\msys64\msys2_shell.cmd
)
if not exist "%MSYS2%" (
    echo %MSYS2% not found.
    goto :EOF
)
%MSYS2% -mingw64 -no-start -defterm %~dpnx0
goto :EOF
EOL
pacman -Syyu --noconfirm || read -p 'Error while updating softwares...'
