<#
.SYNOPSIS
    Thank You Jeffrey - A PowerShell Tribute to Jeffrey Snover
    
.DESCRIPTION
    A cinematic console experience celebrating Jeffrey Snover's creation of PowerShell
    and his retirement. This script uses the very tool he created to tell its story.
    
.NOTES
    Author: The PowerShell Community
    Created: 2025
    
    "PowerShell is a task-based command-line shell and scripting language built on .NET"
    - But more than that, it changed how we think about system administration.
    
    Thank you, Jeffrey. For everything.
#>

param(
    [ValidateSet('Fast', 'Normal', 'Dramatic')]
    [string]$Speed = 'Normal',
    [switch]$Audio,
    [switch]$SkipIntro,
    [switch]$EasterEgg,
    [switch]$NoWait,
    [ValidateSet('Auto', 'en', 'ja', 'de', 'pt-br')]
    [string]$Locale = 'Auto',
    [switch]$Online,
    [string]$CommunityUri = 'https://raw.githubusercontent.com/SysAdminDoc/ThankYouJeffrey/main/data/tributes.json',
    [string]$TranscriptPath
)

#Requires -Version 5.1

# ============================================================================
# CONFIGURATION
# ============================================================================

$script:Version = '0.2.0'

$script:Config = [ordered]@{
    FrameDelay      = 50        # Base animation frame delay (ms)
    TypewriterDelay = 30        # Typewriter effect delay (ms)
    SceneDelay      = 2000      # Pause between scenes (ms)
    EnableSound     = $Audio.IsPresent
    SkipIntro       = $SkipIntro.IsPresent
    Speed           = $Speed
    SpeedFactor     = 1.0
    PacingFactor    = 1.0
    FrameRate       = 20
    ConsoleWidth    = 120
    ConsoleHeight   = 40
    ColorMode       = 'Console'
    IsInteractive   = $false
    SkipToEnd       = $false
    ReplayRequested = $false
    SuppressDelays  = $NoWait.IsPresent
    EasterEgg       = $EasterEgg.IsPresent
    Locale          = $Locale
    Online          = $Online.IsPresent
    CommunityUri    = $CommunityUri
    TranscriptPath  = $TranscriptPath
    TranscriptStarted = $false
}

switch ($Speed) {
    'Fast' { $script:Config.SpeedFactor = 0.35 }
    'Dramatic' { $script:Config.SpeedFactor = 1.75 }
    default { $script:Config.SpeedFactor = 1.0 }
}

function Get-ConsoleWidth {
    try {
        if ($null -ne $Host.UI.RawUI) {
            return [Math]::Max(40, [int]$Host.UI.RawUI.WindowSize.Width)
        }
    } catch {
        # Fall back to the process console when a host does not expose RawUI.
    }

    try {
        if ([Console]::WindowWidth -gt 0) {
            return [Math]::Max(40, [int][Console]::WindowWidth)
        }
    } catch {
        # A redirected or non-console host has no usable window width.
    }

    return 120
}

function Get-ConsoleHeight {
    try {
        if ($null -ne $Host.UI.RawUI) {
            return [Math]::Max(20, [int]$Host.UI.RawUI.WindowSize.Height)
        }
    } catch {
        # Fall back to a safe theatrical default.
    }

    try {
        if ([Console]::WindowHeight -gt 0) {
            return [Math]::Max(20, [int][Console]::WindowHeight)
        }
    } catch {
        # A redirected or non-console host has no usable window height.
    }

    return 40
}

function Test-InteractiveConsole {
    try {
        if ($null -eq $Host.UI.RawUI) {
            return $false
        }

        if ([Console]::IsInputRedirected -or [Console]::IsOutputRedirected) {
            return $false
        }

        return $true
    } catch {
        return $false
    }
}

function Get-ColorMode {
    if ($env:NO_COLOR) {
        return 'Plain'
    }

    try {
        if ([Console]::IsOutputRedirected) {
            return 'Plain'
        }
    } catch {
        # Continue with environment-based detection for non-console hosts.
    }

    $colorTerm = [string]$env:COLORTERM
    $term = [string]$env:TERM
    $termProgram = [string]$env:TERM_PROGRAM

    if ($env:WT_SESSION -or $colorTerm -match 'truecolor|24bit' -or $termProgram -eq 'Alacritty') {
        return 'TrueColor'
    }

    if ($colorTerm -match '256color' -or $term -match '256color' -or $env:ANSICON -or $env:ConEmuANSI -eq 'ON') {
        return 'Ansi256'
    }

    return 'Console'
}

function Initialize-Pacing {
    $script:Config.ConsoleWidth = Get-ConsoleWidth
    $script:Config.ConsoleHeight = Get-ConsoleHeight
    $script:Config.IsInteractive = Test-InteractiveConsole
    $script:Config.ColorMode = Get-ColorMode
    if (-not $script:Config.IsInteractive) {
        $script:Config.EnableSound = $false
    }

    $script:Config.FrameRate = if ($script:Config.ColorMode -in @('TrueColor', 'Ansi256')) { 30 } else { 20 }
    if ($script:Config.ConsoleWidth -lt 80) {
        $script:Config.PacingFactor = 1.35
    } elseif ($script:Config.ConsoleWidth -lt 120) {
        $script:Config.PacingFactor = 1.15
    } else {
        $script:Config.PacingFactor = 1.0
    }
}

function Get-AdjustedDelay {
    param([double]$Milliseconds)

    if ($script:Config.SuppressDelays -or -not $script:Config.IsInteractive) {
        return 0
    }

    $delay = $Milliseconds * $script:Config.SpeedFactor * $script:Config.PacingFactor
    $frameBudget = 1000 / [Math]::Max(10, [double]$script:Config.FrameRate)
    return [Math]::Max(1, [int][Math]::Min($delay, $frameBudget * 4))
}

function Read-PlaybackControl {
    if (-not $script:Config.IsInteractive -or $script:Config.SkipToEnd) {
        return
    }

    try {
        while ($Host.UI.RawUI.KeyAvailable) {
            $key = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
            if ($key.Character -eq ' ' -or $key.VirtualKeyCode -eq 32) {
                $script:Config.SkipToEnd = $true
            } elseif ($key.Character -eq 'r' -or $key.Character -eq 'R') {
                $script:Config.ReplayRequested = $true
                $script:Config.SkipToEnd = $true
            }
        }
    } catch {
        # Some hosts expose RawUI but do not support non-blocking key reads.
    }
}

function Wait-Animation {
    param([int]$Milliseconds)

    if ($Milliseconds -le 0) {
        Read-PlaybackControl
        return
    }

    $remaining = Get-AdjustedDelay -Milliseconds $Milliseconds
    while ($remaining -gt 0 -and -not $script:Config.SkipToEnd) {
        Read-PlaybackControl
        if ($script:Config.SkipToEnd) {
            return
        }

        $slice = [Math]::Min(50, $remaining)
        Start-Sleep -Milliseconds $slice
        $remaining -= $slice
    }
}

$script:DataRoot = if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    Join-Path $PSScriptRoot 'data'
} else {
    Join-Path (Get-Location) 'data'
}

function Read-JsonBundle {
    param(
        [string]$FileName,
        [object]$Fallback
    )

    $path = Join-Path $script:DataRoot $FileName
    if (Test-Path -LiteralPath $path -PathType Leaf) {
        try {
            $json = Get-Content -LiteralPath $path -Raw -Encoding UTF8
            if (-not [string]::IsNullOrWhiteSpace($json)) {
                return ConvertFrom-Json -InputObject $json
            }
        } catch {
            # A malformed local bundle falls back to the embedded safe copy.
        }
    }

    return $Fallback
}

