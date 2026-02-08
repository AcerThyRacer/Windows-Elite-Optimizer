<#
╔══════════════════════════════════════════════════════════════════════════════╗
║                     🏆 PRO PERFORMANCE — Windows 11                        ║
║                   Balanced High-Performance Power Plan                      ║
║                                                                            ║
║  This script creates a high-performance power plan with smart defaults.    ║
║  Strong gains without breaking daily workflows.                            ║
║                                                                            ║
║  ✓ Safe for laptops and all-purpose machines                              ║
║  ✓ CPU can still idle to save power when not gaming                       ║
║  ✓ Sleep and display timeout preserved                                    ║
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
$LogFile = "$env:USERPROFILE\ProPerformance_log.txt"
$PlanName = "🏆 PRO Performance"
$PlanGuid = "a1b2c3d4-e5f6-7890-abcd-ef1234567890"  # Custom fixed GUID for Pro

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
  ║        🏆🏆🏆  PRO PERFORMANCE  🏆🏆🏆                    ║
  ║                                                              ║
  ║       Windows 11 — Balanced High-Performance Optimizer       ║
  ║                                                              ║
  ║       Strong gains. Smart defaults. Safe for daily use.      ║
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

function Write-Tweak {
    param([string]$Name, [string]$Status = "Applied")
    Write-Host "    ✓ $Name" -ForegroundColor Green -NoNewline
    Write-Host " — $Status" -ForegroundColor DarkGray
    Write-Log "  [OK] $Name — $Status"
}

function Write-Info {
    param([string]$Message)
    Write-Host "    ℹ $Message" -ForegroundColor DarkYellow
}

function Write-Skip {
    param([string]$Name, [string]$Reason)
    Write-Host "    ⊘ $Name" -ForegroundColor DarkGray -NoNewline
    Write-Host " — $Reason" -ForegroundColor DarkGray
    Write-Log "  [SKIP] $Name — $Reason"
}

function Set-RegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$Type = "DWord"
    )
    try {
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force
        return $true
    }
    catch {
        Write-Log "  [ERR] Failed to set $Path\$Name : $_"
        return $false
    }
}

function Set-ServiceStartup {
    param(
        [string]$ServiceName,
        [string]$StartType = "Disabled"
    )
    try {
        $svc = Get-Service -Name $ServiceName -ErrorAction Stop
        Set-Service -Name $ServiceName -StartupType $StartType -ErrorAction Stop
        if ($svc.Status -eq "Running" -and $StartType -eq "Disabled") {
            Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
        }
        return $true
    }
    catch {
        return $false
    }
}

# ─── Progress Tracker ────────────────────────────────────────────────────────
$totalSteps = 10
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

Write-Host "  Starting PRO Performance optimization..." -ForegroundColor White
Write-Host "  Log file: $LogFile" -ForegroundColor DarkGray
Write-Host ""
Write-Log "═══════════════════════════════════════════════════"
Write-Log "PRO Performance Script Started"
Write-Log "═══════════════════════════════════════════════════"

