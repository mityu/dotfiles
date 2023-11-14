@echo off
set HOME=

REM Set environmental variables again (TODO: Only invoked from WSL)
set LOADED_INIT_CMD=

REM Clear MSYS* environment variables
for /f "usebackq" %%e in (`set MSYS ^| sed 's/^=.*$/^=/'`) do (
    set %%e
)

cd %USERPROFILE%
