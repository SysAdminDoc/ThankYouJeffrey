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
    [switch]$NoWait
)

#Requires -Version 5.1

# ============================================================================
# CONFIGURATION
# ============================================================================

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
    Write-TypewriterCentered -Text "A PowerShell Production" -Y $centerY -Color 'DarkGray' -Delay 50 -WithSound
    Play-TypewriterReturn
    Wait-Animation -Milliseconds 1500
    
    Play-TransitionDown
    Clear-Console
    Wait-Animation -Milliseconds 300
    
    # Fade in "Presents"
    Write-TypewriterCentered -Text "presents" -Y $centerY -Color 'DarkGray' -Delay 80 -WithSound
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
    Write-TypewriterCentered -Text "Creator of PowerShell" -Y ($subtitleY + 2) -Color 'White' -Delay 40
    
    Wait-Animation -Milliseconds 300
    Write-TypewriterCentered -Text "[ A Retirement Tribute ]" -Y ($subtitleY + 4) -Color 'DarkGray' -Delay 30
    
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
        Clear-Console
        $y = [Math]::Floor($height / 2) - 2
        
        Write-TypewriterCentered -Text ('"' + $quote.Text + '"') -Y $y -Color 'White' -Delay 35 -WithSound
        Play-Sparkle
        Wait-Animation -Milliseconds 400
        Write-TypewriterCentered -Text $quote.Attr -Y ($y + 3) -Color 'DarkGray' -Delay 40
        
        Wait-Animation -Milliseconds 2000
    }
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
    Write-Centered -Text "HAPPY RETIREMENT" -Y ($centerY - 5) -Color 'Yellow'
    
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
        Wait-Animation -Milliseconds 600
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
    
    Wait-Animation -Milliseconds 3000
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

function Start-Tribute {
    try {
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

            Show-Finale
            Show-Credits

            $y = $script:Config.ConsoleHeight - 2
            Write-Centered -Text "Press any key to exit, or R to replay..." -Y $y -Color 'DarkGray'
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
        Restore-Console
    }
}

# ============================================================================
# RUN
# ============================================================================

if ($MyInvocation.InvocationName -ne '.') {
    Start-Tribute
}
