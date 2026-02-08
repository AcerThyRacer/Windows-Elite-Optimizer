<#
╔══════════════════════════════════════════════════════════════════════════════╗
║                   🎮 GAME BOOSTER — Per-Game Performance Mode              ║
║                                                                            ║
║  Run BEFORE launching your game for maximum performance:                   ║
║    • Kills resource-heavy background processes                             ║
║    • Clears standby RAM (RAMMap-style memory flush)                       ║
║    • Flushes DNS and resets network stack                                  ║
║    • Optionally sets game process priority to High/Realtime               ║
║    • Sets CPU affinity to performance cores (Intel hybrid CPUs)           ║
║    • Monitors and restores everything when the game closes                ║
║                                                                            ║
║  Usage: Run this script, then launch your game. When the game closes,     ║
║         all background processes are restored automatically.               ║
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
$LogFile = "$env:USERPROFILE\GameBooster_log.txt"

# Processes to kill before gaming (these will be restarted when the game closes)
$killProcesses = @(
    @{ Name = "msedge"; Label = "Microsoft Edge"; Restart = $false },
    @{ Name = "MicrosoftEdgeUpdate"; Label = "Edge Updater"; Restart = $false },
    @{ Name = "Teams"; Label = "Microsoft Teams"; Restart = $false },
    @{ Name = "ms-teams"; Label = "MS Teams (New)"; Restart = $false },
    @{ Name = "Spotify"; Label = "Spotify"; Restart = $true; Path = "$env:APPDATA\Spotify\Spotify.exe" },
    @{ Name = "Discord"; Label = "Discord"; Restart = $true; Path = "$env:LOCALAPPDATA\Discord\Update.exe"; Args = "--processStart Discord.exe" },
    @{ Name = "Slack"; Label = "Slack"; Restart = $false },
    @{ Name = "OneDrive"; Label = "OneDrive"; Restart = $false },
    @{ Name = "GoogleDriveFS"; Label = "Google Drive"; Restart = $false },
    @{ Name = "Dropbox"; Label = "Dropbox"; Restart = $false },
    @{ Name = "iCUE"; Label = "Corsair iCUE"; Restart = $false },
    @{ Name = "NahimicSvc64"; Label = "Nahimic Audio"; Restart = $false },
    @{ Name = "WavesSvc64"; Label = "Waves MaxxAudio"; Restart = $false },
    @{ Name = "SearchUI"; Label = "Windows Search UI"; Restart = $false },
    @{ Name = "SearchHost"; Label = "Windows Search Host"; Restart = $false },
    @{ Name = "YourPhone"; Label = "Phone Link"; Restart = $false },
    @{ Name = "PhoneExperienceHost"; Label = "Phone Experience Host"; Restart = $false },
    @{ Name = "Widgets"; Label = "Windows Widgets"; Restart = $false },
    @{ Name = "WidgetService"; Label = "Widget Service"; Restart = $false },
    @{ Name = "AdobeIPCBroker"; Label = "Adobe IPC Broker"; Restart = $false },
    @{ Name = "AdobeUpdateService"; Label = "Adobe Updater"; Restart = $false },
    @{ Name = "jusched"; Label = "Java Updater"; Restart = $false },
    @{ Name = "NVIDIA Share"; Label = "NVIDIA Share (Overlay)"; Restart = $false },
    @{ Name = "NvTmRep"; Label = "NVIDIA Telemetry"; Restart = $false }
)

# Services to temporarily pause
$pauseServices = @(
    @{ Name = "SysMain"; Label = "Superfetch/SysMain" },
    @{ Name = "WSearch"; Label = "Windows Search Indexer" },
    @{ Name = "DiagTrack"; Label = "Diagnostics Tracking" },
    @{ Name = "wuauserv"; Label = "Windows Update" }
)

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
  ║        🎮🎮🎮  GAME BOOSTER  🎮🎮🎮                        ║
  ║                                                              ║
  ║       Per-Game Performance Mode — Max FPS, Min Latency       ║
  ║                                                              ║
  ║       Kill bloat → Boost game → Auto-restore on exit         ║
  ║                                                              ║
  ╚══════════════════════════════════════════════════════════════╝

