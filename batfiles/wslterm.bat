@echo off
set WSLENV=USERPROFILE/up:APPDATA/up

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
echo Usage: %0 [start^|new-window^|--help]
echo   [No arguments]   Start WSL here
echo   start            Start WSL in a new window
echo   new-window       Same above
echo   --help           Show this help
goto :EOF

:nostart
wsl.exe -d Ubuntu-18.04
goto :EOF

:start
%~dp0launch-wezterm.bat --config default_prog={'wsl.exe','-d','Ubuntu-18.04'} start
