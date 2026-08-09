$scriptPath = Join-Path $PSScriptRoot 'ThankYouJeffrey.ps1'
. $scriptPath -NoWait

Export-ModuleMember -Function @(
    'Get-MonadManifesto'
    'Get-Snoverism'
    'Get-Snoverisms'
    'Invoke-PowerShellTimeline'
    'New-QuoteOfTheDay'
    'Send-ThankYouEmail'
    'Get-ThankJeffreyShareUrl'
    'Get-ThankYouJeffreyAbout'
    'Invoke-ThankJeffrey'
    'Start-SnoverDemo'
    'Start-StartDemo'
)
