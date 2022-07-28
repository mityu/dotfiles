: <<'EOL'
@echo off
@call %~dp0setenv.bat
set HOME=
for /f "usebackq" %%e in (`set MSYS ^| sed 's/^=.*$/^=/'`) do (
    set %%e
)
goto :EOF
EOL

if ! which cmd.exe &> /dev/null; then
    exit 0
elif which cygpath &> /dev/null; then
    $(which cmd.exe) //K $(cygpath -w $0)
elif which wslpath &> /dev/null; then
    $(which cmd.exe) //K $(wslpath -w $0)
fi
