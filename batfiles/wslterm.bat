@echo off
set WSLENV=USERPROFILE/up:APPDATA/up

set A=%cmdcmdline%
set A=%A:"=%
if "%A%" == "%A:/c=%" (
    REM When launched from terminal.
    REM Ref: https://gist.github.com/seraphy/0fc14023b40935ed925021e64ebaf7b2
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

:nostart
wsl.exe -d Ubuntu-18.04
goto :EOF

:start
%~dp0launch-wezterm.bat start -- wsl.exe -d Ubuntu-18.04