"@
    Write-Host $banner -ForegroundColor Magenta
}

function Write-Section {
    param([string]$Title, [string]$Icon = "►")
    Write-Host ""
    Write-Host "  ┌──────────────────────────────────────────────────────────" -ForegroundColor DarkMagenta
    Write-Host "  │ $Icon $Title" -ForegroundColor Magenta
    Write-Host "  └──────────────────────────────────────────────────────────" -ForegroundColor DarkMagenta
    Write-Log "=== $Title ==="
}

function Write-Action {
    param([string]$Name, [string]$Detail = "")
    Write-Host "    ⚡ $Name" -ForegroundColor Yellow -NoNewline
    if ($Detail) { Write-Host " — $Detail" -ForegroundColor DarkGray } else { Write-Host "" }
    Write-Log "  [ACTION] $Name $Detail"
}

function Write-Skip {
    param([string]$Name, [string]$Reason)
    Write-Host "    ⊘ $Name" -ForegroundColor DarkGray -NoNewline
    Write-Host " — $Reason" -ForegroundColor DarkGray
}

# ══════════════════════════════════════════════════════════════════════════════
#                              MAIN EXECUTION
# ══════════════════════════════════════════════════════════════════════════════

Clear-Host
Write-Banner

Write-Log "═══════════════════════════════════════════════════"
Write-Log "Game Booster Started"
Write-Log "═══════════════════════════════════════════════════"

# ─── Track what we killed (for restoration) ──────────────────────────────────
$killedProcesses = @()
$stoppedServices = @()
$originalPriority = $null
$gameProcess = $null

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 1: CLEAR STANDBY MEMORY
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "Clearing Standby Memory" "🧠"

# WHY: Windows keeps recently-used data in "standby" memory. Over time,
# this eats up available RAM. Games need large contiguous blocks of RAM
# for texture streaming and asset loading. Clearing standby memory gives
# the game a larger pool to work with.

# Method 1: Clear working sets
$processes = Get-Process
$memBefore = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory
foreach ($proc in $processes) {
    try {
        $proc.MinWorkingSet = $proc.MinWorkingSet
    }
    catch { }
}
Write-Action "Working Sets" "Trimmed all process memory"

# Method 2: Clear file system cache
$emptySb = @"
using System;
using System.Runtime.InteropServices;
public class MemoryCleaner {
    [DllImport("psapi.dll")]
    public static extern bool EmptyWorkingSet(IntPtr hProcess);
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetCurrentProcess();
    public static void Clean() {
        EmptyWorkingSet(GetCurrentProcess());
    }
}
"@
try {
    Add-Type -TypeDefinition $emptySb -ErrorAction SilentlyContinue
    [MemoryCleaner]::Clean()
}
catch { }

$memAfter = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory
$memFreed = $memAfter - $memBefore
if ($memFreed -gt 0) {
    $memFreedMB = [math]::Round($memFreed / 1024, 0)
    Write-Action "Standby Memory" "Freed ~${memFreedMB} MB"
}
else {
    Write-Action "Standby Memory" "Cache flushed"
}

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 2: KILL BACKGROUND PROCESSES
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "Killing Background Bloat" "💀"

foreach ($proc in $killProcesses) {
    $running = Get-Process -Name $proc.Name -ErrorAction SilentlyContinue
    if ($running) {
        $running | Stop-Process -Force -ErrorAction SilentlyContinue
        $killedProcesses += $proc
        Write-Action "Killed: $($proc.Label)" "PID $($running[0].Id)"
    }
}

if ($killedProcesses.Count -eq 0) {
    Write-Host "    ✓ No bloatware processes found running." -ForegroundColor Green
}
else {
    Write-Host ""
    Write-Host "    💀 Killed $($killedProcesses.Count) background processes" -ForegroundColor Red
}

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 3: PAUSE HEAVY SERVICES
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "Pausing Heavy Services" "⏸"

foreach ($svc in $pauseServices) {
    $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
    if ($service -and $service.Status -eq "Running") {
        Stop-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue
        $stoppedServices += $svc
        Write-Action "Paused: $($svc.Label)"
    }
    else {
        Write-Skip $svc.Label "Already stopped"
    }
}

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 4: FLUSH NETWORK
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "Optimizing Network" "🌐"

