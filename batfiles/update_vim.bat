@echo off
setlocal
for /f "usebackq" %%A in (`cd`) do set CWD=%%A
cd %USERPROFILE%\vim\src
for /f "usebackq" %%A in (`git rev-parse HEAD`) do set HASH=%%A
git pull
for /f "usebackq" %%A in (`git rev-parse HEAD`) do set HASH_AFTER=%%A
if not %HASH% == %HASH_AFTER% (
    make -j2 -f Make_ming.mak GUI=no
) else (
    echo Vim is already up-to-date.
)
cd %CWD%
