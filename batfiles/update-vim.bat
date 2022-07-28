@echo off
setlocal
if "%1" == "--help" (
    goto :show_usage
) else if "%1" == "-h" (
    goto :show_usage
) else (
    goto :build_vim
)
:show_usage
echo Usage: %0 [gvim^|gui^|vim^|cui^|--help^|-h]
echo   gvim, gui    Build gVim
echo   vim,  cui    Build vim
echo   --help, -h   Show this help
goto :EOF

:build_vim
set ENABLE_GUI=no
set FORCE_BUILD=FALSE
if "%1" == "gui" (
    set ENABLE_GUI=yes
    set FORCE_BUILD=TRUE
) else if "%1" == "gvim" (
    set ENABLE_GUI=yes
    set FORCE_BUILD=TRUE
) else if "%1" == "cui" (
    set ENABLE_GUI=no
    set FORCE_BUILD=TRUE
) else if "%1" == "vim" (
    set ENABLE_GUI=no
    set FORCE_BUILD=TRUE
) else if not "%1" == "" (
    goto :show_usage
)
for /f "usebackq" %%A in (`cd`) do set CWD=%%A
cd %USERPROFILE%\vim\src
for /f "usebackq" %%A in (`git rev-parse HEAD`) do set HASH=%%A
git pull
for /f "usebackq" %%A in (`git rev-parse HEAD`) do set HASH_AFTER=%%A
if %FORCE_BUILD% == TRUE (
    echo make -j2 -f Make_ming.mak GUI=%ENABLE_GUI%
    make -j2 -f Make_ming.mak GUI=%ENABLE_GUI%
) else if not %HASH% == %HASH_AFTER% (
    echo make -j2 -f Make_ming.mak GUI=no
    make -j2 -f Make_ming.mak GUI=no
) else (
    echo Vim is already up-to-date.
)
cd %CWD%