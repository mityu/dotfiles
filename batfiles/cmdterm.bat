@echo off
@call %~dp0setenv.bat
set HOME=
for /f "usebackq" %%e in (`set MSYS ^| sed 's/^=.*$/^=/'`) do (
    set %%e
)
cd %USERPROFILE%