function Get-DefaultTimeline {
    return @(
        [pscustomobject]@{ Year = '2002'; Event = 'The Monad Manifesto is written'; Color = 'Cyan'; Source = 'Monad Manifesto' },
        [pscustomobject]@{ Year = '2003'; Event = 'Project Monad begins at Microsoft'; Color = 'Cyan'; Source = 'PowerShell history' },
        [pscustomobject]@{ Year = '2006'; Event = 'PowerShell 1.0 released to the world'; Color = 'Green'; Source = 'PowerShell history' },
        [pscustomobject]@{ Year = '2009'; Event = 'PowerShell 2.0 - Remoting & Modules'; Color = 'White'; Source = 'PowerShell history' },
        [pscustomobject]@{ Year = '2012'; Event = 'PowerShell 3.0 - Workflows arrive'; Color = 'White'; Source = 'PowerShell history' },
        [pscustomobject]@{ Year = '2016'; Event = 'PowerShell goes OPEN SOURCE'; Color = 'Yellow'; Source = 'PowerShell history' },
        [pscustomobject]@{ Year = '2016'; Event = 'PowerShell runs on Linux & macOS'; Color = 'Magenta'; Source = 'PowerShell history' },
        [pscustomobject]@{ Year = '2018'; Event = 'PowerShell Core 6.0 - Cross-platform'; Color = 'Cyan'; Source = 'PowerShell history' },
        [pscustomobject]@{ Year = '2020'; Event = 'PowerShell 7 - The unified shell'; Color = 'Green'; Source = 'PowerShell history' },
        [pscustomobject]@{ Year = '2025'; Event = 'Jeffrey Snover retires'; Color = 'Yellow'; Source = 'Community tribute' }
    )
}

function Get-DefaultSnoverisms {
    return @(
        [pscustomobject]@{ Text = 'The pipeline is the heart of PowerShell.'; Attr = '- Jeffrey Snover'; Source = 'PowerShell community' },
        [pscustomobject]@{ Text = 'PowerShell is a tool for thought.'; Attr = '- Jeffrey Snover'; Source = 'PowerShell community' },
        [pscustomobject]@{ Text = 'Live your life in a state of compounding success.'; Attr = '- Jeffrey Snover'; Source = 'Snoverism' },
        [pscustomobject]@{ Text = 'Automate everything. Then automate the automation.'; Attr = '- The PowerShell Way'; Source = 'Community paraphrase' }
    )
}

function Get-DefaultTributes {
    return @(
        [pscustomobject]@{ Author = 'PowerShell community'; Message = 'Thank you for a shell that thinks in objects.'; Source = 'Project seed tribute' },
        [pscustomobject]@{ Author = 'Every scripter'; Message = 'Your ideas turned repetitive work into joyful automation.'; Source = 'Project seed tribute' },
        [pscustomobject]@{ Author = 'ThankYouJeffrey'; Message = 'The pipeline keeps carrying the legacy forward.'; Source = 'Project seed tribute' }
    )
}

function Get-DefaultLocales {
    $english = [pscustomobject]@{
        Production = 'A PowerShell Production'
        Presents = 'presents'
        Creator = 'Creator of PowerShell'
        RetirementTribute = '[ A Retirement Tribute ]'
        ProblemYear = '~~ 2002 ~~'
        ManifestoDate = '~~ August 2002 ~~'
        ManifestoTitle = 'THE MONAD MANIFESTO'
        Journey = 'THE JOURNEY'
        Impact = 'THE IMPACT'
        Quotes = 'S N O V E R I S M S'
        CommunityWall = 'COMMUNITY TRIBUTE WALL'
        HappyRetirement = 'HAPPY RETIREMENT'
        ThankYou = 'Thank you, Jeffrey.'
        EnjoyRetirement = 'Enjoy your well-deserved retirement!'
        CommunityWithLove = 'From the PowerShell community, with love.'
        PressAnyKey = 'Press any key to exit, or R to replay...'
        Goodbye = 'Goodbye, and thank you!'
        StatScripts = 'Millions of scripts written'
        StatHours = 'Countless hours saved'
        StatSystems = 'Systems automated worldwide'
        StatCommunity = 'A community united'
        CreditsOne = 'This tribute was created entirely in PowerShell'
        CreditsTwo = 'Because there is no better way to say thank you'
        CreditsThree = 'than with the very tool you created.'
        EasterEggTitle = 'THE PIPELINE KNOWS'
        EasterEggLine = 'Get-Process | Where-Object Legacy -eq Legacy | Thank-You'
    }

    $japanese = [pscustomobject]@{
        Production = 'PowerShell プロダクション'
        Presents = 'お届けします'
        Creator = 'PowerShell の創造者'
        RetirementTribute = '[ 引退記念トリビュート ]'
        ProblemYear = '~~ 2002年 ~~'
        ManifestoDate = '~~ 2002年8月 ~~'
        ManifestoTitle = 'モナド・マニフェスト'
        Journey = '歩み'
        Impact = '影響'
        Quotes = 'スノーバーイズム'
        CommunityWall = 'コミュニティからのメッセージ'
        HappyRetirement = 'ご退職おめでとうございます'
        ThankYou = 'ありがとう、ジェフリー。'
        EnjoyRetirement = '素晴らしい引退生活を！'
        CommunityWithLove = 'PowerShell コミュニティより、感謝をこめて。'
        PressAnyKey = '任意のキーで終了、R で再生...'
        Goodbye = 'さようなら、そしてありがとう！'
        StatScripts = '数えきれないスクリプト'
        StatHours = '節約された無数の時間'
        StatSystems = '世界中のシステムを自動化'
        StatCommunity = 'ひとつになったコミュニティ'
        CreditsOne = 'このトリビュートは PowerShell だけで作られました'
        CreditsTwo = 'あなたが作ったツールで感謝を伝える以上の方法はありません'
        CreditsThree = 'あなたが作った、そのツールで。'
        EasterEggTitle = 'パイプラインは知っている'
        EasterEggLine = 'Get-Process | Where-Object Legacy -eq Legacy | Thank-You'
    }

    $german = [pscustomobject]@{
        Production = 'Eine PowerShell-Produktion'
        Presents = 'präsentiert'
        Creator = 'Schöpfer von PowerShell'
        RetirementTribute = '[ Eine Hommage zum Ruhestand ]'
        ProblemYear = '~~ 2002 ~~'
        ManifestoDate = '~~ August 2002 ~~'
        ManifestoTitle = 'DAS MONAD-MANIFEST'
        Journey = 'DIE REISE'
        Impact = 'DIE WIRKUNG'
        Quotes = 'S N O V E R I S M E N'
        CommunityWall = 'TRIBUTWAND DER COMMUNITY'
        HappyRetirement = 'EINEN SCHÖNEN RUHESTAND'
        ThankYou = 'Danke, Jeffrey.'
        EnjoyRetirement = 'Genieße deinen wohlverdienten Ruhestand!'
        CommunityWithLove = 'Von der PowerShell-Community, mit Liebe.'
        PressAnyKey = 'Beliebige Taste zum Beenden, R zum Wiederholen...'
        Goodbye = 'Auf Wiedersehen und vielen Dank!'
        StatScripts = 'Millionen geschriebene Skripte'
        StatHours = 'Unzählige gesparte Stunden'
        StatSystems = 'Systeme weltweit automatisiert'
        StatCommunity = 'Eine geeinte Community'
        CreditsOne = 'Diese Hommage wurde vollständig in PowerShell erstellt'
        CreditsTwo = 'Denn es gibt keinen besseren Weg, Danke zu sagen'
        CreditsThree = 'als mit dem Werkzeug, das du geschaffen hast.'
        EasterEggTitle = 'DIE PIPELINE WEISS ES'
        EasterEggLine = 'Get-Process | Where-Object Legacy -eq Legacy | Thank-You'
    }

    $portuguese = [pscustomobject]@{
        Production = 'Uma produção PowerShell'
        Presents = 'apresenta'
        Creator = 'Criador do PowerShell'
        RetirementTribute = '[ Uma homenagem à aposentadoria ]'
        ProblemYear = '~~ 2002 ~~'
        ManifestoDate = '~~ Agosto de 2002 ~~'
        ManifestoTitle = 'O MANIFESTO MONAD'
        Journey = 'A JORNADA'
        Impact = 'O IMPACTO'
        Quotes = 'S N O V E R I S M O S'
        CommunityWall = 'MURAL DE HOMENAGENS DA COMUNIDADE'
        HappyRetirement = 'FELIZ APOSENTADORIA'
        ThankYou = 'Obrigado, Jeffrey.'
        EnjoyRetirement = 'Aproveite sua merecida aposentadoria!'
        CommunityWithLove = 'Da comunidade PowerShell, com carinho.'
        PressAnyKey = 'Pressione uma tecla para sair, ou R para repetir...'
        Goodbye = 'Adeus e muito obrigado!'
        StatScripts = 'Milhões de scripts escritos'
        StatHours = 'Incontáveis horas economizadas'
        StatSystems = 'Sistemas automatizados no mundo todo'
        StatCommunity = 'Uma comunidade unida'
        CreditsOne = 'Esta homenagem foi criada inteiramente em PowerShell'
        CreditsTwo = 'Porque não há maneira melhor de agradecer'
        CreditsThree = 'do que com a própria ferramenta que você criou.'
        EasterEggTitle = 'O PIPELINE SABE'
        EasterEggLine = 'Get-Process | Where-Object Legacy -eq Legacy | Thank-You'
    }

    return [pscustomobject]@{ en = $english; ja = $japanese; de = $german; 'pt-br' = $portuguese }
}

