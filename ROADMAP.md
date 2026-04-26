# Roadmap

Forward-looking plans for ThankYouJeffrey — a cinematic PowerShell console tribute to Jeffrey Snover. The project's scope is intentionally small; this roadmap is mostly polish and small celebratory additions.

## Planned Features

### Console Experience
- Timed scene pacing that adapts to console width and frame rate (currently assumes 120+ cols)
- True-color ANSI fallback detection so it still looks right on Windows Terminal, ConEmu, Alacritty, and legacy conhost
- Sound cues (Beeps or `System.Media.SoundPlayer` with optional wav) — opt-in via `-Audio` switch
- Typewriter effect with variable cadence (`-Speed Fast|Normal|Dramatic`)
- Skip-to-end keystroke (Space) and replay (R) handled via `$Host.UI.RawUI.ReadKey`

### Content
- Curated "PowerShell firsts" timeline — Monad Manifesto (2002), v1.0 (2006), open source (2016), cross-plat (2016), retirement (2025)
- Snoverisms quote rotator ("Live your life in a state of compounding success", etc.) pulled from a JSON bundle
- Community tribute wall — pull `git log`-style entries from a public submissions JSON hosted on the repo
- Localized tribute strings (ja / de / pt-br) for international PowerShell community

### Distribution
- PSGallery publish (`Install-Script ThankYouJeffrey`) so it's `iex` + one-line install from the trusted gallery
- Winget / Chocolatey manifests for sysadmins who only install signed packages
- GitHub Release with Authenticode-signed `.ps1`

## Competitive Research

- **`Get-Coffee` / `Out-Pipe` style joke cmdlets** (PowerShell community): small, shareable, one-off tributes. ThankYouJeffrey is in the same spirit — keep it light.
- **`cmatrix` / `hollywood` / `no-more-secrets` (Linux)**: precedent for terminal-as-theater. We can borrow the "fake decrypt" reveal effect for the tribute finale.
- **PowerShell Conference EU / PSConfAsia tribute reels**: content source for the milestones timeline; mirror their framing.

## Nice-to-Haves

- Rickroll-style easter egg triggered by a hidden parameter (Jeffrey would approve)
- QR code at the end linking to the Monad Manifesto PDF
- ASCII-art portrait of Jeffrey rendered from a photo at launch time (dithered via `ConvertTo-AsciiArt`)
- Companion cross-shell versions (bash, zsh, fish) so Linux/macOS PowerShell users get something too
- "Send-ThankYouEmail" cmdlet that composes and opens a draft in the default mail client
- Archive snapshot on archive.org each year on Jeffrey's retirement anniversary

## Open-Source Research (Round 2)

### Related OSS Projects
- https://github.com/LawrenceHwang/Snoverism — existing Snover-quotes PowerShell module (direct peer)
- https://github.com/jpsnover — Jeffrey Snover's own GitHub for linking / crediting
- https://github.com/janikvonrotz/awesome-powershell — broad PowerShell ecosystem reference
- https://github.com/PowerShell/PowerShell — upstream; monitor for related tribute issues/milestones
- https://github.com/Kriegel/PSStart-Demo — Peter Kriegel's refreshed Start-Demo (Snover demo-framework homage)
- https://github.com/PoshCode/PowerShellGet — PSGallery publishing reference
- https://github.com/PowerShell/Modules — module packaging patterns
- https://github.com/pester/Pester — if any test coverage is added later

### Features to Borrow
- `Get-Snoverism` quote fetcher with source-attribution field (Snoverism) — credit talks, blog posts, videos
- PSGallery publishing workflow via GitHub Actions with signed modules (PowerShellGet pattern)
- Monad Manifesto excerpts cmdlet — paginated reader with ASCII-art section headers (fits the project tone)
- Demo-mode replay of Snover's iconic Start-Demo (Kriegel) — step through classic demos in-shell
- `Invoke-PowerShellTimeline` cmdlet printing PowerShell history milestones (v1 → Core → 7) with links
- Markdown quote-of-the-day post generator for social/blog pipelines
- Embedded birthday/retirement-anniversary reminder as scheduled task
- `Thank-Jeffrey` interactive cmdlet — prompt the user to tweet/post appreciation, opens browser
- Multi-shell tribute companion (bash/zsh/fish/pwsh) sharing quote JSON source of truth
- Integration with PowerShell Notes of the Week / community RSS for surfacing current Snover content

### Patterns & Architectures Worth Studying
- Module manifest with `.psd1` metadata referencing tribute source bibliography (Snoverism pattern)
- Data-as-JSON: quotes/timeline/manifesto excerpts live as versioned JSON, not hardcoded in .ps1
- Classic PowerShell idiomatic style: strict pipelining, no aliases in published code, verbose help blocks (Snover's own style guide)
- `Start-Transcript` auto-capture for any demo-mode run — shareable session logs
- Cross-shell portability via a shared data package consumed by thin per-shell wrappers
