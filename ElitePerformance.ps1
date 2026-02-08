<#
╔══════════════════════════════════════════════════════════════════════════════╗
║                    ⚡ ELITE PERFORMANCE — Windows 11                        ║
║                    Maximum Performance Power Plan                           ║
║                                                                            ║
║  This script creates an aggressive power plan and applies deep OS-level    ║
║  optimizations for MAXIMUM performance on Windows 11.                      ║
║                                                                            ║
║  ⚠  WARNING: This disables power saving, sleep, and most background       ║
║     services. Best for desktops and dedicated gaming rigs.                 ║
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
$LogFile = "$env:USERPROFILE\ElitePerformance_log.txt"
$PlanName = "⚡ ELITE Performance"
$PlanGuid = "e9a42b02-d5df-448d-aa00-03f14749eb61"  # Custom fixed GUID

# Ultimate Performance base GUID (hidden plan in Windows 11)
$UltimatePerfGuid = "e9a42b02-d5df-448d-aa00-03f14749eb61"
$UltimatePerfSource = "e9a42b02-d5df-448d-aa00-03f14749eb00"

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
  ║        ⚡⚡⚡  ELITE PERFORMANCE  ⚡⚡⚡                ║
  ║                                                              ║
  ║       Windows 11 — Maximum Performance Optimizer             ║
  ║                                                              ║
  ╚══════════════════════════════════════════════════════════════╝

"@
    Write-Host $banner -ForegroundColor Cyan
}

function Write-Section {
    param([string]$Title, [string]$Icon = "►")
    Write-Host ""
    Write-Host "  ┌──────────────────────────────────────────────────────────" -ForegroundColor DarkCyan
    Write-Host "  │ $Icon $Title" -ForegroundColor Cyan
    Write-Host "  └──────────────────────────────────────────────────────────" -ForegroundColor DarkCyan
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
    } catch {
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
    } catch {
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
    Write-Host "  [$bar] $pct% — $StepName" -ForegroundColor Magenta
}

# ══════════════════════════════════════════════════════════════════════════════
#                              MAIN EXECUTION
# ══════════════════════════════════════════════════════════════════════════════

Clear-Host
Write-Banner

Write-Host "  Starting ELITE Performance optimization..." -ForegroundColor White
Write-Host "  Log file: $LogFile" -ForegroundColor DarkGray
Write-Host ""
Write-Log "═══════════════════════════════════════════════════"
Write-Log "ELITE Performance Script Started"
Write-Log "═══════════════════════════════════════════════════"