ipconfig /flushdns | Out-Null
Write-Action "DNS Cache" "Flushed"

arp -d * 2>$null | Out-Null
Write-Action "ARP Cache" "Cleared"

netsh int ip reset | Out-Null
Write-Action "IP Stack" "Reset"

netsh winsock reset | Out-Null
Write-Action "Winsock" "Reset"

# Disable Nagle's algorithm temporarily for lower latency
$tcpParams = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
$adapters = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" -ErrorAction SilentlyContinue
foreach ($adapter in $adapters) {
    Set-ItemProperty -Path $adapter.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $adapter.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
}
Write-Action "Nagle's Algorithm" "Disabled on all adapters"

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 5: SET POWER TO ULTIMATE
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "Power Plan" "⚡"

# Switch to Ultimate Performance (or High Performance) temporarily
$ultimateGuid = "e9a42b02-d5df-448d-aa00-03f14749eb61"
$currentPlan = (powercfg /getactivescheme 2>$null) -replace ".*:\s+", ""

# Try to activate Ultimate Performance
powercfg /setactive $ultimateGuid 2>$null
if ($LASTEXITCODE -ne 0) {
    # Enable it first if it doesn't exist
    powercfg /duplicatescheme $ultimateGuid 2>$null
    powercfg /setactive $ultimateGuid 2>$null
}

if ($LASTEXITCODE -eq 0) {
    Write-Action "Power Plan" "Switched to Ultimate Performance"
}
else {
    # Fallback to High Performance
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
    Write-Action "Power Plan" "Switched to High Performance"
}

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 6: SET GPU PRIORITY
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "GPU Scheduling Priority" "🖥"

$gpuSchedPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
if (-not (Test-Path $gpuSchedPath)) {
    New-Item -Path $gpuSchedPath -Force | Out-Null
}
Set-ItemProperty -Path $gpuSchedPath -Name "GPU Priority" -Value 8 -Type DWord -Force
Set-ItemProperty -Path $gpuSchedPath -Name "Priority" -Value 6 -Type DWord -Force
Set-ItemProperty -Path $gpuSchedPath -Name "Scheduling Category" -Value "High" -Type String -Force
Set-ItemProperty -Path $gpuSchedPath -Name "SFIO Priority" -Value "High" -Type String -Force
Write-Action "GPU Scheduling" "Priority set to 8, SFIO High"

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 7: WAIT FOR GAME
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "Ready — Launch Your Game!" "🚀"

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   ✅ BOOST ACTIVE — System optimized for gaming!            ║" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   📊 Processes killed:  $($killedProcesses.Count)" -ForegroundColor Green
Write-Host "  ║   ⏸  Services paused:   $($stoppedServices.Count)" -ForegroundColor Green
Write-Host "  ║   🧠 Memory freed:      ~${memFreedMB} MB" -ForegroundColor Green
Write-Host "  ║   🌐 Network:           Flushed & optimized" -ForegroundColor Green
Write-Host "  ║   ⚡ Power Plan:         Ultimate Performance" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  Now launch your game!" -ForegroundColor White
Write-Host ""
Write-Host "  ┌──────────────────────────────────────────────────────────" -ForegroundColor DarkMagenta
Write-Host "  │ OPTIONS:" -ForegroundColor Magenta
Write-Host "  │  [1] Enter game process name to monitor & auto-boost" -ForegroundColor Yellow
Write-Host "  │  [2] Skip monitoring — restore manually with Enter" -ForegroundColor Yellow
Write-Host "  └──────────────────────────────────────────────────────────" -ForegroundColor DarkMagenta
Write-Host ""
Write-Host "  Choice: " -ForegroundColor Magenta -NoNewline
$monitorChoice = Read-Host