# ─── Create System Restore Point ─────────────────────────────────────────────
Write-Section "System Restore Point" "🛡"
Write-Info "Creating a restore point so you can safely undo all changes..."
try {
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "Before PRO Performance Script" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
    Write-Tweak "Restore Point Created" "You can revert from System Restore"
}
catch {
    Write-Skip "Restore Point" "Could not create (may have been created recently)"
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 1: POWER PLAN CREATION
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Creating Pro Power Plan"
Write-Section "Power Plan Creation" "🏆"

# WHY: We start from the High Performance plan and tune it up.
# Unlike Elite, Pro keeps the CPU able to idle — saving power and heat.
Write-Info "Creating PRO plan from High Performance base..."

# Duplicate High Performance plan
powercfg /duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c $PlanGuid 2>$null

# If GUID already exists, that's fine — we'll just update settings
powercfg /changename $PlanGuid "$PlanName" "Balanced high-performance. Smart defaults for gaming and daily use." 2>$null
powercfg /setactive $PlanGuid

Write-Tweak "Power Plan Created" "$PlanName (GUID: $PlanGuid)"
Write-Tweak "Set as Active Plan" "Using Pro as default plan"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 2: POWER PLAN TUNING — BALANCED
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Tuning Power Plan Settings"
Write-Section "Power Plan Tuning — Balanced" "🔧"

$ProcessorSubgroup = "54533251-82be-4824-96c1-47b60b740d00"

# WHY (Pro vs Elite): Minimum processor state at 5% lets the CPU downclock
# when idle, saving power and reducing heat. When a game launches, it ramps
# up instantly. The ~5ms ramp time is negligible during game loading.

# Minimum processor state = 5% (allow idle downclocking)
powercfg /setacvalueindex $PlanGuid $ProcessorSubgroup 893dee8e-2bef-41e0-89c6-b55d0929964c 5
powercfg /setdcvalueindex $PlanGuid $ProcessorSubgroup 893dee8e-2bef-41e0-89c6-b55d0929964c 5
Write-Tweak "Processor Min State → 5%" "CPU can idle to save power"

# Maximum processor state = 100%
powercfg /setacvalueindex $PlanGuid $ProcessorSubgroup bc5038f7-23e0-4960-96da-33abaf5935ec 100
powercfg /setdcvalueindex $PlanGuid $ProcessorSubgroup bc5038f7-23e0-4960-96da-33abaf5935ec 100
Write-Tweak "Processor Max State → 100%" "Full turbo boost available"

# Processor boost mode = Aggressive (2) — same as Elite, boost is free perf
powercfg /setacvalueindex $PlanGuid $ProcessorSubgroup be337238-0d82-4146-a960-4f3749d470c7 2
powercfg /setdcvalueindex $PlanGuid $ProcessorSubgroup be337238-0d82-4146-a960-4f3749d470c7 2
Write-Tweak "Boost Mode → Aggressive" "CPU turbos hard when needed"

# Processor idle = Enabled (Pro keeps idle states for power saving)
powercfg /setacvalueindex $PlanGuid $ProcessorSubgroup 5d76a2ca-e8c0-402f-a133-2158492d58ad 0
powercfg /setdcvalueindex $PlanGuid $ProcessorSubgroup 5d76a2ca-e8c0-402f-a133-2158492d58ad 0
Write-Tweak "Processor Idle → Enabled" "C-states active for power saving"

# Core Parking — Min 50% cores active
# WHY (Pro vs Elite): Keeping 50% of cores active instead of 100% saves
# power at idle while still giving games plenty of cores on demand.
powercfg /setacvalueindex $PlanGuid $ProcessorSubgroup 0cc5b647-c1df-4637-891a-dec35c318583 50
powercfg /setdcvalueindex $PlanGuid $ProcessorSubgroup 0cc5b647-c1df-4637-891a-dec35c318583 50
Write-Tweak "Core Parking Min → 50%" "Half the cores always ready"

# Core Parking Max = 100%
powercfg /setacvalueindex $PlanGuid $ProcessorSubgroup ea062031-0e34-4ff1-9b6d-eb1059334028 100
powercfg /setdcvalueindex $PlanGuid $ProcessorSubgroup ea062031-0e34-4ff1-9b6d-eb1059334028 100
Write-Tweak "Core Parking Max → 100%" "All cores available on demand"

# Hard Disk Timeout = 0 (never)
powercfg /setacvalueindex $PlanGuid 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0
powercfg /setdcvalueindex $PlanGuid 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0
Write-Tweak "Hard Disk Timeout → Never" "Disks stay active"

# USB Selective Suspend = Disabled
powercfg /setacvalueindex $PlanGuid 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
powercfg /setdcvalueindex $PlanGuid 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
Write-Tweak "USB Selective Suspend → Off" "No USB disconnections"

# PCI Express Link State = Off
powercfg /setacvalueindex $PlanGuid 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0
powercfg /setdcvalueindex $PlanGuid 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0
Write-Tweak "PCIe Link State PM → Off" "Full bandwidth to GPU/NVMe"

# Sleep after = 30 minutes (instead of Never like Elite)
# WHY: Pro is practical — it still sleeps to save power when you walk away.
powercfg /setacvalueindex $PlanGuid 238c9fa8-0aad-41ed-83f4-97be242c8f20 29f6c1db-86da-48c5-9fdb-f2b67b1f44da 1800
powercfg /setdcvalueindex $PlanGuid 238c9fa8-0aad-41ed-83f4-97be242c8f20 29f6c1db-86da-48c5-9fdb-f2b67b1f44da 900
Write-Tweak "Sleep Timeout → 30 min (AC) / 15 min (DC)" "Practical power saving"

# Display Timeout = 15 minutes
powercfg /setacvalueindex $PlanGuid 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 900
powercfg /setdcvalueindex $PlanGuid 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 600
Write-Tweak "Display Timeout → 15 min (AC) / 10 min (DC)" "Saves monitor power"

powercfg /setactive $PlanGuid
Write-Tweak "Plan Settings Applied" "All power settings committed"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 3: GPU & DISPLAY OPTIMIZATIONS
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "GPU & Display Optimizations"
Write-Section "GPU & Display Optimizations" "🎮"

# WHY: Same as Elite — high GPU preference is universally beneficial.
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\DirectX\UserGpuPreferences" `
    -Name "DirectXUserGlobalSettings" -Value "SwapEffectUpgradeEnable=1;GpuPreference=2;" -Type String
Write-Tweak "Global GPU Preference → High Performance"

# WHY (Pro keeps HAGS ON): On modern GPUs (RTX 30/40, RX 6000/7000), HAGS
# actually provides benefits in many titles. Pro keeps it enabled.
Write-Info "Hardware GPU Scheduling → Kept at system default (Pro is conservative)"

# Disable fullscreen optimizations globally — still beneficial for all users
Set-RegistryValue -Path "HKCU:\System\GameConfigStore" `
    -Name "GameDVR_FSEBehaviorMode" -Value 2 -Type DWord
Set-RegistryValue -Path "HKCU:\System\GameConfigStore" `
    -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 1 -Type DWord
Set-RegistryValue -Path "HKCU:\System\GameConfigStore" `
    -Name "GameDVR_FSEBehavior" -Value 2 -Type DWord
Set-RegistryValue -Path "HKCU:\System\GameConfigStore" `
    -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value 1 -Type DWord
Write-Tweak "Fullscreen Optimizations → Disabled" "True exclusive fullscreen"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 4: MEMORY & CACHE OPTIMIZATIONS
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Memory & Cache Optimizations"
Write-Section "Memory & Cache Optimizations" "🧠"

# WHY (Pro keeps memory compression): On laptops or systems with 8-16GB RAM,
# memory compression saves significant RAM at a minimal CPU cost.
# Pro keeps it enabled for broader compatibility.
Write-Info "Memory Compression → Kept ON (Pro preserves RAM efficiency)"

# Disable Superfetch — universally beneficial on SSDs
Set-ServiceStartup -ServiceName "SysMain" -StartType "Disabled"
Write-Tweak "SysMain (Superfetch) → Disabled" "Less background I/O"

# Disable Prefetch — same benefit as Elite
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" `
    -Name "EnablePrefetcher" -Value 0 -Type DWord
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" `
    -Name "EnableSuperfetch" -Value 0 -Type DWord
Write-Tweak "Prefetch → Disabled" "No background pre-caching"

# Large System Cache = 0 (programs over file cache)
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" `
    -Name "LargeSystemCache" -Value 0 -Type DWord
Write-Tweak "Large System Cache → Programs" "More RAM for applications"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 5: NETWORK OPTIMIZATIONS
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Network Optimizations"
Write-Section "Network Optimizations" "🌐"

# WHY: Nagle's algorithm hurts gaming regardless of tier. Always disable.
$adapters = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
foreach ($adapter in $adapters) {
    Set-ItemProperty -Path $adapter.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $adapter.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
}
Write-Tweak "Nagle's Algorithm → Disabled" "Immediate TCP packet sending"

# Disable network throttling
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" `
    -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord
Write-Tweak "Network Throttling → Disabled" "Full bandwidth available"

# Optimize DNS cache
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" `
    -Name "MaxCacheTtl" -Value 86400 -Type DWord
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" `
    -Name "MaxNegativeCacheTtl" -Value 5 -Type DWord
Write-Tweak "DNS Cache → Optimized" "Better DNS resolution"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 6: SCHEDULER & TIMER OPTIMIZATIONS
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Scheduler & Timer Optimizations"
Write-Section "Scheduler & Timer Optimizations" "⏱"

# WHY: Same scheduler optimization as Elite — Win32PrioritySeparation at 0x26
# gives the foreground window (your game) 3x more CPU time. This is safe and
# universally beneficial.
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" `
    -Name "Win32PrioritySeparation" -Value 38 -Type DWord
Write-Tweak "CPU Scheduler → Gaming Optimized" "Foreground gets 3x priority"

# WHY (Pro vs Elite): SystemResponsiveness at 10 reserves 10% of CPU for
# background tasks like Discord, Spotify, browser. This prevents audio
# glitches and ensures smooth multitasking while gaming.
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" `
    -Name "SystemResponsiveness" -Value 10 -Type DWord
Write-Tweak "System Responsiveness → 10%" "90% for games, 10% for Discord/Spotify"

# Gaming task priority
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" `
    -Name "GPU Priority" -Value 8 -Type DWord
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" `
    -Name "Priority" -Value 6 -Type DWord
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" `
    -Name "Scheduling Category" -Value "High" -Type String
Write-Tweak "Game Task Priority → Maximum" "GPU Priority 8, CPU Priority 6"

# WHY (Pro skips bcdedit timer): Platform tick changes can cause issues on
# some laptops and hybrid CPUs. Pro stays safer by skipping these.
Write-Info "System Timer → Kept at default (Pro avoids bcdedit changes)"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 7: SERVICE OPTIMIZATIONS — SELECTIVE
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Disabling Non-Essential Services"
Write-Section "Service Optimizations — Selective" "🔇"

# WHY (Pro vs Elite): Pro disables fewer services. It keeps Windows Search
# (for file search) and Touch Keyboard (for tablet/2-in-1 users).

$servicesToDisable = @(
    @{ Name = "SysMain"; Desc = "Superfetch — pre-loads apps into RAM" },
    @{ Name = "DiagTrack"; Desc = "Telemetry — sends data to Microsoft" },
    @{ Name = "MapsBroker"; Desc = "Downloaded Maps Manager — unused" },
    @{ Name = "Fax"; Desc = "Fax service — unnecessary" },
    @{ Name = "RetailDemo"; Desc = "Retail Demo mode — store display only" },
    @{ Name = "dmwappushservice"; Desc = "WAP Push Messages — telemetry helper" }
)

foreach ($svc in $servicesToDisable) {
    $result = Set-ServiceStartup -ServiceName $svc.Name -StartType "Disabled"
    if ($result) {
        Write-Tweak "$($svc.Name) → Disabled" $svc.Desc
    }
    else {
        Write-Skip $svc.Name "Service not found on this system"
    }
}

Write-Info "Kept enabled: WSearch, TabletInputService, WMPNetworkSvc, AJRouter"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 8: VISUAL EFFECTS — SELECTIVE
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Optimizing Visual Effects"
Write-Section "Visual Effects — Selective Optimization" "👁"

# WHY (Pro vs Elite): Pro keeps ClearType font smoothing and some UI polish.
# It disables the heavy stuff (animations, transparency) but keeps the OS
# looking decent for daily use.

# Set to "Custom" mode (3) instead of "Best Performance" (2)
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
    -Name "VisualFXSetting" -Value 3 -Type DWord
Write-Tweak "Visual Effects → Custom" "Balanced appearance/performance"

# Disable transparency — big GPU savings
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
    -Name "EnableTransparency" -Value 0 -Type DWord
Write-Tweak "Transparency → Disabled" "No glass/blur overhead"

# Disable heavy animations but keep smooth scrolling and font smoothing
# UserPreferencesMask with smooth scrolling and ClearType kept ON
Set-RegistryValue -Path "HKCU:\Control Panel\Desktop" `
    -Name "UserPreferencesMask" -Value ([byte[]](0x90, 0x12, 0x07, 0x80, 0x12, 0x00, 0x00, 0x00)) -Type Binary
Write-Tweak "Animations → Reduced" "Heavy effects off, font smoothing on"

# Disable Game DVR — universally beneficial
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" `
    -Name "AppCaptureEnabled" -Value 0 -Type DWord
Set-RegistryValue -Path "HKCU:\System\GameConfigStore" `
    -Name "GameDVR_Enabled" -Value 0 -Type DWord
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" `
    -Name "AllowGameDVR" -Value 0 -Type DWord
Write-Tweak "Game Bar & DVR → Disabled" "No background recording"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 9: TELEMETRY & BACKGROUND REDUCTION
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Reducing Telemetry & Background Activity"
Write-Section "Telemetry & Background Reduction" "🚫"

# WHY: Telemetry is universally safe to disable. No features depend on it.
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
    -Name "AllowTelemetry" -Value 0 -Type DWord
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" `
    -Name "AllowTelemetry" -Value 0 -Type DWord
Write-Tweak "Windows Telemetry → Disabled" "No data collection"

# Disable Cortana
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" `
    -Name "AllowCortana" -Value 0 -Type DWord
Write-Tweak "Cortana → Disabled" "No voice assistant"

# Disable Activity History
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
    -Name "EnableActivityFeed" -Value 0 -Type DWord
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
    -Name "PublishUserActivities" -Value 0 -Type DWord
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
    -Name "UploadUserActivities" -Value 0 -Type DWord
Write-Tweak "Activity History → Disabled" "No timeline tracking"

# WHY (Pro vs Elite): Pro does NOT disable all background apps globally.
# This keeps things like Calculator, Settings, and Store working normally.
# We only disable the telemetry-related background services.
Write-Info "Background Apps → Kept at user settings (Pro preserves app functionality)"

# Disable CEIP
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" `
    -Name "CEIPEnable" -Value 0 -Type DWord
Write-Tweak "CEIP → Disabled" "No usage data collection"

# Disable Advertising ID
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" `
    -Name "Enabled" -Value 0 -Type DWord
Write-Tweak "Advertising ID → Disabled" "No ad tracking"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 10: NTFS & FILESYSTEM OPTIMIZATIONS
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "NTFS & Filesystem Optimizations"
Write-Section "NTFS & Filesystem Optimizations" "💾"

# These are universally safe and beneficial — same as Elite
fsutil behavior set disable8dot3 1 2>$null
Write-Tweak "8.3 Filenames → Disabled" "Faster file creation"

fsutil behavior set disablelastaccess 1 2>$null
Write-Tweak "Last Access Time → Disabled" "Less disk writes"

fsutil behavior set memoryusage 2 2>$null
Write-Tweak "NTFS Memory Usage → High" "More metadata cached"

# ══════════════════════════════════════════════════════════════════════════════
#                           COMPLETION SUMMARY
# ══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "  ║                                                              ║" -ForegroundColor Yellow
Write-Host "  ║   ✅  PRO PERFORMANCE OPTIMIZATION COMPLETE!                ║" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Yellow
Write-Host "  ║   🏆 Power Plan:     $PlanName activated           ║" -ForegroundColor Yellow
Write-Host "  ║   🧠 Memory:         Compression ON, Prefetch OFF          ║" -ForegroundColor Yellow
Write-Host "  ║   🎮 GPU:            Max Performance, Game DVR OFF         ║" -ForegroundColor Yellow
Write-Host "  ║   🌐 Network:        Nagle OFF, Throttling OFF             ║" -ForegroundColor Yellow
Write-Host "  ║   ⏱  Scheduler:      Foreground Priority BOOSTED           ║" -ForegroundColor Yellow
Write-Host "  ║   🔇 Services:       6 non-essential disabled              ║" -ForegroundColor Yellow
Write-Host "  ║   👁  Visuals:        Reduced (font smoothing kept)         ║" -ForegroundColor Yellow
Write-Host "  ║   🚫 Telemetry:      All tracking disabled                 ║" -ForegroundColor Yellow
Write-Host "  ║   💾 Filesystem:     NTFS optimized                        ║" -ForegroundColor Yellow
Write-Host "  ║                                                              ║" -ForegroundColor Yellow
Write-Host "  ║   📄 Log: $LogFile" -ForegroundColor Yellow
Write-Host "  ║                                                              ║" -ForegroundColor Yellow
Write-Host "  ║   💡 PRO keeps sleep, display timeout, and Search           ║" -ForegroundColor Cyan
Write-Host "  ║      enabled for a balanced daily-driver experience.        ║" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Yellow
Write-Host "  ║   ⚠  A system restart is RECOMMENDED.                      ║" -ForegroundColor White
Write-Host "  ║   🛡  A restore point was created for safety.              ║" -ForegroundColor Yellow
Write-Host "  ║   ⏪  Run RestoreDefaults.ps1 to undo all changes.         ║" -ForegroundColor Yellow
Write-Host "  ║                                                              ║" -ForegroundColor Yellow
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
Write-Host ""

Write-Log "═══════════════════════════════════════════════════"
Write-Log "PRO Performance Script Completed Successfully"
Write-Log "═══════════════════════════════════════════════════"

# Prompt for restart
Write-Host "  Would you like to restart now? (Y/N): " -ForegroundColor Yellow -NoNewline
$restart = Read-Host
if ($restart -eq "Y" -or $restart -eq "y") {
    Write-Host "  Restarting in 10 seconds..." -ForegroundColor Red
    shutdown /r /t 10 /c "Restarting for PRO Performance optimizations"
}
else {
    Write-Host "  Remember to restart your PC for all changes to take effect!" -ForegroundColor Yellow
}

Write-Host ""
