<#
╔══════════════════════════════════════════════════════════════════════════════╗
║               🚀 STARTUP MANAGER LITE — Quick Auto-Optimizer               ║
║                                                                            ║
║  Lightweight version that automatically disables known bloatware           ║
║  without an interactive menu. Just run and go.                             ║
║                                                                            ║
║  What it does:                                                             ║
║    • Scans all startup locations (Registry + Startup folders)              ║
║    • Auto-disables known safe bloatware (updaters, trays, etc.)           ║
║    • Leaves critical items untouched (antivirus, GPU drivers, etc.)       ║
║    • Shows what it disabled and what it kept                               ║
║                                                                            ║
║  For the full interactive version with toggle controls, use:               ║
║    StartupManager.ps1                                                      ║
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
$LogFile = "$env:USERPROFILE\StartupManagerLite_log.txt"

# ─── Known Safe-to-Disable Bloatware ────────────────────────────────────────
# Only includes items that are ALWAYS safe to disable.
# This is a curated subset — the full version (StartupManager.ps1) has 30+ entries.
$safeBloat = @{
    # Updaters — these check for updates in the background. Run them manually.
    "AdobeAAMUpdater"      = "Adobe Updater"
    "AdobeGCInvoker"       = "Adobe GC Invoker"
    "Adobe Creative Cloud" = "Adobe Creative Cloud"
    "CCXProcess"           = "Adobe CCX Process"
    "AdobeARMservice"      = "Adobe ARM Service"
    "iTunesHelper"         = "iTunes Helper"
    "jusched"              = "Java Update Scheduler"
    "SunJavaUpdateSched"   = "Java Update Scheduler"
    "GoogleUpdate"         = "Google Updater"

    # Tray icons — removing these doesn't affect functionality
    "RtkNGUI64"            = "Realtek Audio Tray"
    "RTHDVCPL"             = "Realtek Audio Manager"
    "RtHDVBg"              = "Realtek HD Audio BG"
    "WavesSvc"             = "Waves MaxxAudio"

    # Communication apps — launch manually
    "Spotify"              = "Spotify"
    "SpotifyWebHelper"     = "Spotify Web Helper"
    "Discord"              = "Discord"
    "Telegram"             = "Telegram"
    "Slack"                = "Slack"
    "Teams"                = "Microsoft Teams"
    "Skype"                = "Skype"

    # Cloud sync — eats background CPU/network
    "OneDrive"             = "Microsoft OneDrive"
    "Dropbox"              = "Dropbox"
    "GoogleDriveFS"        = "Google Drive"

    # OEM / Gaming launchers
    "EpicGamesLauncher"    = "Epic Games Launcher"
    "EADesktop"            = "EA Desktop"
    "NZXT CAM"             = "NZXT CAM"

    # NVIDIA telemetry — not needed for GPU function
    "NvBackend"            = "NVIDIA GeForce Backend"
    "NvTmRep"              = "NVIDIA Telemetry"

    # Misc updaters
    "com.squirrel"         = "Squirrel Updater (Discord/Slack)"
    "CiscoMeetingDaemon"   = "Cisco WebEx Daemon"
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
  ║        🚀  STARTUP MANAGER LITE  🚀                         ║
  ║                                                              ║
  ║       Quick bloat removal — no questions asked.              ║
  ║                                                              ║
  ╚══════════════════════════════════════════════════════════════╝

"@
    Write-Host $banner -ForegroundColor Yellow
}

# ══════════════════════════════════════════════════════════════════════════════
#                              MAIN EXECUTION
# ══════════════════════════════════════════════════════════════════════════════

Clear-Host
Write-Banner
Write-Log "═══════════════════════════════════════════════════"
Write-Log "Startup Manager Lite Started"
Write-Log "═══════════════════════════════════════════════════"

Write-Host "  Scanning startup locations..." -ForegroundColor DarkGray
Write-Host ""

$disabledCount = 0
$keptCount = 0
$totalFound = 0

# ─── Scan Registry Startup Keys ─────────────────────────────────────────────
$registryPaths = @(
    @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"; Approved = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" },
    @{ Path = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"; Approved = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" }
)

