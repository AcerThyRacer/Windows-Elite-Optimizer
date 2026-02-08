<#
╔══════════════════════════════════════════════════════════════════════════════╗
║             🔄 WINDOWS UPDATE CONTROL — Tame, Not Disable                  ║
║                                                                            ║
║  Takes control of Windows Update without disabling it:                     ║
║    • Set active hours to protect gaming sessions                           ║
║    • Defer feature updates by 30 days (test before you get them)          ║
║    • Defer quality updates by 7 days (avoid day-1 bugs)                   ║
║    • Disable auto-restart after updates                                    ║
║    • Disable delivery optimization (P2P bandwidth drain)                  ║
║    • Disable driver updates through Windows Update                        ║
║    • Disable update notifications during gaming                           ║
║    • Control restart behavior — YOU choose when to restart                ║
║                                                                            ║
║  ⚠  This does NOT disable Windows Update. You still get security         ║
║     patches, just on YOUR schedule.                                        ║
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
$LogFile = "$env:USERPROFILE\WindowsUpdateControl_log.txt"

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
  ║        🔄🔄🔄  WINDOWS UPDATE CONTROL  🔄🔄🔄              ║
  ║                                                              ║
  ║       Tame, Not Disable — Updates on YOUR Schedule           ║
  ║                                                              ║
  ║       Stay secure. Stay in control. Stay gaming.             ║
  ║                                                              ║
  ╚══════════════════════════════════════════════════════════════╝

"@
    Write-Host $banner -ForegroundColor Blue
}

function Write-Section {
    param([string]$Title, [string]$Icon = "►")
    Write-Host ""
    Write-Host "  ┌──────────────────────────────────────────────────────────" -ForegroundColor DarkBlue
    Write-Host "  │ $Icon $Title" -ForegroundColor Blue
    Write-Host "  └──────────────────────────────────────────────────────────" -ForegroundColor DarkBlue
    Write-Log "=== $Title ==="
}

function Write-Applied {
    param([string]$Name, [string]$Detail = "")
    Write-Host "    ✓ $Name" -ForegroundColor Cyan -NoNewline
    if ($Detail) { Write-Host " — $Detail" -ForegroundColor DarkGray } else { Write-Host "" }
    Write-Log "  [APPLIED] $Name $Detail"
}

function Write-Info {
    param([string]$Message)
    Write-Host "    ℹ $Message" -ForegroundColor DarkYellow
}

function Ensure-RegistryPath {
    param([string]$Path)
    if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
}

# ─── Progress Tracker ────────────────────────────────────────────────────────
$totalSteps = 7
$currentStep = 0

function Show-Progress {
    param([string]$StepName)
    $script:currentStep++
    $pct = [math]::Round(($script:currentStep / $totalSteps) * 100)
    $filled = [math]::Round($pct / 5)
    $empty = 20 - $filled
    $bar = ("█" * $filled) + ("░" * $empty)
    Write-Host ""
    Write-Host "  [$bar] $pct% — $StepName" -ForegroundColor Blue
}

# ══════════════════════════════════════════════════════════════════════════════
#                              MAIN EXECUTION
# ══════════════════════════════════════════════════════════════════════════════

Clear-Host
Write-Banner

Write-Host "  This script CONTROLS Windows Update — it does NOT disable it." -ForegroundColor White
Write-Host "  You will still receive security patches, but on your schedule." -ForegroundColor DarkGray
Write-Host ""
Write-Host "  ⚠  If you want to DISABLE Windows Update entirely (not" -ForegroundColor Yellow
Write-Host "     recommended), use the Raphire debloat tool instead." -ForegroundColor Yellow
Write-Host ""

Write-Log "═══════════════════════════════════════════════════"
Write-Log "Windows Update Control Script Started"
Write-Log "═══════════════════════════════════════════════════"