function Resolve-Locale {
    $requested = [string]$script:Config.Locale
    if ($requested -ne 'Auto') {
        return $requested.ToLowerInvariant()
    }

    $culture = [string][System.Globalization.CultureInfo]::CurrentUICulture.Name
    if ($culture -like 'ja*') { return 'ja' }
    if ($culture -like 'de*') { return 'de' }
    if ($culture -like 'pt-BR' -or $culture -like 'pt-br') { return 'pt-br' }
    return 'en'
}

function Initialize-Content {
    if ($null -ne $script:Content) {
        return
    }

    $script:Content = @{
        Timeline = Read-JsonBundle -FileName 'timeline.json' -Fallback (Get-DefaultTimeline)
        Snoverisms = Read-JsonBundle -FileName 'snoverisms.json' -Fallback (Get-DefaultSnoverisms)
        Tributes = Read-JsonBundle -FileName 'tributes.json' -Fallback (Get-DefaultTributes)
        Locales = Read-JsonBundle -FileName 'locales.json' -Fallback (Get-DefaultLocales)
    }
    $script:Config.Locale = Resolve-Locale
}

function Get-PropertyValue {
    param(
        [object]$Object,
        [string]$Name
    )

    if ($null -eq $Object) {
        return $null
    }

    $property = $Object.PSObject.Properties[$Name]
    if ($null -ne $property) {
        return $property.Value
    }

    return $null
}

function Get-LocalizedString {
    param([string]$Key)

    Initialize-Content
    $localeTable = Get-PropertyValue -Object $script:Content.Locales -Name $script:Config.Locale
    $value = Get-PropertyValue -Object $localeTable -Name $Key
    if ($null -eq $value) {
        $value = Get-PropertyValue -Object (Get-PropertyValue -Object $script:Content.Locales -Name 'en') -Name $Key
    }
    if ($null -eq $value) {
        return $Key
    }
    return [string]$value
}

function Get-Timeline {
    Initialize-Content
    $value = $script:Content.Timeline
    if ($null -ne (Get-PropertyValue -Object $value -Name 'milestones')) {
        return @($value.milestones)
    }
    return @($value)
}

function Get-Snoverisms {
    Initialize-Content
    $value = $script:Content.Snoverisms
    if ($null -ne (Get-PropertyValue -Object $value -Name 'quotes')) {
        $value = $value.quotes
    }

    return @($value | ForEach-Object {
        [pscustomobject]@{
            Text = [string](Get-PropertyValue -Object $_ -Name 'text')
            Attr = [string](Get-PropertyValue -Object $_ -Name 'attribution')
            Source = [string](Get-PropertyValue -Object $_ -Name 'source')
        }
    } | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Text) })
}

function ConvertTo-SafeTributes {
    param([object]$Value)

    if ($null -ne (Get-PropertyValue -Object $Value -Name 'tributes')) {
        $Value = $Value.tributes
    }

    return @($Value | ForEach-Object {
        $author = [string](Get-PropertyValue -Object $_ -Name 'author')
        $message = [string](Get-PropertyValue -Object $_ -Name 'message')
        $source = [string](Get-PropertyValue -Object $_ -Name 'source')
        if ($author.Length -gt 40) { $author = $author.Substring(0, 40) }
        if ($message.Length -gt 180) { $message = $message.Substring(0, 177) + '...' }
        if (-not [string]::IsNullOrWhiteSpace($author) -and -not [string]::IsNullOrWhiteSpace($message)) {
            [pscustomobject]@{ Author = $author.Trim(); Message = $message.Trim(); Source = $source.Trim() }
        }
    } | Select-Object -First 8)
}

function Get-CommunityTributes {
    Initialize-Content
    if ($script:Config.Online -and -not [string]::IsNullOrWhiteSpace($script:Config.CommunityUri)) {
        try {
            $remote = Invoke-RestMethod -Uri $script:Config.CommunityUri -Method Get -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
            $safeRemote = ConvertTo-SafeTributes -Value $remote
            if (@($safeRemote).Count -gt 0) {
                return $safeRemote
            }
        } catch {
            # Network failures never interrupt the local tribute experience.
        }
    }

    return ConvertTo-SafeTributes -Value $script:Content.Tributes
}

function Get-MonadManifesto {
    [CmdletBinding()]
    param(
        [ValidateRange(1, 99)]
        [int]$Page = 1,
        [switch]$All,
        [switch]$AsText
    )

    $manifesto = Read-JsonBundle -FileName 'manifesto.json' -Fallback ([pscustomobject]@{
            source = 'https://www.jsnover.com/Docs/MonadManifesto.pdf'
            pages = @(
                [pscustomobject]@{ page = 1; heading = 'The problem'; text = 'System administration was becoming a software problem, but the available tools still treated machines as text to parse.' }
                [pscustomobject]@{ page = 2; heading = 'The idea'; text = 'Monad imagined a task-based shell whose commands compose through objects and a pipeline, making automation easier to reason about.' }
                [pscustomobject]@{ page = 3; heading = 'The legacy'; text = 'That vision became PowerShell: a language, a shell, and a community built around making administrators more effective.' }
            )
        })

    $pages = @($manifesto.pages)
    if (-not $All) {
        $pages = @($pages | Where-Object { [int]$_.page -eq $Page })
    }

    $result = @($pages | ForEach-Object {
        [pscustomobject]@{
            Page = [int]$_.page
            Heading = [string]$_.heading
            Text = [string]$_.text
            Source = [string]$manifesto.source
        }
    })

    if ($AsText) {
        foreach ($entry in $result) {
            "[$($entry.Page)] $($entry.Heading)"
            $entry.Text
            "Source: $($entry.Source)"
            ''
        }
        return
    }

    return $result
}

function Get-Snoverism {
    [CmdletBinding()]
    param(
        [ValidateRange(0, 999)]
        [int]$Index = -1
    )

    $quotes = @(Get-Snoverisms)
    if ($quotes.Count -eq 0) {
        return
    }

    if ($Index -lt 0) {
        $Index = Get-Random -Minimum 0 -Maximum $quotes.Count
    } else {
        $Index = $Index % $quotes.Count
    }

    return $quotes[$Index]
}

function Invoke-PowerShellTimeline {
    [CmdletBinding()]
    param([switch]$AsText)

    $timeline = Get-Timeline | Select-Object Year, Event, Source
    if ($AsText) {
        foreach ($entry in $timeline) {
            "[$($entry.Year)] $($entry.Event)"
        }
        return
    }

    return $timeline
}

function New-QuoteOfTheDay {
    [CmdletBinding()]
    param(
        [datetime]$Date = (Get-Date),
        [ValidateRange(0, 999)]
        [int]$Index = -1
    )

    $quote = Get-Snoverism -Index $Index
    if ($null -eq $quote) {
        return
    }

    $dateText = $Date.ToString('yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture)
    @(
        "## PowerShell quote of the day — $dateText"
        ''
        "> $($quote.Text)"
        ''
        "— $($quote.Attr.TrimStart('-').Trim())"
        ''
        "Source: $($quote.Source)"
    ) -join "`n"
}

function Send-ThankYouEmail {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$To = '',
        [string]$Subject = 'Thank you, Jeffrey Snover',
        [string]$Message = 'Thank you for creating PowerShell and for showing us a better way to automate.',
        [switch]$Open
    )

    $mailTo = "mailto:$($To)?subject=$([uri]::EscapeDataString($Subject))&body=$([uri]::EscapeDataString($Message))"
    $draft = [pscustomobject]@{
        To = $To
        Subject = $Subject
        Message = $Message
        MailTo = $mailTo
        Opened = $false
    }

    if ($Open -and $PSCmdlet.ShouldProcess($mailTo, 'Open an email draft')) {
        try {
            Start-Process -FilePath $mailTo -ErrorAction Stop
            $draft.Opened = $true
        } catch {
            Write-Error "Unable to open the default mail client: $($_.Exception.Message)"
        }
    }

    return $draft
}

