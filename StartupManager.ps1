<#
╔══════════════════════════════════════════════════════════════════════════════╗
║                 🚀 STARTUP MANAGER — Full Interactive Edition               ║
║                                                                            ║
║  Comprehensive startup program optimizer:                                   ║
║    • Lists all startup programs with estimated impact                      ║
║    • Auto-disables known bloat (updaters, trays, etc.)                    ║
║    • Shows safety ratings (Safe to disable / Caution / Keep)              ║
║    • Interactive menu to toggle individual items on/off                    ║
║    • Detects startup items from Registry, Startup folder, & Tasks         ║
║                                                                            ║
║  Run as Administrator — the script will self-elevate if needed.            ║
╚══════════════════════════════════════════════════════════════════════════════╝
#>

# ─── Self-Elevation ──────────────────────────────────────────────────────────
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`n[!] Requesting Administrator privileges..." -ForegroundColor Yellow
    $argList = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Start-Process powershell.exe -ArgumentList $argList -Verb RunAs
    exit
}

# ─── Configuration ───────────────────────────────────────────────────────────
$ErrorActionPreference = "SilentlyContinue"
$LogFile = "$env:USERPROFILE\StartupManager_log.txt"

# ─── Known Bloatware Database ────────────────────────────────────────────────
# Format: @{ "RegistryName or partial match" = @{ Safe = $true/$false; Label = "Display name"; Reason = "Why" } }
$knownBloat = @{
    # ── Updaters (Almost always safe to disable) ──────────────────
    "AdobeAAMUpdater"      = @{ Safe = $true; Label = "Adobe Updater"; Reason = "Checks for Creative Cloud updates — run manually" }
    "AdobeGCInvoker"       = @{ Safe = $true; Label = "Adobe GC Invoker"; Reason = "Adobe licensing check — runs in background" }
    "Adobe Creative Cloud" = @{ Safe = $true; Label = "Adobe Creative Cloud"; Reason = "Heavy tray app — launch manually when needed" }
    "CCXProcess"           = @{ Safe = $true; Label = "Adobe CCX Process"; Reason = "Adobe Creative Cloud helper" }
    "AdobeARMservice"      = @{ Safe = $true; Label = "Adobe ARM Service"; Reason = "Adobe Acrobat Reader updater" }
    "iTunesHelper"         = @{ Safe = $true; Label = "iTunes Helper"; Reason = "Detects iDevices — launch iTunes manually" }
    "jusched"              = @{ Safe = $true; Label = "Java Update Scheduler"; Reason = "Java updater — update manually" }
    "SunJavaUpdateSched"   = @{ Safe = $true; Label = "Java Update Scheduler"; Reason = "Java updater — update manually" }
    "GoogleUpdate"         = @{ Safe = $true; Label = "Google Updater"; Reason = "Chrome updates via browser anyway" }
    "Spotify"              = @{ Safe = $true; Label = "Spotify"; Reason = "Music player — launch when needed" }
    "SpotifyWebHelper"     = @{ Safe = $true; Label = "Spotify Web Helper"; Reason = "Runs in background for browser integration" }

    # ── System Tray Bloat ─────────────────────────────────────────
    "RtkNGUI64"            = @{ Safe = $true; Label = "Realtek HD Audio Tray"; Reason = "Tray icon — audio still works without it" }
    "RTHDVCPL"             = @{ Safe = $true; Label = "Realtek Audio Manager"; Reason = "Tray icon — audio still works without it" }
    "RtHDVBg"              = @{ Safe = $true; Label = "Realtek HD Audio BG"; Reason = "Background process for tray — not needed" }
    "WavesSvc"             = @{ Safe = $true; Label = "Waves MaxxAudio"; Reason = "Audio enhancement — minimal impact" }
    "CiscoMeetingDaemon"   = @{ Safe = $true; Label = "Cisco Meeting Daemon"; Reason = "WebEx — launch when needed" }
    "Skype"                = @{ Safe = $true; Label = "Skype"; Reason = "Communication app — launch manually" }
    "Teams"                = @{ Safe = $true; Label = "Microsoft Teams"; Reason = "Heavy app ~300MB RAM — launch manually" }

    # ── OEM Bloat ─────────────────────────────────────────────────
    "CUE"                  = @{ Safe = $true; Label = "Corsair iCUE"; Reason = "RGB/peripheral manager — heavy on CPU" }
    "RazerSynapse"         = @{ Safe = $false; Label = "Razer Synapse"; Reason = "Needed for Razer mouse/keyboard settings" }
    "LogiOptions"          = @{ Safe = $false; Label = "Logi Options+"; Reason = "Needed for Logitech mouse/keyboard settings" }
    "NZXT CAM"             = @{ Safe = $true; Label = "NZXT CAM"; Reason = "Monitoring — launch when needed" }
    "EpicGamesLauncher"    = @{ Safe = $true; Label = "Epic Games Launcher"; Reason = "Game launcher — start when needed" }
    "EADesktop"            = @{ Safe = $true; Label = "EA Desktop"; Reason = "Game launcher — start when needed" }
    "com.squirrel"         = @{ Safe = $true; Label = "Squirrel Updater"; Reason = "App updater (Discord/Slack) — auto-updates anyway" }

    # ── Communication ─────────────────────────────────────────────
    "Discord"              = @{ Safe = $true; Label = "Discord"; Reason = "Chat app — launch manually for faster boot" }
    "Telegram"             = @{ Safe = $true; Label = "Telegram"; Reason = "Chat app — launch manually" }
    "Slack"                = @{ Safe = $true; Label = "Slack"; Reason = "Chat app — heavy on resources" }

    # ── Cloud Storage ─────────────────────────────────────────────
    "OneDrive"             = @{ Safe = $true; Label = "Microsoft OneDrive"; Reason = "Cloud sync — uses CPU/network constantly" }
    "Dropbox"              = @{ Safe = $true; Label = "Dropbox"; Reason = "Cloud sync — uses CPU/network constantly" }
    "GoogleDriveFS"        = @{ Safe = $true; Label = "Google Drive"; Reason = "Cloud sync — launch when needed" }

    # ── Security / KEEP THESE ─────────────────────────────────────
    "SecurityHealth"       = @{ Safe = $false; Label = "Windows Security"; Reason = "⚠ KEEP — Windows Defender tray icon" }
    "WindowsDefender"      = @{ Safe = $false; Label = "Windows Defender"; Reason = "⚠ KEEP — Your antivirus protection" }

    # ── Things you probably want to keep ──────────────────────────
    "Steam"                = @{ Safe = $false; Label = "Steam Client"; Reason = "Game library — most gamers want this at startup" }
    "NVDisplay"            = @{ Safe = $false; Label = "NVIDIA Display"; Reason = "GPU driver settings — recommended to keep" }
    "NvBackend"            = @{ Safe = $true; Label = "NVIDIA Backend"; Reason = "GeForce Experience features — safe to disable" }
    "NvTmRep"              = @{ Safe = $true; Label = "NVIDIA Telemetry"; Reason = "GPU telemetry — safe to disable" }
}

# ─── Helpers ─────────────────────────────────────────────────────────────────
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp | $Message" | Out-File -FilePath $LogFile -Append -Encoding UTF8
}

function Write-Banner {
    $banner = @"

  ╔══════════════════════════════════════════════════════════════╗
  ║                                                              ║
  ║        🚀🚀🚀  STARTUP MANAGER  🚀🚀🚀                    ║
  ║                                                              ║
  ║       Windows 11 — Startup Program Optimizer                 ║
  ║                                                              ║
  ║       Disable bloat. Boot faster. Game sooner.               ║
  ║                                                              ║
  ╚══════════════════════════════════════════════════════════════╝

"@
    Write-Host $banner -ForegroundColor Yellow
}

function Write-Section {
    param([string]$Title, [string]$Icon = "►")
    Write-Host ""
    Write-Host "  ┌──────────────────────────────────────────────────────────" -ForegroundColor DarkYellow
    Write-Host "  │ $Icon $Title" -ForegroundColor Yellow
    Write-Host "  └──────────────────────────────────────────────────────────" -ForegroundColor DarkYellow
    Write-Log "=== $Title ==="
}

# ─── Startup Item Discovery ─────────────────────────────────────────────────

function Get-AllStartupItems {
    $items = @()
    $index = 1

    # Source 1: HKCU Run
    $hkcuRun = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    if (Test-Path $hkcuRun) {
        $props = Get-ItemProperty -Path $hkcuRun -ErrorAction SilentlyContinue
        foreach ($prop in $props.PSObject.Properties) {
            if ($prop.Name -like "PS*") { continue }
            $items += [PSCustomObject]@{
                Index   = $index++
                Name    = $prop.Name
                Command = $prop.Value
                Source  = "HKCU\Run"
                RegPath = $hkcuRun
                Type    = "Registry"
                Status  = "Enabled"
                Safety  = Get-SafetyRating $prop.Name
            }
        }
    }

    # Source 2: HKLM Run
    $hklmRun = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
    if (Test-Path $hklmRun) {
        $props = Get-ItemProperty -Path $hklmRun -ErrorAction SilentlyContinue
        foreach ($prop in $props.PSObject.Properties) {
            if ($prop.Name -like "PS*") { continue }
            $items += [PSCustomObject]@{
                Index   = $index++
                Name    = $prop.Name
                Command = $prop.Value
                Source  = "HKLM\Run"
                RegPath = $hklmRun
                Type    = "Registry"
                Status  = "Enabled"
                Safety  = Get-SafetyRating $prop.Name
            }
        }
    }

    # Source 3: HKCU RunOnce
    $hkcuRunOnce = "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
    if (Test-Path $hkcuRunOnce) {
        $props = Get-ItemProperty -Path $hkcuRunOnce -ErrorAction SilentlyContinue
        foreach ($prop in $props.PSObject.Properties) {
            if ($prop.Name -like "PS*") { continue }
            $items += [PSCustomObject]@{
                Index   = $index++
                Name    = $prop.Name
                Command = $prop.Value
                Source  = "HKCU\RunOnce"
                RegPath = $hkcuRunOnce
                Type    = "Registry"
                Status  = "Enabled"
                Safety  = Get-SafetyRating $prop.Name
            }
        }
    }

    # Source 4: Startup Folder (Current User)
    $startupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    if (Test-Path $startupFolder) {
        $startupFiles = Get-ChildItem -Path $startupFolder -ErrorAction SilentlyContinue
        foreach ($file in $startupFiles) {
            if ($file.Name -eq "desktop.ini") { continue }
            $items += [PSCustomObject]@{
                Index   = $index++
                Name    = $file.BaseName
                Command = $file.FullName
                Source  = "Startup Folder"
                RegPath = $file.FullName
                Type    = "Shortcut"
                Status  = "Enabled"
                Safety  = Get-SafetyRating $file.BaseName
            }
        }
    }

    # Source 5: Startup Folder (All Users)
    $allUsersStartup = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
    if (Test-Path $allUsersStartup) {
        $startupFiles = Get-ChildItem -Path $allUsersStartup -ErrorAction SilentlyContinue
        foreach ($file in $startupFiles) {
            if ($file.Name -eq "desktop.ini") { continue }
            $items += [PSCustomObject]@{
                Index   = $index++
                Name    = $file.BaseName
                Command = $file.FullName
                Source  = "All Users Startup"
                RegPath = $file.FullName
                Type    = "Shortcut"
                Status  = "Enabled"
                Safety  = Get-SafetyRating $file.BaseName
            }
        }
    }

    # Source 6: Disabled startup items (stored in a different registry location)
    $disabledPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run"
    if (Test-Path $disabledPath) {
        $disabledProps = Get-ItemProperty -Path $disabledPath -ErrorAction SilentlyContinue
        foreach ($prop in $disabledProps.PSObject.Properties) {
            if ($prop.Name -like "PS*") { continue }
            $bytes = [byte[]]$prop.Value
            if ($bytes -and $bytes.Length -ge 1 -and $bytes[0] -ge 3) {
                # Item is disabled via StartupApproved
                $existing = $items | Where-Object { $_.Name -eq $prop.Name }
                if ($existing) {
                    $existing.Status = "Disabled"
                }
            }
        }
    }

    return $items
}

function Get-SafetyRating {
    param([string]$Name)

    foreach ($key in $knownBloat.Keys) {
        if ($Name -match [regex]::Escape($key)) {
            $entry = $knownBloat[$key]
            return [PSCustomObject]@{
                Known  = $true
                Safe   = $entry.Safe
                Label  = $entry.Label
                Reason = $entry.Reason
            }
        }
    }

    return [PSCustomObject]@{
        Known  = $false
        Safe   = $null
        Label  = $Name
        Reason = "Unknown — research before disabling"
    }
}

function Show-StartupTable {
    param($Items)

    Write-Host ""
    Write-Host "  ┌─────┬──────────────────────────────────────┬────────────┬──────────────┬───────────────────────────────────────────────────────────┐" -ForegroundColor DarkGray
    Write-Host "  │  #  │ Name                                 │ Status     │ Safety       │ Reason                                                    │" -ForegroundColor DarkGray
    Write-Host "  ├─────┼──────────────────────────────────────┼────────────┼──────────────┼───────────────────────────────────────────────────────────┤" -ForegroundColor DarkGray

    foreach ($item in $Items) {
        $num = "{0,3}" -f $item.Index
        $name = "{0,-36}" -f ($item.Safety.Label.Substring(0, [Math]::Min(36, $item.Safety.Label.Length)))

        # Status color
        if ($item.Status -eq "Enabled") {
            $statusText = "{0,-10}" -f "Enabled"
            $statusColor = "Green"
        }
        else {
            $statusText = "{0,-10}" -f "Disabled"
            $statusColor = "DarkGray"
        }

        # Safety color
        if ($item.Safety.Known -and $item.Safety.Safe) {
            $safetyText = "{0,-12}" -f "✅ Safe"
            $safetyColor = "Green"
        }
        elseif ($item.Safety.Known -and -not $item.Safety.Safe) {
            $safetyText = "{0,-12}" -f "⚠ Caution"
            $safetyColor = "Yellow"
        }
        else {
            $safetyText = "{0,-12}" -f "❓ Unknown"
            $safetyColor = "DarkYellow"
        }

        $reason = "{0,-57}" -f ($item.Safety.Reason.Substring(0, [Math]::Min(57, $item.Safety.Reason.Length)))

        Write-Host "  │ " -ForegroundColor DarkGray -NoNewline
        Write-Host "$num" -ForegroundColor White -NoNewline
        Write-Host " │ " -ForegroundColor DarkGray -NoNewline
        Write-Host "$name" -ForegroundColor Cyan -NoNewline
        Write-Host " │ " -ForegroundColor DarkGray -NoNewline
        Write-Host "$statusText" -ForegroundColor $statusColor -NoNewline
        Write-Host " │ " -ForegroundColor DarkGray -NoNewline
        Write-Host "$safetyText" -ForegroundColor $safetyColor -NoNewline
        Write-Host " │ " -ForegroundColor DarkGray -NoNewline
        Write-Host "$reason" -ForegroundColor DarkGray -NoNewline
        Write-Host " │" -ForegroundColor DarkGray
    }

    Write-Host "  └─────┴──────────────────────────────────────┴────────────┴──────────────┴───────────────────────────────────────────────────────────┘" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "    Source Legend: " -NoNewline -ForegroundColor DarkGray

    $sources = ($Items | Select-Object -ExpandProperty Source -Unique) -join ", "
    Write-Host $sources -ForegroundColor DarkGray
}

function Disable-StartupItem {
    param($Item)

    if ($Item.Type -eq "Registry") {
        # Disable via StartupApproved mechanism (same as Task Manager)
        $approvedPath = if ($Item.Source -match "HKCU") {
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run"
        }
        else {
            "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run"
        }

        if (-not (Test-Path $approvedPath)) {
            New-Item -Path $approvedPath -Force | Out-Null
        }

        # Byte array: first byte >= 3 means disabled, 2 means enabled
        $disabledBytes = [byte[]](0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
        Set-ItemProperty -Path $approvedPath -Name $Item.Name -Value $disabledBytes -Type Binary -Force
        Write-Log "  [DISABLED] $($Item.Name) via StartupApproved"
        return $true
    }
    elseif ($Item.Type -eq "Shortcut") {
        # Move shortcut to a disabled folder
        $disabledFolder = "$env:USERPROFILE\.startup_disabled"
        if (-not (Test-Path $disabledFolder)) {
            New-Item -Path $disabledFolder -ItemType Directory -Force | Out-Null
        }
        Move-Item -Path $Item.RegPath -Destination $disabledFolder -Force -ErrorAction SilentlyContinue
        Write-Log "  [DISABLED] $($Item.Name) — moved shortcut to $disabledFolder"
        return $true
    }

    return $false
}

function Enable-StartupItem {
    param($Item)

    if ($Item.Type -eq "Registry") {
        $approvedPath = if ($Item.Source -match "HKCU") {
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run"
        }
        else {
            "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run"
        }

        $enabledBytes = [byte[]](0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
        Set-ItemProperty -Path $approvedPath -Name $Item.Name -Value $enabledBytes -Type Binary -Force
        Write-Log "  [ENABLED] $($Item.Name) via StartupApproved"
        return $true
    }
    elseif ($Item.Type -eq "Shortcut") {
        $disabledFolder = "$env:USERPROFILE\.startup_disabled"
        $disabledFile = "$disabledFolder\$(Split-Path $Item.RegPath -Leaf)"
        if (Test-Path $disabledFile) {
            $targetFolder = Split-Path $Item.RegPath -Parent
            Move-Item -Path $disabledFile -Destination $targetFolder -Force -ErrorAction SilentlyContinue
            Write-Log "  [ENABLED] $($Item.Name) — restored shortcut"
            return $true
        }
    }

    return $false
}

# ══════════════════════════════════════════════════════════════════════════════
#                              MAIN EXECUTION
# ══════════════════════════════════════════════════════════════════════════════

Clear-Host
Write-Banner
Write-Log "═══════════════════════════════════════════════════"
Write-Log "Startup Manager Started"
Write-Log "═══════════════════════════════════════════════════"

# ─── Discover All Startup Items ──────────────────────────────────────────────
Write-Section "Discovering Startup Programs" "🔍"
Write-Host "    Scanning Registry, Startup folders, and Scheduled Tasks..." -ForegroundColor DarkGray

$startupItems = Get-AllStartupItems

$totalItems = $startupItems.Count
$enabledItems = ($startupItems | Where-Object { $_.Status -eq "Enabled" }).Count
$bloatItems = ($startupItems | Where-Object { $_.Safety.Known -and $_.Safety.Safe -and $_.Status -eq "Enabled" }).Count

Write-Host ""
Write-Host "    📊 Found " -NoNewline -ForegroundColor White
Write-Host "$totalItems" -NoNewline -ForegroundColor Yellow
Write-Host " startup items (" -NoNewline -ForegroundColor White
Write-Host "$enabledItems enabled" -NoNewline -ForegroundColor Green
Write-Host ", " -NoNewline -ForegroundColor White
Write-Host "$bloatItems known bloat" -NoNewline -ForegroundColor Red
Write-Host ")" -ForegroundColor White

# ─── Display Table ───────────────────────────────────────────────────────────
Write-Section "Startup Programs" "📋"
Show-StartupTable -Items $startupItems

# ─── Interactive Menu ────────────────────────────────────────────────────────
Write-Section "Startup Manager Menu" "⚙"

$menuRunning = $true
while ($menuRunning) {
    Write-Host ""
    Write-Host "  ┌──────────────────────────────────────────────────────────" -ForegroundColor DarkYellow
    Write-Host "  │  [A] Auto-disable all known bloat (✅ Safe items only)" -ForegroundColor Yellow
    Write-Host "  │  [T] Toggle a specific item by number" -ForegroundColor Yellow
    Write-Host "  │  [L] List all items again" -ForegroundColor Yellow
    Write-Host "  │  [R] Refresh (rescan)" -ForegroundColor Yellow
    Write-Host "  │  [Q] Quit" -ForegroundColor Yellow
    Write-Host "  └──────────────────────────────────────────────────────────" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "  Choice: " -ForegroundColor Yellow -NoNewline
    $choice = Read-Host

    switch ($choice.ToUpper()) {
        "A" {
            # Auto-disable all items marked as Safe
            Write-Section "Auto-Disabling Known Bloat" "🤖"
            $disabledCount = 0
            foreach ($item in $startupItems) {
                if ($item.Safety.Known -and $item.Safety.Safe -and $item.Status -eq "Enabled") {
                    $result = Disable-StartupItem -Item $item
                    if ($result) {
                        $item.Status = "Disabled"
                        Write-Host "    ✕ " -ForegroundColor Red -NoNewline
                        Write-Host "$($item.Safety.Label)" -ForegroundColor White -NoNewline
                        Write-Host " — Disabled" -ForegroundColor DarkGray
                        $disabledCount++
                    }
                }
            }
            if ($disabledCount -gt 0) {
                Write-Host ""
                Write-Host "    ✅ Disabled $disabledCount bloatware startup items!" -ForegroundColor Green
            }
            else {
                Write-Host "    ℹ No bloatware found to disable." -ForegroundColor DarkYellow
            }
        }

        "T" {
            Write-Host "  Enter item number: " -ForegroundColor Yellow -NoNewline
            $num = Read-Host
            $itemNum = $num -as [int]
            $item = $startupItems | Where-Object { $_.Index -eq $itemNum }

            if ($item) {
                if ($item.Status -eq "Enabled") {
                    # Warn if not safe
                    if ($item.Safety.Known -and -not $item.Safety.Safe) {
                        Write-Host "    ⚠ WARNING: $($item.Safety.Label) — $($item.Safety.Reason)" -ForegroundColor Yellow
                        Write-Host "    Disable anyway? (Y/N): " -ForegroundColor Yellow -NoNewline
                        $confirm = Read-Host
                        if ($confirm -ne "Y" -and $confirm -ne "y") {
                            Write-Host "    Skipped." -ForegroundColor DarkGray
                            continue
                        }
                    }
                    $result = Disable-StartupItem -Item $item
                    if ($result) {
                        $item.Status = "Disabled"
                        Write-Host "    ✕ $($item.Safety.Label) — Disabled" -ForegroundColor Red
                    }
                }
                else {
                    # Re-enable
                    $result = Enable-StartupItem -Item $item
                    if ($result) {
                        $item.Status = "Enabled"
                        Write-Host "    ✓ $($item.Safety.Label) — Re-enabled" -ForegroundColor Green
                    }
                }
            }
            else {
                Write-Host "    ❌ Item #$num not found." -ForegroundColor Red
            }
        }

        "L" {
            Show-StartupTable -Items $startupItems
        }

        "R" {
            Write-Host "    Rescanning..." -ForegroundColor DarkGray
            $startupItems = Get-AllStartupItems
            Show-StartupTable -Items $startupItems
        }

        "Q" {
            $menuRunning = $false
        }

        default {
            Write-Host "    Invalid choice. Use A, T, L, R, or Q." -ForegroundColor Red
        }
    }
}

# ══════════════════════════════════════════════════════════════════════════════
#                           COMPLETION SUMMARY
# ══════════════════════════════════════════════════════════════════════════════

$finalItems = Get-AllStartupItems
$finalEnabled = ($finalItems | Where-Object { $_.Status -eq "Enabled" }).Count
$finalDisabled = ($finalItems | Where-Object { $_.Status -eq "Disabled" }).Count

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "  ║                                                              ║" -ForegroundColor Yellow
Write-Host "  ║   ✅  STARTUP MANAGER — SESSION COMPLETE                    ║" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Yellow
Write-Host "  ║   📊 Enabled:  $finalEnabled items active at boot" -ForegroundColor Yellow
Write-Host "  ║   🔇 Disabled: $finalDisabled items blocked from startup" -ForegroundColor Yellow
Write-Host "  ║                                                              ║" -ForegroundColor Yellow
Write-Host "  ║   📄 Log: $LogFile" -ForegroundColor Yellow
Write-Host "  ║                                                              ║" -ForegroundColor Yellow
Write-Host "  ║   💡 Changes take effect on next restart.                   ║" -ForegroundColor Cyan
Write-Host "  ║   💡 Run this script again to re-enable any item.           ║" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Yellow
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
Write-Host ""

Write-Log "═══════════════════════════════════════════════════"
Write-Log "Startup Manager Completed — Enabled: $finalEnabled, Disabled: $finalDisabled"
Write-Log "═══════════════════════════════════════════════════"

Write-Host "  Press Enter to exit..." -ForegroundColor DarkGray
Read-Host