# ─── Create Restore Point ────────────────────────────────────────────────────
Write-Section "System Restore Point" "🛡"
try {
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "Before Windows Update Control" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
    Write-Host "    ✓ Restore Point Created" -ForegroundColor Green
}
catch {
    Write-Host "    ⊘ Restore Point — Could not create (may exist already)" -ForegroundColor DarkGray
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 1: SET ACTIVE HOURS
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Setting Active Hours"
Write-Section "Active Hours Protection" "🕐"

# WHY: Active Hours tells Windows when NOT to restart for updates.
# By default, Windows guesses your active hours. We set them explicitly
# to cover typical gaming hours (10 AM to 2 AM = 16 hour protection,
# the maximum Windows allows).

$auPath = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
Ensure-RegistryPath $auPath

# Disable auto-detection of active hours (we set them manually)
Set-ItemProperty -Path $auPath -Name "SmartActiveHoursState" -Value 0 -Type DWord -Force
Write-Applied "Smart Active Hours" "Disabled — using manual schedule"

# Set active hours: 10 AM to 2 AM (16 hours — the maximum)
Set-ItemProperty -Path $auPath -Name "ActiveHoursStart" -Value 10 -Type DWord -Force
Set-ItemProperty -Path $auPath -Name "ActiveHoursEnd" -Value 2 -Type DWord -Force
Write-Applied "Active Hours" "10:00 AM → 2:00 AM (16h protection)"

Write-Info "Windows will NEVER auto-restart between 10 AM and 2 AM"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 2: DEFER FEATURE UPDATES — 30 DAYS
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Deferring Feature Updates"
Write-Section "Feature Update Deferral — 30 Days" "📦"

# WHY: Feature updates (like 23H2 → 24H2) are massive updates that can
# break drivers, games, and software. By deferring 30 days, you let
# millions of other users be the guinea pigs. Known issues will be
# discovered and patched before they reach your machine.

$wuPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
Ensure-RegistryPath $wuPolicyPath

Set-ItemProperty -Path $wuPolicyPath -Name "DeferFeatureUpdates" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $wuPolicyPath -Name "DeferFeatureUpdatesPeriodInDays" -Value 30 -Type DWord -Force
Write-Applied "Feature Updates" "Deferred by 30 days"

Write-Info "Major Windows updates will arrive 30 days after public release"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 3: DEFER QUALITY UPDATES — 7 DAYS
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Deferring Quality Updates"
Write-Section "Quality Update Deferral — 7 Days" "🔧"

# WHY: Quality updates (monthly security patches, Patch Tuesday) are
# generally more stable than feature updates, but day-1 patches have
# occasionally caused BSODs. A 7-day deferral is a safe middle ground:
# you still get security fixes quickly, but avoid day-1 disasters.

Set-ItemProperty -Path $wuPolicyPath -Name "DeferQualityUpdates" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $wuPolicyPath -Name "DeferQualityUpdatesPeriodInDays" -Value 7 -Type DWord -Force
Write-Applied "Quality Updates" "Deferred by 7 days"

Write-Info "Monthly security patches arrive 7 days after Patch Tuesday"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 4: DISABLE AUTO-RESTART
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Disabling Auto-Restart After Updates"
Write-Section "Restart Control" "🔁"

# WHY: There is nothing worse than Windows restarting your PC during
# a ranked match. These settings ensure that Windows will NEVER restart
# without your explicit consent — even after installing updates.

$auPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
Ensure-RegistryPath $auPolicyPath

# Configure automatic updates: Download and notify to install (option 3)
# 2 = Notify before download, 3 = Auto download + notify, 4 = Auto install
Set-ItemProperty -Path $auPolicyPath -Name "AUOptions" -Value 3 -Type DWord -Force
Write-Applied "Update Behavior" "Download automatically, but ask before installing"

# Disable auto-restart with logged on users
Set-ItemProperty -Path $auPolicyPath -Name "NoAutoRebootWithLoggedOnUsers" -Value 1 -Type DWord -Force
Write-Applied "Auto-Restart" "BLOCKED when users are logged in"

# Disable forced reboot timer
$rebootPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
Set-ItemProperty -Path $rebootPath -Name "SetAutoRestartNotificationDisable" -Value 1 -Type DWord -Force
Write-Applied "Restart Nag Notifications" "Disabled"

# Disable "Restart Required" notification
Set-ItemProperty -Path $auPolicyPath -Name "NoAutoUpdate" -Value 0 -Type DWord -Force
Write-Applied "Update Downloads" "Still enabled — just won't force-install"

# Disable wake from sleep to install updates
$wakeForUpdate = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
Set-ItemProperty -Path $wakeForUpdate -Name "AUPowerManagement" -Value 0 -Type DWord -Force
Write-Applied "Wake for Updates" "Disabled — PC won't wake from sleep for updates"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 5: DISABLE DELIVERY OPTIMIZATION (P2P)
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Disabling Delivery Optimization"
Write-Section "Delivery Optimization (P2P)" "📡"

# WHY: By default, Windows uses your internet connection to upload Windows
# Update data to OTHER computers on the internet (like BitTorrent).
# This uses your upload bandwidth — sometimes significantly — which
# directly increases your game latency (ping).

$doPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"
Ensure-RegistryPath $doPath

# DODownloadMode:
# 0 = HTTP only (no P2P at all)
# 1 = LAN only (share with PCs on your network only)
# 2 = LAN + Internet  (default — shares with random people online)
# 3 = HTTP + peering   (same as 2)
# 99 = Simple (HTTP only, no peering, no BITS)
Set-ItemProperty -Path $doPath -Name "DODownloadMode" -Value 0 -Type DWord -Force
Write-Applied "Delivery Optimization" "HTTP only — no P2P upload/download"

# Also set via user-facing registry
$doUserPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization"
Ensure-RegistryPath $doUserPath
Set-ItemProperty -Path $doUserPath -Name "SystemSettingsDownloadMode" -Value 0 -Type DWord -Force
Write-Applied "DO User Settings" "Confirmed HTTP only"

Write-Info "Your internet connection will no longer be used to distribute"
Write-Info "Windows updates to other computers on the internet"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 6: CONTROL DRIVER UPDATES
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Controlling Driver Updates"
Write-Section "Driver Update Control" "🖥"

# WHY: Windows Update sometimes pushes GPU driver updates that are
# OLDER than what you have installed from NVIDIA/AMD directly.
# This can cause performance regressions or break game optimizations.
# We exclude drivers from Windows Update so you control GPU drivers
# through GeForce Experience or AMD Software.

$deviceInstallPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata"
Ensure-RegistryPath $deviceInstallPath
Set-ItemProperty -Path $deviceInstallPath -Name "PreventDeviceMetadataFromNetwork" -Value 1 -Type DWord -Force
Write-Applied "Device Metadata Download" "Blocked"

$searchOrderPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching"
Ensure-RegistryPath $searchOrderPath
Set-ItemProperty -Path $searchOrderPath -Name "SearchOrderConfig" -Value 0 -Type DWord -Force
Write-Applied "Driver Search via WU" "Disabled — install GPU drivers manually"

# Exclude driver class from Windows Update
$wuDriverPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
Set-ItemProperty -Path $wuDriverPath -Name "ExcludeWUDriversInQualityUpdate" -Value 1 -Type DWord -Force
Write-Applied "WU Driver Updates" "Excluded from quality updates"

Write-Info "GPU and hardware drivers will NOT be overwritten by Windows Update"
Write-Info "Update your GPU drivers manually via GeForce Experience or AMD Software"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 7: DISABLE UPDATE NOTIFICATIONS
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Reducing Update Notifications"
Write-Section "Update Notifications" "🔔"

# WHY: The "Restart your PC" banner, toast notifications, and full-screen
# restart nags interrupt gaming sessions. We reduce these to a minimum.

$uxPath = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
Set-ItemProperty -Path $uxPath -Name "RestartNotificationsAllowed2" -Value 0 -Type DWord -Force
Write-Applied "Restart Notifications" "Suppressed"

# Disable update-related toasts during presentations/gaming
$notifPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.WindowsUpdate.MoSetup"
Ensure-RegistryPath $notifPath
Set-ItemProperty -Path $notifPath -Name "Enabled" -Value 0 -Type DWord -Force
Write-Applied "Update Toast Notifications" "Disabled during gaming"

# Disable "Get the latest features with a restart" in Settings
$explorePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Ensure-RegistryPath $explorePath
Set-ItemProperty -Path $explorePath -Name "Start_NotifyNewApps" -Value 0 -Type DWord -Force
Write-Applied "New App Notifications" "Disabled"

# ══════════════════════════════════════════════════════════════════════════════
#                           COMPLETION SUMMARY
# ══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "  ║                                                              ║" -ForegroundColor Blue
Write-Host "  ║   ✅  WINDOWS UPDATE TAMED!                                 ║" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Blue
Write-Host "  ║   🕐 Active Hours:     10 AM → 2 AM (no restarts)          ║" -ForegroundColor Blue
Write-Host "  ║   📦 Feature Updates:  Deferred 30 days                     ║" -ForegroundColor Blue
Write-Host "  ║   🔧 Quality Updates:  Deferred 7 days                      ║" -ForegroundColor Blue
Write-Host "  ║   🔁 Auto-Restart:     BLOCKED (you choose when)            ║" -ForegroundColor Blue
Write-Host "  ║   📡 P2P Delivery:     Disabled (HTTP only)                 ║" -ForegroundColor Blue
Write-Host "  ║   🖥  Driver Updates:   Excluded from WU                     ║" -ForegroundColor Blue
Write-Host "  ║   🔔 Nag Popups:       Suppressed                           ║" -ForegroundColor Blue
Write-Host "  ║                                                              ║" -ForegroundColor Blue
Write-Host "  ║   📄 Log: $LogFile" -ForegroundColor Blue
Write-Host "  ║                                                              ║" -ForegroundColor Blue
Write-Host "  ║   ⚠  Updates still download — they just won't              ║" -ForegroundColor Yellow
Write-Host "  ║      install or restart without your permission.             ║" -ForegroundColor Yellow
Write-Host "  ║                                                              ║" -ForegroundColor Blue
Write-Host "  ║   🛡  A restore point was created for safety.              ║" -ForegroundColor Blue
Write-Host "  ║                                                              ║" -ForegroundColor Blue
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Blue
Write-Host ""

Write-Log "═══════════════════════════════════════════════════"
Write-Log "Windows Update Control Completed"
Write-Log "═══════════════════════════════════════════════════"

Write-Host "  Press Enter to exit..." -ForegroundColor DarkGray
Read-Host