function Get-ThankJeffreyShareUrl {
    [CmdletBinding()]
    param(
        [string]$Message = 'Thank you, Jeffrey Snover, for creating PowerShell and changing how we automate.'
    )

    return "https://twitter.com/intent/tweet?text=$([uri]::EscapeDataString($Message))&url=$([uri]::EscapeDataString('https://github.com/SysAdminDoc/ThankYouJeffrey'))"
}

function Get-ThankYouJeffreyAbout {
    [CmdletBinding()]
    param()

    return [pscustomobject]@{
        Name = 'Thank You Jeffrey'
        Version = $script:Version
        Description = 'A cinematic PowerShell tribute to Jeffrey Snover.'
        PowerShellVersion = $PSVersionTable.PSVersion.ToString()
        ProjectUri = 'https://github.com/SysAdminDoc/ThankYouJeffrey'
    }
}

function Invoke-ThankJeffrey {
    [CmdletBinding(SupportsShouldProcess)]
    param([switch]$Open)

    $shareUrl = Get-ThankJeffreyShareUrl
    if ($Open -and $PSCmdlet.ShouldProcess($shareUrl, 'Open a thank-you post draft')) {
        try {
            Start-Process -FilePath $shareUrl -ErrorAction Stop
        } catch {
            Write-Error "Unable to open the default browser: $($_.Exception.Message)"
        }
    }

    return [pscustomobject]@{
        Url = $shareUrl
        Opened = $Open.IsPresent
    }
}

# ============================================================================
# AUDIO SYSTEM - Musical Notes and Sound Effects
# ============================================================================

# Musical note frequencies (Hz) - Standard tuning
$script:Notes = @{
    # Octave 3
    C3  = 131;  Cs3 = 139;  D3  = 147;  Ds3 = 156;  E3  = 165;  F3  = 175
    Fs3 = 185;  G3  = 196;  Gs3 = 208;  A3  = 220;  As3 = 233;  B3  = 247
    # Octave 4 (Middle)
    C4  = 262;  Cs4 = 277;  D4  = 294;  Ds4 = 311;  E4  = 330;  F4  = 349
    Fs4 = 370;  G4  = 392;  Gs4 = 415;  A4  = 440;  As4 = 466;  B4  = 494
    # Octave 5
    C5  = 523;  Cs5 = 554;  D5  = 587;  Ds5 = 622;  E5  = 659;  F5  = 698
    Fs5 = 740;  G5  = 784;  Gs5 = 831;  A5  = 880;  As5 = 932;  B5  = 988
    # Octave 6
    C6  = 1047; Cs6 = 1109; D6  = 1175; Ds6 = 1245; E6  = 1319; F6  = 1397
    # Rest (silence handled specially)
    R   = 0
}

function Play-Note {
    param(
        [string]$Note,
        [int]$Duration = 200
    )
    if (-not $script:Config.EnableSound) { return }
    
    try {
        $freq = $script:Notes[$Note]
        if ($freq -and $freq -gt 0) {
            [Console]::Beep($freq, $Duration)
        } elseif ($Note -eq 'R') {
            Wait-Animation -Milliseconds $Duration
        }
    } catch {
        # Silently fail if beep not supported
    }
}

function Play-Melody {
    param(
        [array]$Notes,  # Array of @{Note='C4'; Duration=200}
        [int]$Tempo = 1  # Tempo multiplier
    )
    if (-not $script:Config.EnableSound) { return }
    
    foreach ($n in $Notes) {
        $duration = [Math]::Floor($n.Duration / $Tempo)
        Play-Note -Note $n.Note -Duration $duration
    }
}

function Play-Fanfare {
    # Triumphant opening fanfare
    if (-not $script:Config.EnableSound) { return }
    
    $fanfare = @(
        @{Note='C4'; Duration=150},
        @{Note='E4'; Duration=150},
        @{Note='G4'; Duration=150},
        @{Note='C5'; Duration=300},
        @{Note='R'; Duration=100},
        @{Note='G4'; Duration=100},
        @{Note='C5'; Duration=400}
    )
    Play-Melody -Notes $fanfare
}

function Play-TransitionUp {
    # Rising transition sound
    if (-not $script:Config.EnableSound) { return }
    
    $notes = @('C4', 'D4', 'E4', 'F4', 'G4')
    foreach ($note in $notes) {
        Play-Note -Note $note -Duration 50
    }
}

function Play-TransitionDown {
    # Falling transition sound
    if (-not $script:Config.EnableSound) { return }
    
    $notes = @('G4', 'F4', 'E4', 'D4', 'C4')
    foreach ($note in $notes) {
        Play-Note -Note $note -Duration 50
    }
}

function Play-Whoosh {
    # Quick whoosh effect (ascending)
    if (-not $script:Config.EnableSound) { return }
    
    for ($freq = 200; $freq -le 800; $freq += 100) {
        try { [Console]::Beep($freq, 30) } catch {}
    }
}

function Play-TypewriterClick {
    # Single typewriter key sound
    if (-not $script:Config.EnableSound) { return }
    
    try { [Console]::Beep(1200, 10) } catch {}
}

function Play-TypewriterReturn {
    # Typewriter carriage return sound
    if (-not $script:Config.EnableSound) { return }
    
    try {
        [Console]::Beep(800, 30)
        [Console]::Beep(600, 50)
    } catch {}
}

function Play-Sparkle {
    # Magical sparkle effect
    if (-not $script:Config.EnableSound) { return }
    
    $sparkle = @(
        @{Note='E5'; Duration=50},
        @{Note='G5'; Duration=50},
        @{Note='B5'; Duration=50},
        @{Note='E6'; Duration=100}
    )
    Play-Melody -Notes $sparkle
}

function Play-FireworkLaunch {
    # Firework launch whistle
    if (-not $script:Config.EnableSound) { return }
    
    for ($freq = 300; $freq -le 1500; $freq += 150) {
        try { [Console]::Beep($freq, 15) } catch {}
    }
}

function Play-FireworkBurst {
    # Firework explosion crackle
    if (-not $script:Config.EnableSound) { return }
    
    $random = New-Object System.Random
    for ($i = 0; $i -lt 5; $i++) {
        $freq = $random.Next(800, 2000)
        try { [Console]::Beep($freq, 20) } catch {}
    }
}

function Play-TimelineTick {
    # Timeline milestone sound
    if (-not $script:Config.EnableSound) { return }
    
    try { [Console]::Beep(600, 80) } catch {}
}

function Play-Heartbeat {
    # Dramatic heartbeat
    if (-not $script:Config.EnableSound) { return }
    
    try {
        [Console]::Beep(100, 100)
        Wait-Animation -Milliseconds 100
        [Console]::Beep(100, 150)
    } catch {}
}

function Play-VictoryTheme {
    # Celebratory victory melody
    if (-not $script:Config.EnableSound) { return }
    
    $victory = @(
        # "Celebration" style riff
        @{Note='C4'; Duration=150},
        @{Note='C4'; Duration=150},
        @{Note='C4'; Duration=150},
        @{Note='C4'; Duration=400},
        @{Note='Gs3'; Duration=400},
        @{Note='As3'; Duration=400},
        @{Note='C4'; Duration=200},
        @{Note='R'; Duration=100},
        @{Note='As3'; Duration=150},
        @{Note='C4'; Duration=500}
    )
    Play-Melody -Notes $victory
}