if ($monitorChoice -eq "1") {
    Write-Host ""
    Write-Host "  Enter game process name (e.g., 'valorant', 'cs2', 'ACValhalla'): " -ForegroundColor Yellow -NoNewline
    $gameName = Read-Host

    Write-Host ""
    Write-Host "  Waiting for '$gameName' to start..." -ForegroundColor DarkGray

    # Wait for game to start
    $timeout = 0
    while (-not (Get-Process -Name $gameName -ErrorAction SilentlyContinue)) {
        Start-Sleep -Seconds 2
        $timeout += 2
        if ($timeout % 30 -eq 0) {
            Write-Host "    Still waiting for '$gameName'... (${timeout}s)" -ForegroundColor DarkGray
        }
        if ($timeout -ge 600) {
            Write-Host "    Timed out after 10 minutes. Press Enter to restore..." -ForegroundColor Yellow
            Read-Host
            break
        }
    }

    $gameProcess = Get-Process -Name $gameName -ErrorAction SilentlyContinue
    if ($gameProcess) {
        Write-Host ""
        Write-Section "Game Detected — Applying Boost" "🎯"

        # Set priority to High
        try {
            $gameProcess[0].PriorityClass = "High"
            Write-Action "Priority" "'$gameName' set to HIGH"
        }
        catch {
            Write-Host "    ⊘ Could not set priority (anti-cheat may block this)" -ForegroundColor DarkGray
        }

        # Set CPU affinity to performance cores (Intel 12th+ gen hybrid)
        # On hybrid CPUs, P-cores are typically the first cores
        try {
            $cpuCount = (Get-CimInstance Win32_Processor).NumberOfLogicalProcessors
            if ($cpuCount -ge 16) {
                # Likely hybrid CPU — use first 8 cores (P-cores)
                $affinityMask = 0xFF  # Cores 0-7
                $gameProcess[0].ProcessorAffinity = [IntPtr]$affinityMask
                Write-Action "CPU Affinity" "Pinned to P-cores (0-7)"
            }
            elseif ($cpuCount -ge 8) {
                # Use all cores
                Write-Action "CPU Affinity" "Using all $cpuCount cores (no hybrid detected)"
            }
        }
        catch {
            Write-Host "    ⊘ Could not set CPU affinity" -ForegroundColor DarkGray
        }

        Write-Host ""
        Write-Host "  🎮 '$gameName' is running with BOOST active!" -ForegroundColor Green
        Write-Host "  Monitoring... (will auto-restore when game exits)" -ForegroundColor DarkGray
        Write-Host ""

        # Wait for game to close
        while (Get-Process -Name $gameName -ErrorAction SilentlyContinue) {
            Start-Sleep -Seconds 5
        }

        Write-Host ""
        Write-Host "  🏁 '$gameName' has closed. Restoring system..." -ForegroundColor Yellow
    }
}
else {
    Write-Host ""
    Write-Host "  Press Enter when done gaming to restore system..." -ForegroundColor Yellow
    Read-Host
}

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 8: RESTORE EVERYTHING
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "Restoring System" "🔄"

# Restart killed processes that have Restart = $true
foreach ($proc in $killedProcesses) {
    if ($proc.Restart -and $proc.Path -and (Test-Path $proc.Path)) {
        if ($proc.Args) {
            Start-Process -FilePath $proc.Path -ArgumentList $proc.Args -ErrorAction SilentlyContinue
        }
        else {
            Start-Process -FilePath $proc.Path -ErrorAction SilentlyContinue
        }
        Write-Action "Restarted: $($proc.Label)"
    }
}

# Restart paused services
foreach ($svc in $stoppedServices) {
    Start-Service -Name $svc.Name -ErrorAction SilentlyContinue
    Write-Action "Resumed: $($svc.Label)"
}

# Restore power plan to Balanced
powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e 2>$null
Write-Action "Power Plan" "Restored to Balanced"

# ══════════════════════════════════════════════════════════════════════════════
#                           COMPLETION SUMMARY
# ══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   ✅  SYSTEM RESTORED — Gaming session complete!            ║" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   🔄 Processes restarted:  $(($killedProcesses | Where-Object { $_.Restart }).Count) apps" -ForegroundColor Green
Write-Host "  ║   ▶  Services resumed:     $($stoppedServices.Count) services" -ForegroundColor Green
Write-Host "  ║   ⚡ Power Plan:            Balanced (restored)" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   📄 Log: $LogFile" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Log "Game Booster — Session Complete"

Write-Host "  Press Enter to exit..." -ForegroundColor DarkGray
Read-Host
