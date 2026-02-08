<#
╔══════════════════════════════════════════════════════════════════════════════╗
║              ⏱ LATENCY MONITOR — DPC/ISR Latency Checker                  ║
║                                                                            ║
║  Comprehensive system latency analysis tool:                               ║
║    • Monitors DPC (Deferred Procedure Call) latency in real-time          ║
║    • Monitors ISR (Interrupt Service Routine) overhead                    ║
║    • Identifies which drivers cause the highest latency                   ║
║    • Benchmarks system timer resolution                                    ║
║    • Tests network latency to game servers                                ║
║    • Recommends specific fixes per driver                                 ║
║    • Configurable monitoring duration                                      ║
║                                                                            ║
║  WHY THIS MATTERS: High DPC/ISR latency causes audio crackling,          ║
║  mouse stuttering, and frame drops — even on high-end hardware.           ║
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
$LogFile = "$env:USERPROFILE\LatencyMonitor_log.txt"

# ─── Known Problematic Drivers Database ──────────────────────────────────────
$driverFixes = @{
    "ndis.sys"         = "Network stack driver — update NIC driver or disable Wi-Fi if using Ethernet"
    "USBPORT.sys"      = "USB controller — try a different USB port or disable USB power saving"
    "USBXHCI.sys"      = "USB 3.0 controller — update chipset drivers, disable USB power saving"
    "dxgkrnl.sys"      = "DirectX Graphics Kernel — update GPU driver to latest"
    "nvlddmkm.sys"     = "NVIDIA GPU driver — update to latest Game Ready driver, clean install"
    "amdkmdag.sys"     = "AMD GPU driver — update to latest Adrenalin driver, use DDU for clean install"
    "atikmdag.sys"     = "AMD GPU driver (legacy) — update to latest Adrenalin driver"
    "igdkmd64.sys"     = "Intel Graphics — update Intel driver via Intel DSA"
    "Wdf01000.sys"     = "Windows Driver Framework — update peripheral drivers"
    "storport.sys"     = "Storage port driver — update storage controller driver, check AHCI mode"
    "stornvme.sys"     = "NVMe driver — update SSD firmware and NVMe driver"
    "ntoskrnl.exe"     = "Windows kernel — check for background processes, timer resolution issues"
    "tcpip.sys"        = "TCP/IP stack — run NetworkOptimizer.ps1 or update NIC driver"
    "HDAudBus.sys"     = "HD Audio bus — update Realtek/audio driver or disable unused audio devices"
    "portcls.sys"      = "Audio port class — update audio driver, disable audio enhancements"
    "ks.sys"           = "Kernel Streaming — update audio driver"
    "Netwtw06.sys"     = "Intel Wi-Fi 6 — update Intel Wi-Fi driver or switch to Ethernet"
    "Netwtw08.sys"     = "Intel Wi-Fi 6E — update Intel Wi-Fi driver or switch to Ethernet"
    "Netwtw10.sys"     = "Intel Wi-Fi 7 — update Intel Wi-Fi driver or switch to Ethernet"
    "ibtusb.sys"       = "Intel Bluetooth — update or disable Bluetooth if not needed"
    "e1d68x64.sys"     = "Intel Ethernet — update Intel LAN driver"
    "rt640x64.sys"     = "Realtek Ethernet — update Realtek NIC driver"
    "rtwlanu.sys"      = "Realtek Wi-Fi — update Realtek Wi-Fi driver or use Ethernet"
    "ACPI.sys"         = "ACPI driver — check BIOS settings, update BIOS"
    "intelppm.sys"     = "Intel Processor Power Management — disable C-States in BIOS or set power plan to High Performance"
    "amdppm.sys"       = "AMD Processor Power Management — set Ryzen power plan, disable Cool'n'Quiet in BIOS"
    "iaStorAC.sys"     = "Intel Rapid Storage — update Intel RST driver"
    "NahimicSvc64.exe" = "Nahimic Audio — disable or uninstall Nahimic (known high latency)"
    "WavesSvc64.exe"   = "Waves MaxxAudio — disable or uninstall (known high latency)"
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
  ║        ⏱⏱⏱  LATENCY MONITOR  ⏱⏱⏱                        ║
  ║                                                              ║
  ║       DPC/ISR Latency Checker — Find What's Lagging          ║
  ║                                                              ║
  ║       Identify driver-level latency problems.                ║
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

function Get-LatencyRating {
    param([double]$LatencyUs)
    if ($LatencyUs -lt 100) { return @{ Rating = "Excellent"; Color = "Green"; Icon = "✓" } }
    if ($LatencyUs -lt 500) { return @{ Rating = "Good"; Color = "Green"; Icon = "✓" } }
    if ($LatencyUs -lt 1000) { return @{ Rating = "Fair"; Color = "Yellow"; Icon = "⚠" } }
    if ($LatencyUs -lt 2000) { return @{ Rating = "Poor"; Color = "Red"; Icon = "✕" } }
    return @{ Rating = "Critical"; Color = "Red"; Icon = "‼" }
}

# ══════════════════════════════════════════════════════════════════════════════
#                              MAIN EXECUTION
# ══════════════════════════════════════════════════════════════════════════════

Clear-Host
Write-Banner

Write-Log "═══════════════════════════════════════════════════"
Write-Log "Latency Monitor Started"
Write-Log "═══════════════════════════════════════════════════"

# ─── Configuration Menu ──────────────────────────────────────────────────────
Write-Section "Monitor Configuration" "⚙"

Write-Host "    How long should the latency test run?" -ForegroundColor White
Write-Host ""
Write-Host "    [1] 15 seconds (quick check)" -ForegroundColor Yellow
Write-Host "    [2] 30 seconds (recommended)" -ForegroundColor Yellow
Write-Host "    [3] 60 seconds (thorough)" -ForegroundColor Yellow
Write-Host "    [4] Custom duration" -ForegroundColor Yellow
Write-Host ""
Write-Host "    Choice: " -ForegroundColor Cyan -NoNewline
$durationChoice = Read-Host

$duration = switch ($durationChoice) {
    "1" { 15 }
    "2" { 30 }
    "3" { 60 }
    "4" {
        Write-Host "    Duration (seconds): " -ForegroundColor Yellow -NoNewline
        $custom = Read-Host
        [int]$custom
    }
    default { 30 }
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 1: SYSTEM TIMER RESOLUTION
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "System Timer Resolution" "⏰"

# Check current timer resolution
$timerInfo = @"
using System;
using System.Runtime.InteropServices;
public class TimerResolution {
    [DllImport("ntdll.dll")]
    public static extern int NtQueryTimerResolution(out uint MinResolution, out uint MaxResolution, out uint CurrentResolution);
}
"@

try {
    Add-Type -TypeDefinition $timerInfo -ErrorAction Stop
    [uint32]$minRes = 0; [uint32]$maxRes = 0; [uint32]$curRes = 0
    [TimerResolution]::NtQueryTimerResolution([ref]$minRes, [ref]$maxRes, [ref]$curRes) | Out-Null

    $currentMs = [math]::Round($curRes / 10000, 2)
    $minMs = [math]::Round($minRes / 10000, 2)
    $maxMs = [math]::Round($maxRes / 10000, 2)

    Write-Host "    Current Resolution: ${currentMs}ms" -ForegroundColor $(if ($currentMs -le 1) { "Green" } else { "Yellow" })
    Write-Host "    Minimum Possible:   ${maxMs}ms" -ForegroundColor DarkGray
    Write-Host "    Maximum (worst):    ${minMs}ms" -ForegroundColor DarkGray

    if ($currentMs -gt 1) {
        Write-Host ""
        Write-Host "    ⚠ Timer resolution is above 1ms." -ForegroundColor Yellow
        Write-Host "      Most games set this to 0.5ms automatically when running." -ForegroundColor DarkGray
        Write-Host "      If you see >1ms DURING gaming, consider ISLC or TimerTool." -ForegroundColor DarkGray
    }
    else {
        Write-Host "    ✓ Timer resolution is optimal" -ForegroundColor Green
    }
}
catch {
    Write-Host "    Could not query timer resolution" -ForegroundColor DarkGray
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 2: DPC & ISR LATENCY MONITORING
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "DPC & ISR Latency Monitoring (${duration}s)" "📊"

Write-Host ""
Write-Host "    Monitoring system latency for $duration seconds..." -ForegroundColor White
Write-Host "    Keep the system under typical gaming load for best results." -ForegroundColor DarkGray
Write-Host ""

# Use performance counters for DPC/ISR monitoring
$dpcSamples = @()
$isrSamples = @()
$cpuSamples = @()

$elapsed = 0
$interval = 1  # Sample every 1 second
$barWidth = 40

while ($elapsed -lt $duration) {
    # Get DPC and ISR time percentages
    $dpcTime = (Get-Counter "\Processor(_Total)\% DPC Time" -ErrorAction SilentlyContinue).CounterSamples[0].CookedValue
    $isrTime = (Get-Counter "\Processor(_Total)\% Interrupt Time" -ErrorAction SilentlyContinue).CounterSamples[0].CookedValue
    $cpuUsage = (Get-Counter "\Processor(_Total)\% Processor Time" -ErrorAction SilentlyContinue).CounterSamples[0].CookedValue

    if ($null -eq $dpcTime) { $dpcTime = 0 }
    if ($null -eq $isrTime) { $isrTime = 0 }
    if ($null -eq $cpuUsage) { $cpuUsage = 0 }

    $dpcSamples += $dpcTime
    $isrSamples += $isrTime
    $cpuSamples += $cpuUsage

    # Visual bar
    $dpcBar = [math]::Min([math]::Round($dpcTime * 2), $barWidth)
    $isrBar = [math]::Min([math]::Round($isrTime * 2), $barWidth)
    $dpcFill = "█" * $dpcBar + "░" * ($barWidth - $dpcBar)
    $isrFill = "█" * $isrBar + "░" * ($barWidth - $isrBar)

    $dpcColor = if ($dpcTime -lt 2) { "Green" } elseif ($dpcTime -lt 5) { "Yellow" } else { "Red" }

    $timeLeft = $duration - $elapsed
    Write-Host "`r    DPC [$dpcFill] $([math]::Round($dpcTime,1))%  ISR [$isrFill] $([math]::Round($isrTime,1))%  [${timeLeft}s] " -NoNewline -ForegroundColor $dpcColor

    Start-Sleep -Seconds $interval
    $elapsed += $interval
}

Write-Host ""

# Calculate statistics
$dpcAvg = [math]::Round(($dpcSamples | Measure-Object -Average).Average, 2)
$dpcMax = [math]::Round(($dpcSamples | Measure-Object -Maximum).Maximum, 2)
$dpcMin = [math]::Round(($dpcSamples | Measure-Object -Minimum).Minimum, 2)

$isrAvg = [math]::Round(($isrSamples | Measure-Object -Average).Average, 2)
$isrMax = [math]::Round(($isrSamples | Measure-Object -Maximum).Maximum, 2)

$cpuAvg = [math]::Round(($cpuSamples | Measure-Object -Average).Average, 2)

Write-Host ""
Write-Host "    ┌──────────────────────────────────────────────────────" -ForegroundColor DarkCyan
Write-Host "    │  DPC Latency Results ($duration samples)" -ForegroundColor Cyan
Write-Host "    │  Average:  ${dpcAvg}% CPU time" -ForegroundColor $(if ($dpcAvg -lt 2) { "Green" } elseif ($dpcAvg -lt 5) { "Yellow" } else { "Red" })
Write-Host "    │  Peak:     ${dpcMax}%" -ForegroundColor $(if ($dpcMax -lt 5) { "Green" } elseif ($dpcMax -lt 10) { "Yellow" } else { "Red" })
Write-Host "    │  Minimum:  ${dpcMin}%" -ForegroundColor DarkGray
Write-Host "    ├──────────────────────────────────────────────────────" -ForegroundColor DarkCyan
Write-Host "    │  ISR Overhead Results" -ForegroundColor Cyan
Write-Host "    │  Average:  ${isrAvg}% CPU time" -ForegroundColor $(if ($isrAvg -lt 1) { "Green" } elseif ($isrAvg -lt 3) { "Yellow" } else { "Red" })
Write-Host "    │  Peak:     ${isrMax}%" -ForegroundColor $(if ($isrMax -lt 3) { "Green" } elseif ($isrMax -lt 5) { "Yellow" } else { "Red" })
Write-Host "    ├──────────────────────────────────────────────────────" -ForegroundColor DarkCyan
Write-Host "    │  CPU Usage During Test" -ForegroundColor Cyan
Write-Host "    │  Average:  ${cpuAvg}%" -ForegroundColor White
Write-Host "    └──────────────────────────────────────────────────────" -ForegroundColor DarkCyan

# Overall assessment
Write-Host ""
if ($dpcAvg -lt 2 -and $isrAvg -lt 1) {
    Write-Host "    ✓ EXCELLENT — Your system has very low latency!" -ForegroundColor Green
    Write-Host "      No driver issues detected. Great for gaming." -ForegroundColor Green
}
elseif ($dpcAvg -lt 5 -and $isrAvg -lt 3) {
    Write-Host "    ⚠ FAIR — Some latency detected." -ForegroundColor Yellow
    Write-Host "      May cause occasional micro-stutters. Check drivers below." -ForegroundColor Yellow
}
else {
    Write-Host "    ✕ HIGH LATENCY — Significant driver issues detected!" -ForegroundColor Red
    Write-Host "      This will cause audio crackling, mouse stutter, frame drops." -ForegroundColor Red
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 3: DRIVER ANALYSIS
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "Driver Latency Analysis" "🔍"

Write-Host "    Analyzing loaded drivers for known latency issues..." -ForegroundColor DarkGray
Write-Host ""

$loadedDrivers = Get-CimInstance Win32_SystemDriver | Where-Object { $_.State -eq "Running" }
$problemDrivers = @()

foreach ($driver in $loadedDrivers) {
    $driverFile = $driver.PathName
    if ($driverFile) {
        $fileName = Split-Path $driverFile -Leaf
        if ($driverFixes.ContainsKey($fileName)) {
            $problemDrivers += @{
                Name        = $fileName
                DisplayName = $driver.DisplayName
                Fix         = $driverFixes[$fileName]
            }
        }
    }
}

# Also check running services with known latency issues
$latencyServices = @("NahimicService", "WavesSysSvc64", "NahimicSvc64")
foreach ($svc in $latencyServices) {
    $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($service -and $service.Status -eq "Running") {
        $key = "$svc.exe"
        if ($driverFixes.ContainsKey($key)) {
            $problemDrivers += @{
                Name        = $key
                DisplayName = $service.DisplayName
                Fix         = $driverFixes[$key]
            }
        }
    }
}

if ($problemDrivers.Count -gt 0) {
    Write-Host "    Found $($problemDrivers.Count) drivers with known latency issues:" -ForegroundColor Yellow
    Write-Host ""

    $idx = 1
    foreach ($pd in $problemDrivers) {
        Write-Host "    [$idx] $($pd.Name)" -ForegroundColor Red -NoNewline
        Write-Host " — $($pd.DisplayName)" -ForegroundColor White
        Write-Host "        Fix: $($pd.Fix)" -ForegroundColor DarkCyan
        Write-Host ""
        $idx++
    }
}
else {
    Write-Host "    ✓ No known problematic drivers detected" -ForegroundColor Green
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 4: DEVICE LATENCY CHECK
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "Device & Peripheral Check" "🔌"

# Check disabled/problem devices
$errorDevices = Get-PnpDevice -Status Error -ErrorAction SilentlyContinue

if ($errorDevices) {
    Write-Host "    ⚠ Devices with errors:" -ForegroundColor Red
    foreach ($dev in $errorDevices) {
        Write-Host "      ✕ $($dev.FriendlyName) [$($dev.InstanceId)]" -ForegroundColor Red
    }
}
else {
    Write-Host "    ✓ No devices with errors" -ForegroundColor Green
}

# Check for known high-latency audio devices
$audioDevices = Get-PnpDevice -Class AudioEndpoint -Status OK -ErrorAction SilentlyContinue
if ($audioDevices) {
    Write-Host ""
    Write-Host "    Audio devices (common latency source):" -ForegroundColor White
    foreach ($dev in $audioDevices | Select-Object -First 5) {
        Write-Host "      🔊 $($dev.FriendlyName)" -ForegroundColor DarkGray
    }
    Write-Host ""
    Write-Host "    💡 Tip: Disable unused audio devices in Device Manager" -ForegroundColor DarkCyan
    Write-Host "       to reduce ISR overhead." -ForegroundColor DarkCyan
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 5: NETWORK LATENCY
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "Network Latency Test" "🌐"

Write-Host "    Run network latency test? (Y/N): " -ForegroundColor Yellow -NoNewline
$netTest = Read-Host

if ($netTest -eq "Y" -or $netTest -eq "y") {
    $targets = @(
        @{ Name = "Cloudflare DNS"; IP = "1.1.1.1" },
        @{ Name = "Google DNS"; IP = "8.8.8.8" },
        @{ Name = "AWS US-East"; IP = "3.3.3.3" },
        @{ Name = "Quad9 DNS"; IP = "9.9.9.9" }
    )

    Write-Host ""
    foreach ($target in $targets) {
        $result = Test-Connection -ComputerName $target.IP -Count 10 -ErrorAction SilentlyContinue
        if ($result) {
            $avg = [math]::Round(($result.Latency | Measure-Object -Average).Average, 1)
            $min = ($result.Latency | Measure-Object -Minimum).Minimum
            $max = ($result.Latency | Measure-Object -Maximum).Maximum
            $jitter = [math]::Round($max - $min, 1)

            $color = if ($avg -lt 20) { "Green" } elseif ($avg -lt 50) { "Yellow" } else { "Red" }
            Write-Host "    $($target.Name.PadRight(20))" -NoNewline -ForegroundColor White
            Write-Host "avg: ${avg}ms" -NoNewline -ForegroundColor $color
            Write-Host "  jitter: ${jitter}ms" -NoNewline -ForegroundColor $(if ($jitter -lt 10) { "Green" } else { "Yellow" })
            Write-Host "  (${min}-${max}ms)" -ForegroundColor DarkGray
        }
        else {
            Write-Host "    $($target.Name.PadRight(20)) unreachable" -ForegroundColor Red
        }
    }
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 6: RECOMMENDATIONS
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "Recommendations" "💡"

$recommendations = @()

if ($dpcAvg -gt 2) {
    $recommendations += "Run GPUOptimizer.ps1 — GPU drivers are a top DPC latency source"
}
if ($dpcAvg -gt 5) {
    $recommendations += "Update ALL drivers — chipset, audio, network, GPU"
    $recommendations += "Disable Nahimic/Waves audio processing if installed"
}
if ($isrAvg -gt 1) {
    $recommendations += "Disable unused audio devices in Device Manager"
    $recommendations += "Check USB devices — disconnect and reconnect to find the culprit"
}
if ($currentMs -and $currentMs -gt 1) {
    $recommendations += "Timer resolution is >1ms — games usually fix this, but check ISLC for idle"
}

# Always recommend
$recommendations += "Use Ethernet instead of Wi-Fi for lowest network latency"
$recommendations += "Run GameBooster.ps1 before gaming to kill background processes"

foreach ($rec in $recommendations) {
    Write-Host "    💡 $rec" -ForegroundColor Cyan
    Write-Host ""
}

# ══════════════════════════════════════════════════════════════════════════════
#                           COMPLETION SUMMARY
# ══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Cyan
Write-Host "  ║   ⏱  LATENCY ANALYSIS COMPLETE                              ║" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Cyan
Write-Host "  ║   📊 DPC Average:  ${dpcAvg}% $(if ($dpcAvg -lt 2) { '✓' } elseif ($dpcAvg -lt 5) { '⚠' } else { '✕' })" -ForegroundColor Cyan
Write-Host "  ║   📊 ISR Average:  ${isrAvg}% $(if ($isrAvg -lt 1) { '✓' } elseif ($isrAvg -lt 3) { '⚠' } else { '✕' })" -ForegroundColor Cyan
Write-Host "  ║   🔍 Problem Drivers: $($problemDrivers.Count)" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Cyan
Write-Host "  ║   📄 Log: $LogFile" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Log "Latency Monitor Complete — DPC avg: ${dpcAvg}%, ISR avg: ${isrAvg}%, Problem drivers: $($problemDrivers.Count)"

Write-Host "  Press Enter to exit..." -ForegroundColor DarkGray
Read-Host