function Play-EmotionalTheme {
    # Touching, emotional melody for the thank you section
    if (-not $script:Config.EnableSound) { return }
    
    $theme = @(
        @{Note='E4'; Duration=400},
        @{Note='G4'; Duration=400},
        @{Note='A4'; Duration=600},
        @{Note='G4'; Duration=300},
        @{Note='E4'; Duration=300},
        @{Note='D4'; Duration=600},
        @{Note='R'; Duration=200},
        @{Note='E4'; Duration=400},
        @{Note='G4'; Duration=400},
        @{Note='A4'; Duration=400},
        @{Note='B4'; Duration=400},
        @{Note='C5'; Duration=800}
    )
    Play-Melody -Notes $theme
}

function Play-PowerShellTheme {
    # A little "PowerShell signature" jingle
    if (-not $script:Config.EnableSound) { return }
    
    $theme = @(
        # P-S rhythm
        @{Note='G4'; Duration=150},
        @{Note='R'; Duration=50},
        @{Note='G4'; Duration=150},
        @{Note='R'; Duration=50},
        @{Note='A4'; Duration=200},
        @{Note='G4'; Duration=200},
        @{Note='R'; Duration=100},
        @{Note='B4'; Duration=300},
        @{Note='A4'; Duration=500}
    )
    Play-Melody -Notes $theme
}

function Play-ClosingFanfare {
    # Grand closing fanfare
    if (-not $script:Config.EnableSound) { return }
    
    $closing = @(
        @{Note='G4'; Duration=200},
        @{Note='G4'; Duration=200},
        @{Note='G4'; Duration=200},
        @{Note='Ds4'; Duration=600},
        @{Note='R'; Duration=100},
        @{Note='F4'; Duration=200},
        @{Note='F4'; Duration=200},
        @{Note='F4'; Duration=200},
        @{Note='D4'; Duration=600},
        @{Note='R'; Duration=200},
        # Final triumphant notes
        @{Note='C4'; Duration=200},
        @{Note='E4'; Duration=200},
        @{Note='G4'; Duration=200},
        @{Note='C5'; Duration=300},
        @{Note='E5'; Duration=300},
        @{Note='G5'; Duration=600}
    )
    Play-Melody -Notes $closing
}

# Color palette
$script:Colors = @{
    PowerShellBlue = 'Cyan'
    Accent         = 'Yellow'
    Highlight      = 'White'
    Dim            = 'DarkGray'
    Success        = 'Green'
    Timeline       = 'Magenta'
    Fire           = 'Red'
    Gold           = 'Yellow'
}

$script:AnsiColors = @{
    Black     = @(0, 0, 0)
    DarkGray  = @(85, 85, 85)
    Gray      = @(192, 192, 192)
    White     = @(255, 255, 255)
    Red       = @(205, 49, 49)
    DarkRed   = @(139, 0, 0)
    Green     = @(13, 188, 121)
    DarkGreen = @(0, 100, 0)
    Yellow    = @(229, 229, 16)
    DarkYellow = @(128, 128, 0)
    Blue      = @(36, 114, 200)
    DarkBlue  = @(0, 0, 139)
    Magenta   = @(188, 63, 188)
    DarkMagenta = @(139, 0, 139)
    Cyan      = @(17, 168, 205)
    DarkCyan  = @(0, 139, 139)
}

function ConvertTo-Ansi256Code {
    param([int[]]$Rgb)

    $levels = @(0, 95, 135, 175, 215, 255)
    $indexes = foreach ($channel in $Rgb) {
        $nearest = 0
        $distance = [int]::MaxValue
        for ($i = 0; $i -lt $levels.Count; $i++) {
            $candidateDistance = [Math]::Abs($channel - $levels[$i])
            if ($candidateDistance -lt $distance) {
                $distance = $candidateDistance
                $nearest = $i
            }
        }
        $nearest
    }

    return 16 + (36 * $indexes[0]) + (6 * $indexes[1]) + $indexes[2]
}

function Write-ConsoleText {
    param(
        [AllowNull()]
        [string]$Text,
        [ConsoleColor]$Color = 'White',
        [switch]$NoNewline
    )

    if ($script:Config.ColorMode -eq 'TrueColor' -or $script:Config.ColorMode -eq 'Ansi256') {
        $rgb = $script:AnsiColors[[string]$Color]
        if ($null -eq $rgb) {
            $rgb = $script:AnsiColors.White
        }

        if ($script:Config.ColorMode -eq 'TrueColor') {
            $prefix = "`e[38;2;$($rgb[0]);$($rgb[1]);$($rgb[2])m"
        } else {
            $prefix = "`e[38;5;$(ConvertTo-Ansi256Code -Rgb $rgb)m"
        }

        $suffix = "`e[0m"
        if ($NoNewline) {
            [Console]::Write($prefix + $Text + $suffix)
        } else {
            [Console]::WriteLine($prefix + $Text + $suffix)
        }
        return
    }

    Write-Host $Text -ForegroundColor $Color -NoNewline:$NoNewline
}

# ============================================================================
# CONSOLE SETUP
# ============================================================================

function Initialize-Console {
    Initialize-Pacing
    Initialize-Content
    $script:OriginalBg = $null
    $script:OriginalFg = $null
    $script:OriginalCursor = $true

    if (-not $script:Config.IsInteractive) {
        return
    }

    try {
        $script:OriginalBg = $Host.UI.RawUI.BackgroundColor
        $script:OriginalFg = $Host.UI.RawUI.ForegroundColor
        $script:OriginalCursor = [Console]::CursorVisible
        [Console]::CursorVisible = $false
        $Host.UI.RawUI.BackgroundColor = 'Black'
        $Host.UI.RawUI.ForegroundColor = 'White'
    } catch {
        # Continue with the host's current console settings.
    }

    Clear-Console
}

function Restore-Console {
    if (-not $script:Config.IsInteractive) {
        return
    }

    try {
        [Console]::CursorVisible = $script:OriginalCursor
        if ($null -ne $script:OriginalBg) {
            $Host.UI.RawUI.BackgroundColor = $script:OriginalBg
        }
        if ($null -ne $script:OriginalFg) {
            $Host.UI.RawUI.ForegroundColor = $script:OriginalFg
        }
        Clear-Console
    } catch {
        # Restoration is best effort across console hosts.
    }
}

function Clear-Console {
    if (-not $script:Config.IsInteractive) {
        return
    }

    try {
        Clear-Host
    } catch {
        # A redirected host may reject clear-screen operations.
    }
}

# ============================================================================
# ANIMATION UTILITIES
# ============================================================================

function Set-CursorPosition {
    param([int]$X, [int]$Y)
    if (-not $script:Config.IsInteractive) {
        return
    }

    try {
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates($X, $Y)
    } catch {
        # Redirected output cannot position a cursor.
    }
}

function Write-Centered {
    param(
        [string]$Text,
        [int]$Y,
        [ConsoleColor]$Color = 'White'
    )
    $width = $script:Config.ConsoleWidth
    $x = [Math]::Max(0, [Math]::Floor(($width - $Text.Length) / 2))
    Set-CursorPosition -X $x -Y $Y
    Write-ConsoleText -Text $Text -Color $Color -NoNewline
}

function Write-Typewriter {
    param(
        [string]$Text,
        [int]$X,
        [int]$Y,
        [ConsoleColor]$Color = 'White',
        [int]$Delay = $script:Config.TypewriterDelay,
        [switch]$WithSound
    )
    Set-CursorPosition -X $X -Y $Y
    foreach ($char in $Text.ToCharArray()) {
        Write-ConsoleText -Text $char -Color $Color -NoNewline
        if ($WithSound -and $char -match '\S') {
            Play-TypewriterClick
        }
        Wait-Animation -Milliseconds $Delay
        if ($script:Config.SkipToEnd) {
            break
        }
    }
}

function Write-TypewriterCentered {
    param(
        [string]$Text,
        [int]$Y,
        [ConsoleColor]$Color = 'White',
        [int]$Delay = $script:Config.TypewriterDelay,
        [switch]$WithSound
    )
    $width = $script:Config.ConsoleWidth
    $x = [Math]::Max(0, [Math]::Floor(($width - $Text.Length) / 2))
    Write-Typewriter -Text $Text -X $x -Y $Y -Color $Color -Delay $Delay -WithSound:$WithSound
}