foreach ($reg in $registryPaths) {
    if (-not (Test-Path $reg.Path)) { continue }

    $props = Get-ItemProperty -Path $reg.Path -ErrorAction SilentlyContinue
    foreach ($prop in $props.PSObject.Properties) {
        if ($prop.Name -like "PS*") { continue }

        $totalFound++
        $matched = $false

        # Check if this item matches any known bloat
        foreach ($bloatKey in $safeBloat.Keys) {
            if ($prop.Name -match [regex]::Escape($bloatKey)) {
                $matched = $true
                $label = $safeBloat[$bloatKey]

                # Check if already disabled
                $alreadyDisabled = $false
                if (Test-Path $reg.Approved) {
                    $approvedProp = Get-ItemProperty -Path $reg.Approved -Name $prop.Name -ErrorAction SilentlyContinue
                    if ($approvedProp) {
                        $bytes = [byte[]]$approvedProp.$($prop.Name)
                        if ($bytes -and $bytes.Length -ge 1 -and $bytes[0] -ge 3) {
                            $alreadyDisabled = $true
                        }
                    }
                }

                if ($alreadyDisabled) {
                    Write-Host "    ⊘ $label" -ForegroundColor DarkGray -NoNewline
                    Write-Host " — already disabled" -ForegroundColor DarkGray
                }
                else {
                    # Disable it via StartupApproved (same mechanism as Task Manager)
                    if (-not (Test-Path $reg.Approved)) {
                        New-Item -Path $reg.Approved -Force | Out-Null
                    }
                    $disabledBytes = [byte[]](0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
                    Set-ItemProperty -Path $reg.Approved -Name $prop.Name -Value $disabledBytes -Type Binary -Force

                    Write-Host "    ✕ $label" -ForegroundColor Red -NoNewline
                    Write-Host " — Disabled" -ForegroundColor DarkGray
                    Write-Log "  [DISABLED] $($prop.Name) ($label)"
                    $disabledCount++
                }
                break
            }
        }

        if (-not $matched) {
            $keptCount++
        }
    }
}

# ─── Scan Startup Folders ───────────────────────────────────────────────────
$startupFolders = @(
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup",
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
)

foreach ($folder in $startupFolders) {
    if (-not (Test-Path $folder)) { continue }

    $files = Get-ChildItem -Path $folder -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne "desktop.ini" }
    foreach ($file in $files) {
        $totalFound++
        $matched = $false

        foreach ($bloatKey in $safeBloat.Keys) {
            if ($file.BaseName -match [regex]::Escape($bloatKey)) {
                $matched = $true
                $label = $safeBloat[$bloatKey]

                # Move to disabled folder
                $disabledFolder = "$env:USERPROFILE\.startup_disabled"
                if (-not (Test-Path $disabledFolder)) {
                    New-Item -Path $disabledFolder -ItemType Directory -Force | Out-Null
                }
                Move-Item -Path $file.FullName -Destination $disabledFolder -Force -ErrorAction SilentlyContinue

                Write-Host "    ✕ $label" -ForegroundColor Red -NoNewline
                Write-Host " — Removed from Startup folder" -ForegroundColor DarkGray
                Write-Log "  [DISABLED] $($file.Name) — moved to .startup_disabled"
                $disabledCount++
                break
            }
        }

        if (-not $matched) {
            $keptCount++
        }
    }
}

# ══════════════════════════════════════════════════════════════════════════════
#                           COMPLETION SUMMARY
# ══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "  ║                                                              ║" -ForegroundColor Yellow
if ($disabledCount -gt 0) {
    Write-Host "  ║   ✅  STARTUP OPTIMIZED!                                    ║" -ForegroundColor Green
}
else {
    Write-Host "  ║   ✅  STARTUP ALREADY CLEAN!                                ║" -ForegroundColor Green
}
Write-Host "  ║                                                              ║" -ForegroundColor Yellow
Write-Host "  ║   📊 Scanned:  $totalFound startup items" -ForegroundColor Yellow
Write-Host "  ║   ✕  Disabled: $disabledCount bloatware items" -ForegroundColor Red
Write-Host "  ║   ✓  Kept:     $keptCount items (critical/unknown)" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Yellow
Write-Host "  ║   📄 Log: $LogFile" -ForegroundColor Yellow
Write-Host "  ║                                                              ║" -ForegroundColor Yellow
Write-Host "  ║   💡 Changes take effect on next restart.                   ║" -ForegroundColor Cyan
Write-Host "  ║   💡 For full control, use StartupManager.ps1               ║" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Yellow
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
Write-Host ""

Write-Log "═══════════════════════════════════════════════════"
Write-Log "Startup Manager Lite Completed — Disabled: $disabledCount, Kept: $keptCount"
Write-Log "═══════════════════════════════════════════════════"

Write-Host "  Press Enter to exit..." -ForegroundColor DarkGray
Read-Host
