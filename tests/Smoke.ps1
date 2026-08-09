[CmdletBinding()]
param()

$projectRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $projectRoot 'ThankYouJeffrey.ps1') -NoWait

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) {
        throw "FAIL: $Message"
    }
}

function Assert-Equal {
    param([object]$Actual, [object]$Expected, [string]$Message)
    if ($Actual -ne $Expected) {
        throw "FAIL: $Message (actual: '$Actual', expected: '$Expected')"
    }
}

$timeline = @(Get-Timeline)
$quotes = @(Get-Snoverisms)
$tributes = @(Get-CommunityTributes)
$manifesto = @(Get-MonadManifesto -All)
$draft = Send-ThankYouEmail -To 'test@example.com'
$about = Get-ThankYouJeffreyAbout
$post = New-QuoteOfTheDay -Date ([datetime]'2025-01-02') -Index 0
$qrPath = Join-Path $projectRoot 'data\monad-manifesto-qr.txt'

Assert-Equal -Actual $timeline.Count -Expected 10 -Message 'timeline bundle should contain ten milestones'
Assert-Equal -Actual $quotes.Count -Expected 4 -Message 'Snoverisms bundle should contain four quotes'
Assert-True -Condition ($tributes.Count -ge 1) -Message 'tribute bundle should contain a fallback wall entry'
Assert-Equal -Actual $manifesto.Count -Expected 3 -Message 'manifesto bundle should contain three pages'
Assert-True -Condition ($post -like '## PowerShell quote of the day*') -Message 'quote post should be Markdown text'
Assert-True -Condition ($draft.MailTo -like 'mailto:test@example.com?*') -Message 'email draft should include the recipient'
Assert-Equal -Actual $about.Version -Expected '0.2.0' -Message 'about metadata should expose the release version'
Assert-True -Condition ((Get-LocalizedString -Key 'CommunityWall') -eq 'COMMUNITY TRIBUTE WALL') -Message 'English locale should be the default'
Assert-True -Condition (Test-Path -LiteralPath $qrPath -PathType Leaf) -Message 'manifesto QR data should be packaged'
Assert-True -Condition ((Get-Content -LiteralPath $qrPath).Count -ge 30) -Message 'manifesto QR data should have enough rows'

Write-Output 'Smoke tests passed.'