function Write-FadeIn {
    param(
        [string[]]$Lines,
        [int]$StartY,
        [ConsoleColor]$Color = 'White'
    )
    
    $colors = @('DarkGray', 'Gray', $Color)
    
    foreach ($fadeColor in $colors) {
        $y = $StartY
        foreach ($line in $Lines) {
            Write-Centered -Text $line -Y $y -Color $fadeColor
            $y++
        }
        Wait-Animation -Milliseconds 150
    }
}

function Clear-Line {
    param([int]$Y)
    $width = $script:Config.ConsoleWidth
    Set-CursorPosition -X 0 -Y $Y
    Write-ConsoleText -Text (' ' * $width) -NoNewline
}

function Show-ProgressBar {
    param(
        [int]$Y,
        [int]$Duration = 2000,
        [string]$Label = "Loading",
        [ConsoleColor]$Color = 'Cyan'
    )
    
    $width = 40
    $x = [Math]::Floor(($script:Config.ConsoleWidth - $width - 2) / 2)
    $steps = 20
    $stepDelay = $Duration / $steps
    
    Write-Centered -Text $Label -Y ($Y - 1) -Color 'DarkGray'
    
    for ($i = 0; $i -le $steps; $i++) {
        $filled = [Math]::Floor(($i / $steps) * $width)
        $empty = $width - $filled
        $bar = "[" + ("=" * $filled) + (" " * $empty) + "]"
        Set-CursorPosition -X $x -Y $Y
        Write-ConsoleText -Text $bar -Color $Color -NoNewline
        Wait-Animation -Milliseconds $stepDelay
    }
}

# ============================================================================
# ASCII ART
# ============================================================================

$script:Art = @{

PowerShellLogo = @'
                                                                        
    ____                        ____  _          _ _                    
   |  _ \ _____      _____ _ __/ ___|| |__   ___| | |                   
   | |_) / _ \ \ /\ / / _ \ '__\___ \| '_ \ / _ \ | |                   
   |  __/ (_) \ V  V /  __/ |   ___) | | | |  __/ | |                   
   |_|   \___/ \_/\_/ \___|_|  |____/|_| |_|\___|_|_|                   
                                                                        
'@

JeffreyName = @'
       _      __  __                   ____                             
      | | ___|  \/  | __ ___  ___ _ __/ ___| _ __   _____   _____ _ __  
   _  | |/ _ \ |\/| |/ _` \ \/ / '__\___ \| '_ \ / _ \ \ / / _ \ '__| 
  | |_| |  __/ |  | | (_| |>  <| |   ___) | | | | (_) \ V /  __/ |    
   \___/ \___|_|  |_|\__,_/_/\_\_|  |____/|_| |_|\___/ \_/ \___|_|    
'@

MonadLogo = @'
    __  __                       _ 
   |  \/  | ___  _ __   __ _  __| |
   | |\/| |/ _ \| '_ \ / _` |/ _` |
   | |  | | (_) | | | | (_| | (_| |
   |_|  |_|\___/|_| |_|\__,_|\__,_|
'@

ThankYou = @'
  _____ _                 _     __   __          
 |_   _| |__   __ _ _ __ | | __ \ \ / /__  _   _ 
   | | | '_ \ / _` | '_ \| |/ /  \ V / _ \| | | |
   | | | | | | (_| | | | |   <    | | (_) | |_| |
   |_| |_| |_|\__,_|_| |_|_|\_\   |_|\___/ \__,_|
'@

Firework1 = @'
       .
      /|\
     / | \
    '  |  '
   '   |   '
  *    |    *
       |
'@

Firework2 = @'
    \  |  /
     \ | /
    --   --
     / | \
    /  |  \
'@

Star = @'
    *
   /|\
  / | \
 *--+--*
  \ | /
   \|/
    *
'@

Prompt = @'
PS C:\> _
'@

}

# ============================================================================
# SCENE: OPENING
# ============================================================================

function Show-Opening {
    Clear-Console
    $height = $script:Config.ConsoleHeight
    $centerY = [Math]::Floor($height / 2) - 3
    
    # Opening fanfare
    Play-Fanfare
    
    # Fade in "A PowerShell Production"
    Wait-Animation -Milliseconds 500
    Write-TypewriterCentered -Text (Get-LocalizedString -Key 'Production') -Y $centerY -Color 'DarkGray' -Delay 50 -WithSound
    Play-TypewriterReturn
    Wait-Animation -Milliseconds 1500
    
    Play-TransitionDown
    Clear-Console
    Wait-Animation -Milliseconds 300
    
    # Fade in "Presents"
    Write-TypewriterCentered -Text (Get-LocalizedString -Key 'Presents') -Y $centerY -Color 'DarkGray' -Delay 80 -WithSound
    Play-Sparkle
    Wait-Animation -Milliseconds 1500
    
    Play-Whoosh
    Clear-Console
}

# ============================================================================
# SCENE: TITLE
# ============================================================================

function Show-Title {
    Clear-Console
    $height = $script:Config.ConsoleHeight
    $lines = $script:Art.ThankYou -split "`n"
    $startY = [Math]::Floor($height / 2) - [Math]::Floor($lines.Count / 2) - 2
    
    Wait-Animation -Milliseconds 500
    
    # Draw title with fade effect
    Write-FadeIn -Lines $lines -StartY $startY -Color 'Yellow'
    Play-PowerShellTheme
    
    Wait-Animation -Milliseconds 500
    
    # Subtitle
    $subtitleY = $startY + $lines.Count + 2
    Write-TypewriterCentered -Text "Jeffrey Snover" -Y $subtitleY -Color 'Cyan' -Delay 60 -WithSound
    Play-Sparkle
    
    Wait-Animation -Milliseconds 300
    Write-TypewriterCentered -Text (Get-LocalizedString -Key 'Creator') -Y ($subtitleY + 2) -Color 'White' -Delay 40
    
    Wait-Animation -Milliseconds 300
    Write-TypewriterCentered -Text (Get-LocalizedString -Key 'RetirementTribute') -Y ($subtitleY + 4) -Color 'DarkGray' -Delay 30
    
    Wait-Animation -Milliseconds $script:Config.SceneDelay
}

# ============================================================================
# SCENE: THE PROBLEM (2002)
# ============================================================================

function Show-TheProblem {
    Clear-Console
    $height = $script:Config.ConsoleHeight
    $y = 3
    
    # Year header
    Play-TransitionUp
    Write-Centered -Text (Get-LocalizedString -Key 'ProblemYear') -Y $y -Color 'Magenta'
    $y += 3
    
    # Scene setting
    Write-TypewriterCentered -Text "Microsoft. Building 42." -Y $y -Color 'DarkGray' -Delay 40 -WithSound
    $y += 2
    Write-TypewriterCentered -Text "A systems architect stares at his screen..." -Y $y -Color 'DarkGray' -Delay 30
    $y += 4
    
    # The frustration - with heartbeat for tension
    $cmdLines = @(
        'C:\> dir /s /b *.log | find "error"',
        'C:\> for /f "tokens=1,2" %a in (file.txt) do @echo %a',
        'C:\> if exist "file.txt" (echo yes) else (echo no)'
    )
    
    foreach ($line in $cmdLines) {
        Write-Centered -Text $line -Y $y -Color 'Gray'
        Play-Heartbeat
        Wait-Animation -Milliseconds 200
        $y += 1
    }
    
    $y += 2
    Play-Sparkle
    Write-TypewriterCentered -Text '"There has to be a better way..."' -Y $y -Color 'Yellow' -Delay 50 -WithSound
    
    $y += 3
    Write-TypewriterCentered -Text "Windows needed a real shell." -Y $y -Color 'White' -Delay 40
    $y += 1
    Write-TypewriterCentered -Text "One that understood objects, not just text." -Y $y -Color 'White' -Delay 40
    $y += 1
    Play-TransitionUp
    Write-TypewriterCentered -Text "One built for the future." -Y $y -Color 'Cyan' -Delay 40
    
    Wait-Animation -Milliseconds $script:Config.SceneDelay
}

# ============================================================================
# SCENE: THE MANIFESTO
# ============================================================================

