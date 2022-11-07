@echo off

set A=%cmdcmdline%
set A=%A:"=%
if "%A%" == "%A:/c=%" (
    REM When launched from terminal.
    REM Ref: https://gist.github.com/seraphy/0fc14023b40935ed925021e64ebaf7b2

    if "%1" == "--help" (
        goto :usage
    ) else if "%1" == "-h" (
        goto :usage
    )

    for %%o in (start,new-window) do (
        if "%1" == "%%o" (
            goto :start
        ) else if "%1" == "-%%o" (
            goto :start
        ) else if "%1" == "--%%o" (
            goto :start
        )
    )
    goto :nostart
) else (
    goto :start
)

:usage
echo Batchfile to launch msys2 bash ^(mingw64^).
echo
echo Usage: %0 [start^|new-window^|--help]
echo   [No arguments]   Start bash here
echo   start            Start bash in a new window
echo   new-window       Same above
echo   --help           Show this help
goto :EOF

:nostart
C:\msys64\msys2_shell.cmd -mingw64 -defterm -no-start -use-full-path
goto :EOF

:start
%~dp0launch-wezterm.bat --config default_prog={'C:\\msys64\\msys2_shell.cmd','-mingw64','-defterm','-no-start','-use-full-path'} start
