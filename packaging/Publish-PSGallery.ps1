[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$ApiKey,
    [string]$Repository = 'PSGallery'
)

$projectRoot = Split-Path -Parent $PSScriptRoot
$scriptPath = Join-Path $projectRoot 'ThankYouJeffrey.ps1'

if (-not (Test-Path -LiteralPath $scriptPath -PathType Leaf)) {
    throw "The publish script was not found: $scriptPath"
}

if ($PSCmdlet.ShouldProcess("$scriptPath -> $Repository", 'Publish PowerShell script')) {
    Publish-Script -Path $scriptPath -NuGetApiKey $ApiKey -Repository $Repository -Verbose
}