function Show-TheManifesto {
    Clear-Console
    $height = $script:Config.ConsoleHeight
    $y = 3
    
    Play-Whoosh
    Write-Centered -Text (Get-LocalizedString -Key 'ManifestoDate') -Y $y -Color 'Magenta'
    $y += 3
    
    Write-TypewriterCentered -Text "Jeffrey Snover writes..." -Y $y -Color 'DarkGray' -Delay 40 -WithSound
    $y += 3
    
    # Monad logo fade in
    $monadLines = $script:Art.MonadLogo -split "`n"
    Write-FadeIn -Lines $monadLines -StartY $y -Color 'Cyan'
    Play-Sparkle
    $y += $monadLines.Count + 2
    
    Write-TypewriterCentered -Text (Get-LocalizedString -Key 'ManifestoTitle') -Y $y -Color 'Yellow' -Delay 60 -WithSound
    Play-VictoryTheme
    $y += 3
    
    # Key quotes from the manifesto
    $quotes = @(
        '"Automating the management of systems..."',
        '"A new approach based on objects and pipelines..."',
        '"The future of Windows administration."'
    )
    
    foreach ($quote in $quotes) {
        Write-TypewriterCentered -Text $quote -Y $y -Color 'White' -Delay 25
        Play-TimelineTick
        $y += 2
        Wait-Animation -Milliseconds 300
    }
    
    Wait-Animation -Milliseconds $script:Config.SceneDelay
}

# ============================================================================
# SCENE: THE JOURNEY (Timeline)
# ============================================================================

function Show-Timeline {
    Clear-Console
    $y = 2
    
    Play-TransitionUp
    Write-Centered -Text (Get-LocalizedString -Key 'Journey') -Y $y -Color 'Yellow'
    $y += 3
    
    $timeline = Get-Timeline
    
    foreach ($item in $timeline) {
        $yearText = "[ $($item.Year) ]"
        $width = $script:Config.ConsoleWidth
        $lineX = [Math]::Floor($width / 2) - 30
        
        # Sound for each milestone
        Play-TimelineTick
        
        # Draw timeline marker
        Set-CursorPosition -X $lineX -Y $y
        Write-ConsoleText -Text $yearText -Color 'Magenta' -NoNewline
        
        # Draw event with typewriter
        Set-CursorPosition -X ($lineX + 12) -Y $y
        foreach ($char in $item.Event.ToCharArray()) {
            Write-ConsoleText -Text $char -Color $item.Color -NoNewline
            Wait-Animation -Milliseconds 15
            if ($script:Config.SkipToEnd) {
                break
            }
        }
        
        # Special sounds for major events
        if ($item.Event -like "*OPEN SOURCE*") {
            Play-Sparkle
        }
        if ($item.Event -like "*retires*") {
            Play-EmotionalTheme
        }
        
        # Draw connecting line
        if ($item -ne $timeline[-1]) {
            $y++
            Set-CursorPosition -X ($lineX + 4) -Y $y
            Write-ConsoleText -Text "|" -Color 'DarkGray'
        }
        
        $y++
        Wait-Animation -Milliseconds 100
    }
    
    Wait-Animation -Milliseconds $script:Config.SceneDelay
}

# ============================================================================
# SCENE: THE IMPACT
# ============================================================================

function Show-Impact {
    Clear-Console
    $y = 3
    
    Play-Whoosh
    Write-Centered -Text (Get-LocalizedString -Key 'Impact') -Y $y -Color 'Yellow'
    $y += 4
    
    # PowerShell logo
    $logoLines = $script:Art.PowerShellLogo -split "`n"
    Write-FadeIn -Lines $logoLines -StartY $y -Color 'Cyan'
    Play-PowerShellTheme
    $y += $logoLines.Count + 2
    
    $stats = @(
        (Get-LocalizedString -Key 'StatScripts'),
        (Get-LocalizedString -Key 'StatHours'),
        (Get-LocalizedString -Key 'StatSystems'),
        (Get-LocalizedString -Key 'StatCommunity')
    )
    
    foreach ($stat in $stats) {
        Play-TimelineTick
        Write-TypewriterCentered -Text ">> $stat" -Y $y -Color 'White' -Delay 25
        $y += 2
        Wait-Animation -Milliseconds 200
    }
    
    $y += 1
    Play-VictoryTheme
    Write-TypewriterCentered -Text "One shell to rule them all." -Y $y -Color 'Green' -Delay 50 -WithSound
    
    Wait-Animation -Milliseconds $script:Config.SceneDelay
}

# ============================================================================
# SCENE: QUOTES
# ============================================================================

function Show-Quotes {
    Clear-Console
    $height = $script:Config.ConsoleHeight

    $quotes = Get-Snoverisms
    Write-Centered -Text (Get-LocalizedString -Key 'Quotes') -Y 2 -Color 'Yellow'
    
    foreach ($quote in $quotes) {
        Play-TransitionUp
        Clear-Console
        $y = [Math]::Floor($height / 2) - 2
        
        Write-TypewriterCentered -Text ('"' + $quote.Text + '"') -Y $y -Color 'White' -Delay 35 -WithSound
        Play-Sparkle
        Wait-Animation -Milliseconds 400
        Write-TypewriterCentered -Text $quote.Attr -Y ($y + 3) -Color 'DarkGray' -Delay 40
        
        Wait-Animation -Milliseconds 2000
    }
}

function Show-CommunityWall {
    $tributes = @(Get-CommunityTributes)
    if ($tributes.Count -eq 0) {
        return
    }

    Clear-Console
    Write-Centered -Text (Get-LocalizedString -Key 'CommunityWall') -Y 2 -Color 'Yellow'
    $y = 5
    foreach ($tribute in $tributes) {
        if ($y -ge ($script:Config.ConsoleHeight - 3) -or $script:Config.SkipToEnd) {
            break
        }

        $line = "[$($tribute.Author)] $($tribute.Message)"
        $maxLength = [Math]::Max(20, $script:Config.ConsoleWidth - 8)
        if ($line.Length -gt $maxLength) {
            $line = $line.Substring(0, $maxLength - 3) + '...'
        }
        Write-TypewriterCentered -Text $line -Y $y -Color 'White' -Delay 15
        $y += 2
        Wait-Animation -Milliseconds 250
    }

    Wait-Animation -Milliseconds $script:Config.SceneDelay
}

# ============================================================================
# SCENE: FIREWORKS
# ============================================================================

function Show-Fireworks {
    param([int]$Duration = 5000)

    if (-not $script:Config.IsInteractive -or $script:Config.SuppressDelays) {
        $Duration = 0
    }
    
    $width = $script:Config.ConsoleWidth
    $height = $script:Config.ConsoleHeight
    $endTime = (Get-Date).AddMilliseconds($Duration)
    
    $particles = @()
    $colors = @('Red', 'Yellow', 'Green', 'Cyan', 'Magenta', 'White')
    $chars = @('*', '.', '+', 'o', "'", '`')
    
    $frameCount = 0
    
    while ((Get-Date) -lt $endTime -and -not $script:Config.SkipToEnd) {
        $frameCount++
        
        # Spawn new firework
        if ((Get-Random -Maximum 100) -lt 30) {
            $burstX = Get-Random -Minimum 10 -Maximum ($width - 10)
            $burstY = Get-Random -Minimum 3 -Maximum ([Math]::Floor($height / 2))
            $color = $colors | Get-Random
            
            # Play launch sound occasionally (not every time to avoid audio overload)
            if ($frameCount % 3 -eq 0) {
                Play-FireworkBurst
            }
            
            # Create burst particles
            for ($i = 0; $i -lt 8; $i++) {
                $angle = ($i / 8) * 2 * [Math]::PI
                $particles += @{
                    X = $burstX
                    Y = $burstY
                    VX = [Math]::Cos($angle) * (1 + (Get-Random -Maximum 10) / 10)
                    VY = [Math]::Sin($angle) * 0.5
                    Life = 10 + (Get-Random -Maximum 10)
                    Color = $color
                    Char = $chars | Get-Random
                }
            }
        }
        
        # Clear old positions and update particles
        $newParticles = @()
        foreach ($p in $particles) {
            # Clear old position
            if ($p.X -ge 0 -and $p.X -lt $width -and $p.Y -ge 0 -and $p.Y -lt $height) {
                Set-CursorPosition -X ([int]$p.X) -Y ([int]$p.Y)
                Write-ConsoleText -Text ' ' -NoNewline
            }
            
            # Update position
            $p.X += $p.VX
            $p.Y += $p.VY
            $p.VY += 0.1  # Gravity
            $p.Life--
            
            # Draw new position
            if ($p.Life -gt 0 -and $p.X -ge 0 -and $p.X -lt $width -and $p.Y -ge 0 -and $p.Y -lt $height) {
                Set-CursorPosition -X ([int]$p.X) -Y ([int]$p.Y)
                Write-ConsoleText -Text $p.Char -Color $p.Color -NoNewline
                $newParticles += $p
            }
        }
        $particles = $newParticles
        
        Wait-Animation -Milliseconds 50
    }
}

