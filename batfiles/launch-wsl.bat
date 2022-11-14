@echo off
set WSLENV=USERPROFILE/up:APPDATA/up

set DIST=%1
set OPT=%2

set A=%cmdcmdline%
set A=%A:"=%
if "%A%" == "%A:/c=%" (
    REM When launched from terminal.
    REM Ref: https://gist.github.com/seraphy/0fc14023b40935ed925021e64ebaf7b2

    if "%OPT%" == "--help" (
        goto :usage
    ) else if "%OPT%" == "-h" (
        goto :usage
    )

    for %%o in (start,new-window) do (
        if "%OPT%" == "%%o" (
            goto :start
        ) else if "%OPT%" == "-%%o" (
            goto :start
        ) else if "%OPT%" == "--%%o" (
            goto :start
        )
    )
    goto :nostart
) else (
    goto :start
)

:usage
echo Usage: %0 [start^|new-window^|--help]
echo   [No arguments]   Start WSL here
echo   start            Start WSL in a new window
echo   new-window       Same above
echo   --help           Show this help
goto :EOF

:nostart
wsl.exe -d %DIST%
goto :EOF

:start
%~dp0launch-wezterm.bat --config default_prog={'wsl.exe','-d','%DIST%'} start
