@(echo '> NUL
echo off)
REM Run myself as a PowerShell script
start cmd.exe /c powershell -Command "iex -Command ((gc '%~f0') -join \"`n\")"
GOTO :EOF
') | sv -Name DummyVer

$res = curl.exe --silent "https://api.github.com/repos/wez/wezterm/releases/latest"
$res = [String]$res
$releaseInfo = ConvertFrom-Json -InputObject $res
$versionRemote = $releaseInfo.name
$versionLocal = (cmd.exe /C "%USERPROFILE%\WezTerm\wezterm-gui.exe --version").split(" ")[1]

If ($versionRemote -ne $versionLocal) {
    $weztermProcList = Get-Process -Name wezterm*
    $weztermProcCount = ($weztermProcList | Measure-Object -Line).Lines
    if ($weztermProcCount -ne 0) {
        Write-Output "Please shutdown all WezTerm process before update."
        Write-Output "Try to shutdown all WezTerm process."
        $toStop = Stop-Process -InputObject $weztermProcList -Confirm -PassThru
        if ($toStop -ne $null) {
            Wait-Process -InputObject $toStop
            Start-Sleep -Milliseconds 10
        }
        if ((Get-Process -Name wezterm* | Measure-Object -Line).Lines -ne 0) {
            Write-Output "Re-run after shutdown all WezTerm process."
            PAUSE
            exit
        }
    }
    foreach ($asset in $releaseInfo.assets) {
        if ($asset.name -Like "*windows*.zip") {
            $outZipPath = "$HOME\Downloads\" + $asset.name
            $cmd = "curl.exe -L -o $outZipPath " + $asset.browser_download_url
            Invoke-Expression $cmd
            $extractDirName = (Get-Item $outZipPath).BaseName
            if ($extractDirName -eq "") {
                Write-Output "Internal error: $extractDirName is empty. Abort."
                PAUSE
                exit
            }
            Expand-Archive -Path $outZipPath -DestinationPath $HOME
            Remove-Item $outZipPath
            Remove-Item -Recurse $HOME\WezTerm
            Rename-Item -Force -Path "$HOME\$extractDirName" -NewName $HOME\WezTerm
        }
    }
} else {
    Write-Output "Already up-to-date."
}
PAUSE
# vim: set filetype=ps1:
