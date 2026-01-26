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

#Requires -Version 5.1

# ============================================================================
# CONFIGURATION
# ============================================================================

$script:Config = @{
    FrameDelay      = 50        # Base animation frame delay (ms)
    TypewriterDelay = 30        # Typewriter effect delay (ms)
    SceneDelay      = 2000      # Pause between scenes (ms)
    EnableSound     = $true     # Console beeps and music
    SkipIntro       = $false    # Skip the opening sequence
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
            Start-Sleep -Milliseconds $Duration
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
        Start-Sleep -Milliseconds 100
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

# ============================================================================
# CONSOLE SETUP
# ============================================================================

function Initialize-Console {
    # Store original settings
    $script:OriginalBg = $Host.UI.RawUI.BackgroundColor
    $script:OriginalFg = $Host.UI.RawUI.ForegroundColor
    $script:OriginalCursor = [Console]::CursorVisible
    
    # Configure for animation
    [Console]::CursorVisible = $false
    $Host.UI.RawUI.BackgroundColor = 'Black'
    $Host.UI.RawUI.ForegroundColor = 'White'
    
    # Set window size if possible
    try {
        $maxWidth = [Math]::Min(120, $Host.UI.RawUI.MaxWindowSize.Width)
        $maxHeight = [Math]::Min(40, $Host.UI.RawUI.MaxWindowSize.Height)
        $Host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size($maxWidth, $maxHeight)
        $Host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size($maxWidth, 1000)
    } catch {
        # Continue with current size
    }
    
    Clear-Host
}

function Restore-Console {
    [Console]::CursorVisible = $script:OriginalCursor
    $Host.UI.RawUI.BackgroundColor = $script:OriginalBg
    $Host.UI.RawUI.ForegroundColor = $script:OriginalFg
    Clear-Host
}

# ============================================================================
# ANIMATION UTILITIES
# ============================================================================

function Set-CursorPosition {
    param([int]$X, [int]$Y)
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates($X, $Y)
}

function Write-Centered {
    param(
        [string]$Text,
        [int]$Y,
        [ConsoleColor]$Color = 'White'
    )
    $width = $Host.UI.RawUI.WindowSize.Width
    $x = [Math]::Max(0, [Math]::Floor(($width - $Text.Length) / 2))
    Set-CursorPosition -X $x -Y $Y
    Write-Host $Text -ForegroundColor $Color -NoNewline
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
        Write-Host $char -ForegroundColor $Color -NoNewline
        if ($WithSound -and $char -match '\S') {
            Play-TypewriterClick
        }
        Start-Sleep -Milliseconds $Delay
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
    $width = $Host.UI.RawUI.WindowSize.Width
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
        Start-Sleep -Milliseconds 150
    }
}

function Clear-Line {
    param([int]$Y)
    $width = $Host.UI.RawUI.WindowSize.Width
    Set-CursorPosition -X 0 -Y $Y
    Write-Host (' ' * $width) -NoNewline
}

function Show-ProgressBar {
    param(
        [int]$Y,
        [int]$Duration = 2000,
        [string]$Label = "Loading",
        [ConsoleColor]$Color = 'Cyan'
    )
    
    $width = 40
    $x = [Math]::Floor(($Host.UI.RawUI.WindowSize.Width - $width - 2) / 2)
    $steps = 20
    $stepDelay = $Duration / $steps
    
    Write-Centered -Text $Label -Y ($Y - 1) -Color 'DarkGray'
    
    for ($i = 0; $i -le $steps; $i++) {
        $filled = [Math]::Floor(($i / $steps) * $width)
        $empty = $width - $filled
        $bar = "[" + ("=" * $filled) + (" " * $empty) + "]"
        Set-CursorPosition -X $x -Y $Y
        Write-Host $bar -ForegroundColor $Color -NoNewline
        Start-Sleep -Milliseconds $stepDelay
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
    Clear-Host
    $height = $Host.UI.RawUI.WindowSize.Height
    $centerY = [Math]::Floor($height / 2) - 3
    
    # Opening fanfare
    Play-Fanfare
    
    # Fade in "A PowerShell Production"
    Start-Sleep -Milliseconds 500
    Write-TypewriterCentered -Text "A PowerShell Production" -Y $centerY -Color 'DarkGray' -Delay 50 -WithSound
    Play-TypewriterReturn
    Start-Sleep -Milliseconds 1500
    
    Play-TransitionDown
    Clear-Host
    Start-Sleep -Milliseconds 300
    
    # Fade in "Presents"
    Write-TypewriterCentered -Text "presents" -Y $centerY -Color 'DarkGray' -Delay 80 -WithSound
    Play-Sparkle
    Start-Sleep -Milliseconds 1500
    
    Play-Whoosh
    Clear-Host
}

# ============================================================================
# SCENE: TITLE
# ============================================================================

function Show-Title {
    Clear-Host
    $height = $Host.UI.RawUI.WindowSize.Height
    $lines = $script:Art.ThankYou -split "`n"
    $startY = [Math]::Floor($height / 2) - [Math]::Floor($lines.Count / 2) - 2
    
    Start-Sleep -Milliseconds 500
    
    # Draw title with fade effect
    Write-FadeIn -Lines $lines -StartY $startY -Color 'Yellow'
    Play-PowerShellTheme
    
    Start-Sleep -Milliseconds 500
    
    # Subtitle
    $subtitleY = $startY + $lines.Count + 2
    Write-TypewriterCentered -Text "Jeffrey Snover" -Y $subtitleY -Color 'Cyan' -Delay 60 -WithSound
    Play-Sparkle
    
    Start-Sleep -Milliseconds 300
    Write-TypewriterCentered -Text "Creator of PowerShell" -Y ($subtitleY + 2) -Color 'White' -Delay 40
    
    Start-Sleep -Milliseconds 300
    Write-TypewriterCentered -Text "[ A Retirement Tribute ]" -Y ($subtitleY + 4) -Color 'DarkGray' -Delay 30
    
    Start-Sleep -Milliseconds $script:Config.SceneDelay
}

# ============================================================================
# SCENE: THE PROBLEM (2002)
# ============================================================================

function Show-TheProblem {
    Clear-Host
    $height = $Host.UI.RawUI.WindowSize.Height
    $y = 3
    
    # Year header
    Play-TransitionUp
    Write-Centered -Text "~~ 2002 ~~" -Y $y -Color 'Magenta'
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
        Start-Sleep -Milliseconds 200
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
    
    Start-Sleep -Milliseconds $script:Config.SceneDelay
}

# ============================================================================
# SCENE: THE MANIFESTO
# ============================================================================

function Show-TheManifesto {
    Clear-Host
    $height = $Host.UI.RawUI.WindowSize.Height
    $y = 3
    
    Play-Whoosh
    Write-Centered -Text "~~ August 2002 ~~" -Y $y -Color 'Magenta'
    $y += 3
    
    Write-TypewriterCentered -Text "Jeffrey Snover writes..." -Y $y -Color 'DarkGray' -Delay 40 -WithSound
    $y += 3
    
    # Monad logo fade in
    $monadLines = $script:Art.MonadLogo -split "`n"
    Write-FadeIn -Lines $monadLines -StartY $y -Color 'Cyan'
    Play-Sparkle
    $y += $monadLines.Count + 2
    
    Write-TypewriterCentered -Text "THE MONAD MANIFESTO" -Y $y -Color 'Yellow' -Delay 60 -WithSound
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
        Start-Sleep -Milliseconds 300
    }
    
    Start-Sleep -Milliseconds $script:Config.SceneDelay
}

# ============================================================================
# SCENE: THE JOURNEY (Timeline)
# ============================================================================

function Show-Timeline {
    Clear-Host
    $y = 2
    
    Play-TransitionUp
    Write-Centered -Text "THE JOURNEY" -Y $y -Color 'Yellow'
    $y += 3
    
    $timeline = @(
        @{ Year = "2002"; Event = "The Monad Manifesto is written"; Color = 'Cyan' },
        @{ Year = "2003"; Event = "Project Monad begins at Microsoft"; Color = 'Cyan' },
        @{ Year = "2006"; Event = "PowerShell 1.0 released to the world"; Color = 'Green' },
        @{ Year = "2009"; Event = "PowerShell 2.0 - Remoting & Modules"; Color = 'White' },
        @{ Year = "2012"; Event = "PowerShell 3.0 - Workflows arrive"; Color = 'White' },
        @{ Year = "2016"; Event = "PowerShell goes OPEN SOURCE"; Color = 'Yellow' },
        @{ Year = "2016"; Event = "PowerShell runs on Linux & macOS"; Color = 'Magenta' },
        @{ Year = "2018"; Event = "PowerShell Core 6.0 - Cross-platform"; Color = 'Cyan' },
        @{ Year = "2020"; Event = "PowerShell 7 - The unified shell"; Color = 'Green' },
        @{ Year = "2025"; Event = "Jeffrey Snover retires"; Color = 'Yellow' }
    )
    
    foreach ($item in $timeline) {
        $yearText = "[ $($item.Year) ]"
        $width = $Host.UI.RawUI.WindowSize.Width
        $lineX = [Math]::Floor($width / 2) - 30
        
        # Sound for each milestone
        Play-TimelineTick
        
        # Draw timeline marker
        Set-CursorPosition -X $lineX -Y $y
        Write-Host $yearText -ForegroundColor 'Magenta' -NoNewline
        
        # Draw event with typewriter
        Set-CursorPosition -X ($lineX + 12) -Y $y
        foreach ($char in $item.Event.ToCharArray()) {
            Write-Host $char -ForegroundColor $item.Color -NoNewline
            Start-Sleep -Milliseconds 15
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
            Write-Host "|" -ForegroundColor 'DarkGray'
        }
        
        $y++
        Start-Sleep -Milliseconds 100
    }
    
    Start-Sleep -Milliseconds $script:Config.SceneDelay
}

# ============================================================================
# SCENE: THE IMPACT
# ============================================================================

function Show-Impact {
    Clear-Host
    $y = 3
    
    Play-Whoosh
    Write-Centered -Text "THE IMPACT" -Y $y -Color 'Yellow'
    $y += 4
    
    # PowerShell logo
    $logoLines = $script:Art.PowerShellLogo -split "`n"
    Write-FadeIn -Lines $logoLines -StartY $y -Color 'Cyan'
    Play-PowerShellTheme
    $y += $logoLines.Count + 2
    
    $stats = @(
        "Millions of scripts written",
        "Countless hours saved",
        "Systems automated worldwide",
        "A community united"
    )
    
    foreach ($stat in $stats) {
        Play-TimelineTick
        Write-TypewriterCentered -Text ">> $stat" -Y $y -Color 'White' -Delay 25
        $y += 2
        Start-Sleep -Milliseconds 200
    }
    
    $y += 1
    Play-VictoryTheme
    Write-TypewriterCentered -Text "One shell to rule them all." -Y $y -Color 'Green' -Delay 50 -WithSound
    
    Start-Sleep -Milliseconds $script:Config.SceneDelay
}

# ============================================================================
# SCENE: QUOTES
# ============================================================================

function Show-Quotes {
    Clear-Host
    $height = $Host.UI.RawUI.WindowSize.Height
    
    $quotes = @(
        @{
            Text = "The pipeline is the heart of PowerShell."
            Attr = "- Jeffrey Snover"
        },
        @{
            Text = "PowerShell is a tool for thought."
            Attr = "- Jeffrey Snover"
        },
        @{
            Text = "Automate everything. Then automate the automation."
            Attr = "- The PowerShell Way"
        }
    )
    
    foreach ($quote in $quotes) {
        Play-TransitionUp
        Clear-Host
        $y = [Math]::Floor($height / 2) - 2
        
        Write-TypewriterCentered -Text ('"' + $quote.Text + '"') -Y $y -Color 'White' -Delay 35 -WithSound
        Play-Sparkle
        Start-Sleep -Milliseconds 400
        Write-TypewriterCentered -Text $quote.Attr -Y ($y + 3) -Color 'DarkGray' -Delay 40
        
        Start-Sleep -Milliseconds 2000
    }
}

# ============================================================================
# SCENE: FIREWORKS
# ============================================================================

function Show-Fireworks {
    param([int]$Duration = 5000)
    
    $width = $Host.UI.RawUI.WindowSize.Width
    $height = $Host.UI.RawUI.WindowSize.Height
    $endTime = (Get-Date).AddMilliseconds($Duration)
    
    $particles = @()
    $colors = @('Red', 'Yellow', 'Green', 'Cyan', 'Magenta', 'White')
    $chars = @('*', '.', '+', 'o', "'", '`')
    
    $frameCount = 0
    
    while ((Get-Date) -lt $endTime) {
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
                Write-Host ' ' -NoNewline
            }
            
            # Update position
            $p.X += $p.VX
            $p.Y += $p.VY
            $p.VY += 0.1  # Gravity
            $p.Life--
            
            # Draw new position
            if ($p.Life -gt 0 -and $p.X -ge 0 -and $p.X -lt $width -and $p.Y -ge 0 -and $p.Y -lt $height) {
                Set-CursorPosition -X ([int]$p.X) -Y ([int]$p.Y)
                Write-Host $p.Char -ForegroundColor $p.Color -NoNewline
                $newParticles += $p
            }
        }
        $particles = $newParticles
        
        Start-Sleep -Milliseconds 50
    }
}

# ============================================================================
# SCENE: FINALE
# ============================================================================

function Show-Finale {
    Clear-Host
    $width = $Host.UI.RawUI.WindowSize.Width
    $height = $Host.UI.RawUI.WindowSize.Height
    $centerY = [Math]::Floor($height / 2)
    
    # First, show the message
    Play-VictoryTheme
    Write-Centered -Text "HAPPY RETIREMENT" -Y ($centerY - 5) -Color 'Yellow'
    
    $nameLines = $script:Art.JeffreyName -split "`n"
    $nameY = $centerY - 3
    foreach ($line in $nameLines) {
        Write-Centered -Text $line -Y $nameY -Color 'Cyan'
        $nameY++
    }
    
    Start-Sleep -Milliseconds 1000
    
    # Fireworks!
    Show-Fireworks -Duration 5000
    
    # Final message with emotional theme
    Clear-Host
    
    Play-EmotionalTheme
    
    $finalY = [Math]::Floor($height / 2) - 6
    
    Write-Centered -Text "Thank you, Jeffrey." -Y $finalY -Color 'Yellow'
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
        Start-Sleep -Milliseconds 600
    }
    
    $finalY += 2
    Play-Sparkle
    Write-Centered -Text "Enjoy your well-deserved retirement!" -Y $finalY -Color 'Green'
    
    $finalY += 3
    Write-Centered -Text "---" -Y $finalY -Color 'DarkGray'
    $finalY += 2
    Write-Centered -Text "From the PowerShell community, with love." -Y $finalY -Color 'Cyan'
    
    # Final prompt
    $finalY += 4
    Write-Centered -Text "PS C:\> Write-Host 'Goodbye, and thank you!' -ForegroundColor Cyan" -Y $finalY -Color 'Gray'
    $finalY += 1
    Write-Centered -Text "Goodbye, and thank you!" -Y $finalY -Color 'Cyan'
    
    # Closing fanfare
    Play-ClosingFanfare
    
    Start-Sleep -Milliseconds 3000
}

# ============================================================================
# SCENE: CREDITS
# ============================================================================

function Show-Credits {
    Clear-Host
    $height = $Host.UI.RawUI.WindowSize.Height
    $y = [Math]::Floor($height / 2) - 4
    
    Write-Centered -Text "---" -Y $y -Color 'DarkGray'
    $y += 2
    
    Write-TypewriterCentered -Text "This tribute was created entirely in PowerShell" -Y $y -Color 'DarkGray' -Delay 25 -WithSound
    $y += 2
    Write-TypewriterCentered -Text "Because there's no better way to say thank you" -Y $y -Color 'DarkGray' -Delay 25
    $y += 2
    Write-TypewriterCentered -Text "than with the very tool you created." -Y $y -Color 'Cyan' -Delay 25
    Play-Sparkle
    
    $y += 4
    Write-Centered -Text "#ThankYouJeffrey" -Y $y -Color 'Yellow'
    $y += 2
    Write-Centered -Text "#PowerShell" -Y $y -Color 'Cyan'
    
    # Final musical flourish
    Play-PowerShellTheme
    
    Start-Sleep -Milliseconds 3000
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

function Start-Tribute {
    try {
        Initialize-Console
        
        # Opening
        if (-not $script:Config.SkipIntro) {
            Show-Opening
        }
        
        # Main scenes
        Show-Title
        Show-TheProblem
        Show-TheManifesto
        Show-Timeline
        Show-Impact
        Show-Quotes
        Show-Finale
        Show-Credits
        
        # Wait for keypress
        $y = $Host.UI.RawUI.WindowSize.Height - 2
        Write-Centered -Text "Press any key to exit..." -Y $y -Color 'DarkGray'
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    }
    finally {
        Restore-Console
    }
}

# ============================================================================
# RUN
# ============================================================================

Start-Tribute