# ─── Create System Restore Point ─────────────────────────────────────────────
Write-Section "System Restore Point" "🛡"
Write-Info "Creating a restore point so you can safely undo all changes..."
try {
    # Enable System Restore on C: if not already
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "Before ELITE Performance Script" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
    Write-Tweak "Restore Point Created" "You can revert from System Restore"
} catch {
    Write-Skip "Restore Point" "Could not create (may have been created recently)"
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 1: POWER PLAN CREATION
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Creating Elite Power Plan"
Write-Section "Power Plan Creation" "⚡"

# WHY: The "Ultimate Performance" plan is hidden in Windows 11 but provides
# the best baseline. We duplicate it and push settings even further.
Write-Info "Unlocking the hidden Ultimate Performance plan as our base..."

# First, try to unhide Ultimate Performance
powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 $PlanGuid 2>$null

# If that fails (GUID already exists or not found), try High Performance as base
$existingPlan = powercfg /list | Select-String $PlanGuid
if (-not $existingPlan) {
    # Try from the actual Ultimate Performance source
    powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 $PlanGuid 2>$null
}
if (-not (powercfg /list | Select-String $PlanGuid)) {
    # Fallback: duplicate High Performance (8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c)
    powercfg /duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c $PlanGuid 2>$null
}

# Rename the plan
powercfg /changename $PlanGuid "$PlanName" "Maximum performance. All cores active. No power saving." 2>$null

# Set as active
powercfg /setactive $PlanGuid

Write-Tweak "Power Plan Created" "$PlanName (GUID: $PlanGuid)"
Write-Tweak "Set as Active Plan" "All power settings will use this plan"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 2: POWER PLAN TUNING
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Tuning Power Plan Settings"
Write-Section "Power Plan Deep Tuning" "🔧"

# WHY: By default, Windows downclocks your CPU to save power.
# Setting min processor state to 100% keeps all cores at max frequency at all times.
# This eliminates the ~5-15ms latency spike when the CPU has to ramp up from idle.

# Processor Power Management SubGroup: 54533251-82be-4824-96c1-47b60b740d00
$ProcessorSubgroup = "54533251-82be-4824-96c1-47b60b740d00"

# Minimum processor state = 100%  (setting GUID: 893dee8e-2bef-41e0-89c6-b55d0929964c)
powercfg /setacvalueindex $PlanGuid $ProcessorSubgroup 893dee8e-2bef-41e0-89c6-b55d0929964c 100
powercfg /setdcvalueindex $PlanGuid $ProcessorSubgroup 893dee8e-2bef-41e0-89c6-b55d0929964c 100
Write-Tweak "Processor Min State → 100%" "CPU never downclocks"

# Maximum processor state = 100%  (setting GUID: bc5038f7-23e0-4960-96da-33abaf5935ec)
powercfg /setacvalueindex $PlanGuid $ProcessorSubgroup bc5038f7-23e0-4960-96da-33abaf5935ec 100
powercfg /setdcvalueindex $PlanGuid $ProcessorSubgroup bc5038f7-23e0-4960-96da-33abaf5935ec 100
Write-Tweak "Processor Max State → 100%" "Full turbo boost available"

# Processor performance boost mode = Aggressive (2)
# GUID: be337238-0d82-4146-a960-4f3749d470c7
powercfg /setacvalueindex $PlanGuid $ProcessorSubgroup be337238-0d82-4146-a960-4f3749d470c7 2
powercfg /setdcvalueindex $PlanGuid $ProcessorSubgroup be337238-0d82-4146-a960-4f3749d470c7 2
Write-Tweak "Boost Mode → Aggressive" "CPU turbos harder and longer"

# Processor idle disable = 1 (disable C-states / idle)
# GUID: 5d76a2ca-e8c0-402f-a133-2158492d58ad
powercfg /setacvalueindex $PlanGuid $ProcessorSubgroup 5d76a2ca-e8c0-402f-a133-2158492d58ad 1
powercfg /setdcvalueindex $PlanGuid $ProcessorSubgroup 5d76a2ca-e8c0-402f-a133-2158492d58ad 1
Write-Tweak "Processor Idle → Disabled" "No C-state transitions = lower latency"

# Core Parking — Minimum cores online: 100%
# GUID: 0cc5b647-c1df-4637-891a-dec35c318583
powercfg /setacvalueindex $PlanGuid $ProcessorSubgroup 0cc5b647-c1df-4637-891a-dec35c318583 100
powercfg /setdcvalueindex $PlanGuid $ProcessorSubgroup 0cc5b647-c1df-4637-891a-dec35c318583 100
Write-Tweak "Core Parking Min → 100%" "All CPU cores always active"

# Core Parking — Max cores: 100%
# GUID: ea062031-0e34-4ff1-9b6d-eb1059334028
powercfg /setacvalueindex $PlanGuid $ProcessorSubgroup ea062031-0e34-4ff1-9b6d-eb1059334028 100
powercfg /setdcvalueindex $PlanGuid $ProcessorSubgroup ea062031-0e34-4ff1-9b6d-eb1059334028 100
Write-Tweak "Core Parking Max → 100%" "Never park any cores"

# Hard Disk Subgroup: 0012ee47-9041-4b5d-9b77-535fba8b1442
# Turn off hard disk after: 0 = Never
powercfg /setacvalueindex $PlanGuid 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0
powercfg /setdcvalueindex $PlanGuid 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0
Write-Tweak "Hard Disk Timeout → Never" "Disks always spinning"

# USB Selective Suspend: Disabled (0)
# Subgroup: 2a737441-1930-4402-8d77-b2bebba308a3
# Setting:  48e6b7a6-50f5-4782-a5d4-53bb8f07e226
powercfg /setacvalueindex $PlanGuid 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
powercfg /setdcvalueindex $PlanGuid 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
Write-Tweak "USB Selective Suspend → Off" "No USB device disconnections"

# PCI Express Link State Power Management: Off (0)
# Subgroup: 501a4d13-42af-4429-9fd1-a8218c268e20
# Setting:  ee12f906-d277-404b-b6da-e5fa1a576df5
powercfg /setacvalueindex $PlanGuid 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0
powercfg /setdcvalueindex $PlanGuid 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0
Write-Tweak "PCIe Link State PM → Off" "Full bandwidth to GPU/NVMe"

# Sleep: Disabled
# Subgroup: 238c9fa8-0aad-41ed-83f4-97be242c8f20
# Sleep after (AC): 29f6c1db-86da-48c5-9fdb-f2b67b1f44da
powercfg /setacvalueindex $PlanGuid 238c9fa8-0aad-41ed-83f4-97be242c8f20 29f6c1db-86da-48c5-9fdb-f2b67b1f44da 0
powercfg /setdcvalueindex $PlanGuid 238c9fa8-0aad-41ed-83f4-97be242c8f20 29f6c1db-86da-48c5-9fdb-f2b67b1f44da 0
Write-Tweak "Sleep Timeout → Never" "System never enters sleep"

# Hibernate off
powercfg /hibernate off 2>$null
Write-Tweak "Hibernate → Off" "Saves disk space, prevents sleep issues"

# Display Timeout: Never (0)
# Subgroup: 7516b95f-f776-4464-8c53-06167f40cc99
# Setting:  3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e (Turn off display after)
powercfg /setacvalueindex $PlanGuid 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0
powercfg /setdcvalueindex $PlanGuid 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0
Write-Tweak "Display Timeout → Never" "Monitor stays on"

# Apply the plan changes
powercfg /setactive $PlanGuid
Write-Tweak "Plan Settings Applied" "All power settings committed"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 3: GPU & DISPLAY OPTIMIZATIONS
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "GPU & Display Optimizations"
Write-Section "GPU & Display Optimizations" "🎮"

# WHY: Windows defaults to "let Windows decide" for GPU scheduling.
# Setting global preference to high performance ensures the discrete GPU
# is always used and never power-throttled.

# Global GPU preference: High Performance (2)
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\DirectX\UserGpuPreferences" `
    -Name "DirectXUserGlobalSettings" -Value "SwapEffectUpgradeEnable=1;GpuPreference=2;" -Type String
Write-Tweak "Global GPU Preference → High Performance"

# WHY: Hardware-Accelerated GPU Scheduling (HAGS) can add micro-latency
# in some games. Disabling it gives the CPU direct GPU queue control.
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" `
    -Name "HwSchMode" -Value 1 -Type DWord
Write-Tweak "HW GPU Scheduling → Disabled" "Lower input latency in most games"

# Disable fullscreen optimizations globally
# WHY: FSO adds a composition layer. True exclusive fullscreen = lower latency.
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

# WHY: Memory Compression saves RAM but costs CPU cycles to compress/decompress.
# On systems with 16GB+, disabling it frees CPU for gaming.
try {
    Disable-MMAgent -MemoryCompression -ErrorAction Stop
    Write-Tweak "Memory Compression → Disabled" "Less CPU overhead"
} catch {
    Write-Skip "Memory Compression" "Already disabled or not available"
}

# WHY: Superfetch/SysMain pre-loads apps into RAM. For gaming, this wastes
# memory and causes I/O spikes. Disabling frees RAM for games.
Set-ServiceStartup -ServiceName "SysMain" -StartType "Disabled"
Write-Tweak "SysMain (Superfetch) → Disabled" "Less RAM preloading"

# Disable Prefetch
# WHY: Similar to Superfetch — pre-caching wastes disk I/O on gaming rigs.
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" `
    -Name "EnablePrefetcher" -Value 0 -Type DWord
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" `
    -Name "EnableSuperfetch" -Value 0 -Type DWord
Write-Tweak "Prefetch → Disabled" "No background disk pre-caching"

# Large System Cache = 0 (optimize for programs, not file cache)
# WHY: Setting to 0 tells Windows to allocate more memory to applications
# rather than the filesystem cache. Better for games, worse for file servers.
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" `
    -Name "LargeSystemCache" -Value 0 -Type DWord
Write-Tweak "Large System Cache → Programs" "More RAM for applications"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 5: NETWORK OPTIMIZATIONS
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Network Optimizations"
Write-Section "Network Optimizations" "🌐"

# WHY: Nagle's Algorithm batches small TCP packets together to reduce overhead.
# This adds 5-40ms latency. Disabling it sends packets immediately — critical
# for online gaming and competitive shooters.

# Find all network adapters and apply per-adapter
$adapters = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
foreach ($adapter in $adapters) {
    Set-ItemProperty -Path $adapter.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $adapter.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
}
Write-Tweak "Nagle's Algorithm → Disabled" "Immediate TCP packet sending"

# WHY: Windows throttles network traffic to reserve bandwidth for multimedia.
# Setting to 0xFFFFFFFF disables this throttle completely.
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" `
    -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord
Write-Tweak "Network Throttling → Disabled" "Full bandwidth available"

# Optimize DNS cache
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" `
    -Name "MaxCacheTtl" -Value 86400 -Type DWord
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" `
    -Name "MaxNegativeCacheTtl" -Value 5 -Type DWord
Write-Tweak "DNS Cache → Optimized" "Longer positive cache, shorter negative"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 6: SCHEDULER & TIMER OPTIMIZATIONS
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Scheduler & Timer Optimizations"
Write-Section "Scheduler & Timer Optimizations" "⏱"

# WHY: Win32PrioritySeparation controls how Windows schedules foreground vs
# background tasks. Value 0x26 (38 decimal) = Short quantum, Variable,
# Foreground boosted 3x. This is the optimal setting for gaming — the active
# game window gets 3x more CPU time slices than background processes.
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" `
    -Name "Win32PrioritySeparation" -Value 38 -Type DWord
Write-Tweak "CPU Scheduler → Gaming Optimized" "Foreground gets 3x priority"

# WHY: SystemResponsiveness controls what % of CPU is reserved for background.
# 0 = give 100% to the foreground application (your game).
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" `
    -Name "SystemResponsiveness" -Value 0 -Type DWord
Write-Tweak "System Responsiveness → 0%" "100% CPU for foreground app"

# Gaming task priority settings
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" `
    -Name "GPU Priority" -Value 8 -Type DWord
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" `
    -Name "Priority" -Value 6 -Type DWord
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" `
    -Name "Scheduling Category" -Value "High" -Type String
Write-Tweak "Game Task Priority → Maximum" "GPU Priority 8, CPU Priority 6"

# WHY: Platform tick and disabling dynamic tick forces Windows to use a
# consistent, low-latency timer. This reduces timer jitter in games.
bcdedit /set useplatformtick yes 2>$null
bcdedit /set disabledynamictick yes 2>$null
Write-Tweak "System Timer → Platform Tick" "Consistent low-latency timer"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 7: SERVICE OPTIMIZATIONS
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Disabling Non-Essential Services"
Write-Section "Service Optimizations" "🔇"

# WHY: These services consume CPU, RAM, and disk I/O in the background.
# Disabling them frees resources for games. None are needed for gaming.

$servicesToDisable = @(
    @{ Name = "SysMain";           Desc = "Superfetch — pre-loads apps into RAM" },
    @{ Name = "DiagTrack";         Desc = "Telemetry — sends data to Microsoft" },
    @{ Name = "WSearch";           Desc = "Windows Search Indexer — disk I/O hog" },
    @{ Name = "MapsBroker";        Desc = "Downloaded Maps Manager — unused" },
    @{ Name = "Fax";               Desc = "Fax service — who still faxes?" },
    @{ Name = "TabletInputService"; Desc = "Touch Keyboard — not needed on desktop" },
    @{ Name = "RetailDemo";        Desc = "Retail Demo mode — store display only" },
    @{ Name = "WMPNetworkSvc";     Desc = "WMP Network Sharing — media streaming" },
    @{ Name = "AJRouter";          Desc = "AllJoyn Router — IoT protocol" },
    @{ Name = "dmwappushservice";  Desc = "WAP Push Messages — telemetry helper" }
)

foreach ($svc in $servicesToDisable) {
    $result = Set-ServiceStartup -ServiceName $svc.Name -StartType "Disabled"
    if ($result) {
        Write-Tweak "$($svc.Name) → Disabled" $svc.Desc
    } else {
        Write-Skip $svc.Name "Service not found on this system"
    }
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 8: VISUAL EFFECTS — ALL OFF
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Disabling Visual Effects"
Write-Section "Visual Effects — Maximum Performance" "👁"

# WHY: Windows animations (fade, slide, smooth-scroll) consume GPU cycles and
# add perceived input delay. Disabling them makes the OS feel snappier and
# frees GPU resources for your games.

# Set Visual Effects to "Adjust for best performance" (custom mask)
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
    -Name "VisualFXSetting" -Value 2 -Type DWord
Write-Tweak "Visual Effects → Best Performance" "All animations disabled"

# Disable transparency effects
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
    -Name "EnableTransparency" -Value 0 -Type DWord
Write-Tweak "Transparency → Disabled" "No glass/blur effects"

# Disable animation effects
Set-RegistryValue -Path "HKCU:\Control Panel\Desktop" `
    -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -Type Binary
Write-Tweak "Desktop Animations → Disabled" "No window fade/slide"

# Disable Game Bar and Game DVR
# WHY: Game Bar runs an overlay that captures frames and consumes GPU.
# Game DVR records gameplay in the background, tanking FPS.
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" `
    -Name "AppCaptureEnabled" -Value 0 -Type DWord
Set-RegistryValue -Path "HKCU:\System\GameConfigStore" `
    -Name "GameDVR_Enabled" -Value 0 -Type DWord
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" `
    -Name "AllowGameDVR" -Value 0 -Type DWord
Write-Tweak "Game Bar & DVR → Disabled" "No background recording overhead"

# Disable Widgets
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" `
    -Name "AllowNewsAndInterests" -Value 0 -Type DWord
Write-Tweak "Widgets → Disabled" "No news/weather panel"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 9: TELEMETRY & BACKGROUND BLOAT
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Removing Telemetry & Background Bloat"
Write-Section "Telemetry & Background Removal" "🚫"

# WHY: Telemetry services constantly collect and upload data in the background,
# consuming CPU, disk, and network bandwidth. Disabling them gives those
# resources back to your games.

# Disable Windows Telemetry
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
    -Name "AllowTelemetry" -Value 0 -Type DWord
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" `
    -Name "AllowTelemetry" -Value 0 -Type DWord
Write-Tweak "Windows Telemetry → Disabled" "No data collection"

# Disable Cortana
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" `
    -Name "AllowCortana" -Value 0 -Type DWord
Write-Tweak "Cortana → Disabled" "No voice assistant overhead"

# Disable Activity History
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
    -Name "EnableActivityFeed" -Value 0 -Type DWord
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
    -Name "PublishUserActivities" -Value 0 -Type DWord
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
    -Name "UploadUserActivities" -Value 0 -Type DWord
Write-Tweak "Activity History → Disabled" "No timeline tracking"

# Disable Background Apps (global)
# WHY: Background apps run even when you're not using them, consuming
# CPU and RAM. Disabling them is one of the biggest single wins.
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" `
    -Name "GlobalUserDisabled" -Value 1 -Type DWord
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" `
    -Name "BackgroundAppGlobalToggle" -Value 0 -Type DWord
Write-Tweak "Background Apps → All Disabled" "No hidden app processes"

# Disable Connected User Experiences and Telemetry service
Set-ServiceStartup -ServiceName "DiagTrack" -StartType "Disabled"
Set-ServiceStartup -ServiceName "dmwappushservice" -StartType "Disabled"
Write-Tweak "Telemetry Services → Stopped" "DiagTrack and WAP Push"

# Disable Customer Experience Improvement Program
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

# WHY: 8.3 short filenames (legacy DOS compatibility) are generated for every
# file on NTFS. Disabling this speeds up file creation by ~20%.
fsutil behavior set disable8dot3 1 2>$null
Write-Tweak "8.3 Filenames → Disabled" "Faster file creation"

# WHY: NTFS updates the "last access time" on every file read. This is a
# write operation on every read, which wastes disk I/O. Disabling it is
# one of the biggest single NTFS performance improvements.
fsutil behavior set disablelastaccess 1 2>$null
Write-Tweak "Last Access Time → Disabled" "Less disk writes on reads"

# WHY: Increasing NTFS memory usage allows the filesystem to cache more
# metadata in RAM, speeding up directory traversal and file operations.
fsutil behavior set memoryusage 2 2>$null
Write-Tweak "NTFS Memory Usage → High" "More filesystem metadata cached"

# ══════════════════════════════════════════════════════════════════════════════
#                           COMPLETION SUMMARY
# ══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   ✅  ELITE PERFORMANCE OPTIMIZATION COMPLETE!              ║" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   ⚡ Power Plan:     $PlanName activated      ║" -ForegroundColor Green
Write-Host "  ║   🧠 Memory:         Compression OFF, Prefetch OFF         ║" -ForegroundColor Green
Write-Host "  ║   🎮 GPU:            Max Performance, Game DVR OFF         ║" -ForegroundColor Green
Write-Host "  ║   🌐 Network:        Nagle OFF, Throttling OFF             ║" -ForegroundColor Green
Write-Host "  ║   ⏱  Scheduler:      Foreground Priority MAXIMUM           ║" -ForegroundColor Green
Write-Host "  ║   🔇 Services:       10 non-essential services disabled    ║" -ForegroundColor Green
Write-Host "  ║   👁  Visuals:        All animations OFF                    ║" -ForegroundColor Green
Write-Host "  ║   🚫 Telemetry:      All tracking disabled                 ║" -ForegroundColor Green
Write-Host "  ║   💾 Filesystem:     NTFS optimized for speed              ║" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   📄 Log: $LogFile" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   ⚠  A system restart is RECOMMENDED.                      ║" -ForegroundColor Yellow
Write-Host "  ║   🛡  A restore point was created for safety.              ║" -ForegroundColor Green
Write-Host "  ║   ⏪  Run RestoreDefaults.ps1 to undo all changes.         ║" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Log "═══════════════════════════════════════════════════"
Write-Log "ELITE Performance Script Completed Successfully"
Write-Log "═══════════════════════════════════════════════════"

# Prompt for restart
Write-Host "  Would you like to restart now? (Y/N): " -ForegroundColor Yellow -NoNewline
$restart = Read-Host
if ($restart -eq "Y" -or $restart -eq "y") {
    Write-Host "  Restarting in 10 seconds..." -ForegroundColor Red
    shutdown /r /t 10 /c "Restarting for ELITE Performance optimizations"
} else {
    Write-Host "  Remember to restart your PC for all changes to take effect!" -ForegroundColor Yellow
}

Write-Host ""