# ============================================================================
# SCENE: FINALE
# ============================================================================

function Show-Finale {
    Clear-Console
    $width = $script:Config.ConsoleWidth
    $height = $script:Config.ConsoleHeight
    $centerY = [Math]::Floor($height / 2)
    
    # First, show the message
    Play-VictoryTheme
    Write-Centered -Text (Get-LocalizedString -Key 'HappyRetirement') -Y ($centerY - 5) -Color 'Yellow'
    
    $nameLines = $script:Art.JeffreyName -split "`n"
    $nameY = $centerY - 3
    foreach ($line in $nameLines) {
        Write-Centered -Text $line -Y $nameY -Color 'Cyan'
        $nameY++
    }
    
    Wait-Animation -Milliseconds 1000
    
    # Fireworks!
    Show-Fireworks -Duration 5000
    
    # Final message with emotional theme
    Clear-Console
    
    Play-EmotionalTheme
    
    $finalY = [Math]::Floor($height / 2) - 6
    
    Write-Centered -Text (Get-LocalizedString -Key 'ThankYou') -Y $finalY -Color 'Yellow'
    $finalY += 3
    
    $messages = @(
        "For giving us PowerShell.",
        "For changing how we work.",
        "For making automation accessible.",
        "For building a community.",
        "For 20+ years of innovation."
    )
    
    foreach ($msg in $messages) {
        Play-TimelineTick
        Write-Centered -Text $msg -Y $finalY -Color 'White'
        $finalY++
        Wait-Animation -Milliseconds 600
    }
    
    $finalY += 2
    Play-Sparkle
    Write-Centered -Text (Get-LocalizedString -Key 'EnjoyRetirement') -Y $finalY -Color 'Green'
    
    $finalY += 3
    Write-Centered -Text "---" -Y $finalY -Color 'DarkGray'
    $finalY += 2
    Write-Centered -Text (Get-LocalizedString -Key 'CommunityWithLove') -Y $finalY -Color 'Cyan'
    
    # Final prompt
    $finalY += 4
    Write-Centered -Text "PS C:\> Write-Host 'Goodbye, and thank you!' -ForegroundColor Cyan" -Y $finalY -Color 'Gray'
    $finalY += 1
    Write-Centered -Text (Get-LocalizedString -Key 'Goodbye') -Y $finalY -Color 'Cyan'
    
    # Closing fanfare
    Play-ClosingFanfare
    
    Wait-Animation -Milliseconds 3000
}

# ============================================================================
# SCENE: CREDITS
# ============================================================================

function Show-Credits {
    Clear-Console
    $height = $script:Config.ConsoleHeight
    $y = [Math]::Floor($height / 2) - 4
    
    Write-Centered -Text "---" -Y $y -Color 'DarkGray'
    $y += 2
    
    Write-TypewriterCentered -Text (Get-LocalizedString -Key 'CreditsOne') -Y $y -Color 'DarkGray' -Delay 25 -WithSound
    $y += 2
    Write-TypewriterCentered -Text (Get-LocalizedString -Key 'CreditsTwo') -Y $y -Color 'DarkGray' -Delay 25
    $y += 2
    Write-TypewriterCentered -Text (Get-LocalizedString -Key 'CreditsThree') -Y $y -Color 'Cyan' -Delay 25
    Play-Sparkle
    
    $y += 4
    Write-Centered -Text "#ThankYouJeffrey" -Y $y -Color 'Yellow'
    $y += 2
    Write-Centered -Text "#PowerShell" -Y $y -Color 'Cyan'
    
    # Final musical flourish
    Play-PowerShellTheme
    
    Wait-Animation -Milliseconds 3000
}

function Show-ManifestoQr {
    $qrPath = Join-Path $script:DataRoot 'monad-manifesto-qr.txt'
    if (-not (Test-Path -LiteralPath $qrPath -PathType Leaf)) {
        return
    }

    Clear-Console
    Write-Centered -Text 'MONAD MANIFESTO' -Y 1 -Color 'Yellow'
    $y = 3
    foreach ($line in (Get-Content -LiteralPath $qrPath -Encoding ASCII)) {
        if ($y -ge $script:Config.ConsoleHeight - 4) {
            break
        }
        Write-Centered -Text $line -Y $y -Color 'White'
        $y++
    }

    $manifesto = Get-MonadManifesto -All | Select-Object -First 1
    if ($null -ne $manifesto) {
        Write-Centered -Text $manifesto.Source -Y ($script:Config.ConsoleHeight - 2) -Color 'Cyan'
    }
    Wait-Animation -Milliseconds $script:Config.SceneDelay
}

function Show-EasterEgg {
    Clear-Console
    $centerY = [Math]::Floor($script:Config.ConsoleHeight / 2)
    Write-Centered -Text (Get-LocalizedString -Key 'EasterEggTitle') -Y ($centerY - 2) -Color 'Yellow'
    Write-TypewriterCentered -Text (Get-LocalizedString -Key 'EasterEggLine') -Y $centerY -Color 'Cyan' -Delay 25
    Write-Centered -Text 'https://www.youtube.com/watch?v=dQw4w9WgXcQ' -Y ($centerY + 3) -Color 'DarkGray'
    Wait-Animation -Milliseconds 2000
}

function Start-SnoverDemo {
    [CmdletBinding()]
    param()

    try {
        Initialize-Console
        Show-TheProblem
        Show-TheManifesto
        Show-Timeline
    } finally {
        Restore-Console
    }
}

function Start-StartDemo {
    [CmdletBinding()]
    param()

    Start-SnoverDemo
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

function Start-Tribute {
    try {
        if (-not [string]::IsNullOrWhiteSpace($script:Config.TranscriptPath)) {
            try {
                Start-Transcript -Path $script:Config.TranscriptPath -Force | Out-Null
                $script:Config.TranscriptStarted = $true
            } catch {
                Write-Warning "Unable to start transcript: $($_.Exception.Message)"
            }
        }

        Initialize-Console

        do {
            $script:Config.SkipToEnd = $false
            $script:Config.ReplayRequested = $false

            if (-not $script:Config.SkipIntro) {
                Show-Opening
            }

            if (-not $script:Config.SkipToEnd) { Show-Title }
            if (-not $script:Config.SkipToEnd) { Show-TheProblem }
            if (-not $script:Config.SkipToEnd) { Show-TheManifesto }
            if (-not $script:Config.SkipToEnd) { Show-Timeline }
            if (-not $script:Config.SkipToEnd) { Show-Impact }
            if (-not $script:Config.SkipToEnd) { Show-Quotes }
            if (-not $script:Config.SkipToEnd) { Show-CommunityWall }
            if (-not $script:Config.SkipToEnd -and $script:Config.EasterEgg) { Show-EasterEgg }

            Show-Finale
            Show-Credits
            Show-ManifestoQr

            $y = $script:Config.ConsoleHeight - 2
            Write-Centered -Text (Get-LocalizedString -Key 'PressAnyKey') -Y $y -Color 'DarkGray'
            if ($script:Config.ReplayRequested) {
                $replay = $true
            } elseif ($script:Config.IsInteractive) {
                $replay = $false
                try {
                    $key = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
                    $replay = $key.Character -eq 'r' -or $key.Character -eq 'R'
                } catch {
                    $replay = $false
                }
            } else {
                $replay = $false
            }
        } while ($replay)
    }
    finally {
        if ($script:Config.TranscriptStarted) {
            try {
                Stop-Transcript | Out-Null
            } catch {
                # Transcript cleanup is best effort.
            }
            $script:Config.TranscriptStarted = $false
        }
        Restore-Console
    }
}

# ============================================================================
# RUN
# ============================================================================

if ($MyInvocation.InvocationName -ne '.') {
    Start-Tribute
}
