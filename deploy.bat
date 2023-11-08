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
  mklink /D %USERPROFILE%\vimfiles %PARENT_DIR%\vim

  echo Deploying wezterm...
  mklink /D %USERPROFILE%\.config\wezterm %PARENT_DIR%\wezterm

  echo Deploying alacritty...
  mklink /D %APPDATA%\alacritty %PARENT_DIR%\alacritty

  echo Making shortcuts...
  cscript.exe //nologo //E:JScript "%~f0" %*

  pause
  GOTO:EOF
@end

var fs = WScript.CreateObject('Scripting.FileSystemObject')
var wsh = WScript.CreateObject('WScript.shell')

function formatString(fmt) {
  var regex = new RegExp('{}', '')
  for (var i = 1; i < arguments.length; ++i) {
    fmt = fmt.replace(regex, arguments[i])
  }
  return fmt
}

function joinPath() {
  var path = ''
  for (var i = 0; i < arguments.length; ++i) {
    path = fs.BuildPath(path, arguments[i])
  }
  return path
}

function downloadFile(url, dst) {
  var cmd = formatString('curl.exe --silent "{}" -o "{}"', url, dst)
  WScript.Echo(cmd)
  wsh.Run(cmd, 0, true)
}

function getIconDir() {
  var home = fs.getParentFolderName(wsh.SpecialFolders('Desktop'))
  return joinPath(home, '.cache', 'shortcut-icons')
}

function prepareIcons() {
  var icons = [
    ['https://www.archlinux.jp/images/favicon.ico', 'archlinux.ico'],
    ['https://raw.githubusercontent.com/wez/wezterm/main/assets/windows/terminal.ico', 'wezterm.ico'],
    ['https://raw.githubusercontent.com/msys2/msys2.github.io/source/web/favicon.ico', 'bashterm.ico'],
    ['https://jp.ubuntu.com/static/files/favicon.ico', 'ubuntu.ico'],
  ]
  var iconDir = getIconDir()
  if (!fs.FolderExists(iconDir)) {
    fs.CreateFolder(iconDir)
  }
  for (var i in icons) {
    var icon = icons[i]
    var dst = fs.BuildPath(iconDir, icon[1])
    downloadFile(icon[0], dst)
  }
}

function makeShortcuts() {
  var files = ['WSLTerm', 'wezterm', 'bashterm', 'archlinux', 'ubuntu']
  var dstDir = wsh.SpecialFolders('Programs')  // Path to start menu
  var srcDir = fs.BuildPath(fs.getParentFolderName(WScript.ScriptFullName), 'batfiles')
  var iconDir = getIconDir()
  for (var i in files) {
    var file = files[i]
    var src = fs.BuildPath(srcDir, file + '.bat')
    var dst = fs.BuildPath(dstDir, file + '.lnk')
    var icon = fs.BuildPath(iconDir, file + '.ico')

    WScript.Echo(src, '->', dst)

    var shortcut = wsh.CreateShortcut(dst)
    shortcut.TargetPath = src
    if (fs.FileExists(icon)) {
      shortcut.IconLocation = icon
    } else if (file === 'WSLTerm') {
      shortcut.IconLocation = 'wsl.exe, 0'
    }
    shortcut.Save()
  }

  {  // Create shortcut for open cmd.exe with unix-like commands in msys2 enabled.
    var dst = fs.BuildPath(dstDir, 'cmdterm.lnk')
    var setenv = fs.BuildPath(srcDir, 'setenv.bat')
    var home = fs.getParentFolderName(wsh.SpecialFolders('Desktop'))
    var args = formatString('/k "{} && title %ComSpec% - with msys2"', setenv)

    WScript.Echo(formatString('cmd.exe {}', args), '->', dst)

    var shortcut = wsh.CreateShortcut(dst)
    shortcut.TargetPath = 'cmd.exe'
    shortcut.Arguments = args
    shortcut.IconLocation = 'cmd.exe, 0'
    shortcut.WorkingDirectory = home
    shortcut.Save()
  }
}

prepareIcons()
makeShortcuts()
