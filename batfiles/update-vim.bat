@echo off
setlocal

set DO_BUILD=FALSE

if "%1" == "--help" goto :show_usage
if "%1" == "-h" goto :show_usage
if "%1" == "--force" set DO_BUILD=TRUE
if "%1" == "-f" set DO_BUILD=TRUE
goto :build_vim

:show_usage
echo Usage: %0 [--force^|-f^|--help^|-h]
echo   --force, -f  Force build
echo   --help, -h   Show this help
goto :EOF

:build_vim
for /f "usebackq" %%A in (`cd`) do set CWD=%%A
cd %USERPROFILE%\.cache\vimbuild\src
for /f "usebackq" %%A in (`git rev-parse HEAD`) do set HASH=%%A
git pull
for /f "usebackq" %%A in (`git rev-parse HEAD`) do set HASH_AFTER=%%A

if not %HASH% == %HASH_AFTER% set DO_BUILD=TRUE

if %DO_BUILD% == TRUE (
    make -j4 -f Make_ming.mak GUI=yes VIMDLL=yes STATIC_STDCPLUS=yes
) else (
    echo Vim is already up-to-date.
)
cd %CWD%
