$scriptPath = Join-Path $toolsDir 'ThankYouJeffrey.ps1'
$wrapperPath = Join-Path $toolsDir 'ThankYouJeffrey.cmd'

@"
@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ThankYouJeffrey.ps1" %*
"@ | Set-Content -LiteralPath $wrapperPath -Encoding ASCII

Install-BinFile -Name 'ThankYouJeffrey' -Path $wrapperPath
