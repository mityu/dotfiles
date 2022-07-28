@if(0)==(0) echo off
  openfiles > NUL 2>&1
  if not %ERRORLEVEL% == 0 (
    echo Re-run this as administrator
    powershell start-process \"%~f0\" -Verb runas
    goto :EOF
  )

  setlocal
  set PARENT_DIR=%~dp0
  set PARENT_DIR=%PARENT_DIR:~0,-1%


  rem Preperation
  if not Exist %USERPROFILE%\.config mkdir %USERPROFILE%\.config

  echo Deploying .vim...
  mklink /D %USERPROFILE%\vimfiles %PARENT_DIR%\dot_vim

  echo Deploying wezterm...
  mklink /D %USERPROFILE%\.config\wezterm %PARENT_DIR%\wezterm

  echo Deploying alacritty...
  mklink /D %APPDATA%\alacritty %PARENT_DIR%\alacritty

  echo Making shortcuts...
  cscript.exe //nologo //E:JScript "%~f0" %*

  pause
  GOTO:EOF
@end

fs = WScript .CreateObject("Scripting.FileSystemObject")
WshShell = WScript.CreateObject("WScript.shell")
startMenuPath = fs.BuildPath(
  WshShell.ExpandEnvironmentStrings("%ProgramData%"),
  "Microsoft\\Windows\\Start Menu\\Programs")
parentDirPath = fs.getParentFolderName(WScript.ScriptFullName)
batfilesDirPath = fs.BuildPath(parentDirPath, "batfiles")

batfiles = ["WSLTerm", "wezterm", "bash"]
for (i in batfiles) {
  WScript.Echo("Making shortcut of " + batfiles[i] + ".bat...")
  src = fs.BuildPath(batfilesDirPath, batfiles[i] + ".bat")
  dest = fs.BuildPath(startMenuPath, batfiles[i] + ".lnk")
  shortcut = WshShell.CreateShortcut(dest)
  shortcut.TargetPath = src
  shortcut.Save()
}
