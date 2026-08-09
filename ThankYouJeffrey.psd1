@{
    RootModule = 'ThankYouJeffrey.psm1'
    ModuleVersion = '0.2.0'
    GUID = '8c0e8b28-0fc8-4f4e-a7a4-5e6b9f9f5f2f'
    Author = 'SysAdminDoc'
    CompanyName = 'SysAdminDoc'
    Copyright = '(c) SysAdminDoc. All rights reserved.'
    Description = 'A cinematic PowerShell tribute to Jeffrey Snover.'
    PowerShellVersion = '5.1'
    CompatiblePSEditions = @('Desktop', 'Core')
    FunctionsToExport = @(
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
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('PowerShell', 'tribute', 'Jeffrey Snover', 'console')
            LicenseUri = 'https://github.com/SysAdminDoc/ThankYouJeffrey/blob/main/LICENSE'
            ProjectUri = 'https://github.com/SysAdminDoc/ThankYouJeffrey'
            ReleaseNotes = 'JSON-backed tribute content, localized playback, and helper commands.'
        }
    }
}
