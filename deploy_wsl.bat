@if(0)==(0) ECHO OFF
    @rem /mnt/c/Users/K/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json

    rem setlocal
    rem set PARENT_DIR=%~dp0
    rem set PARENT_DIR=%PARENT_DIR:~0,-1%
    rem
    rem mklink /D %USERPROFILE%\vimfiles %PARENT_DIR%\dot_vim
    rem mklink /D %APPDATA%\alacritty %PARENT_DIR%\alacritty

    cscript.exe //nologo //E:JScript "%~f0" %*
    GOTO :EOF
    rem shortcut.IconLocation = "C:\\myicon.ico"
@end

WshShell = WScript.CreateObject("WScript.shell")
startMenuPath = WshShell.ExpandEnvironmentStrings("%ProgramData%") + "\\Microsoft\\Windows\\Start Menu\\Programs\\"
shortcut = WshShell.CreateShortcut(startMenuPath + "WSLTerm.lnk")
shortcut.TargetPath = WScript.CreateObject("Scripting.FileSystemObject").getParentFolderName(WScript.ScriptFullName) + "\\WslTerm.bat"
shortcut.Save()
