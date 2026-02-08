<#
╔══════════════════════════════════════════════════════════════════════════════╗
║          ⏱ LATENCY MONITOR LITE — Quick 15-Second DPC Check               ║
║                                                                            ║
║  Fast latency check with automatic driver analysis:                        ║
║    ✓ 15-second DPC/ISR monitoring with live bar                           ║
║    ✓ Auto-scans for known problematic drivers                             ║
║    ✓ Shows quick fix recommendations                                      ║
║    ✗ No timer resolution query                                            ║
║    ✗ No network latency test                                              ║
║    ✗ No configurable duration                                             ║
║                                                                            ║
║  For full analysis, use: LatencyMonitor.ps1                               ║
║                                                                            ║
║  Run as Administrator — the script will self-elevate if needed.            ║
╚══════════════════════════════════════════════════════════════════════════════╝
#>

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`n[!] Requesting Administrator privileges..." -ForegroundColor Yellow
    $argList = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Start-Process powershell.exe -ArgumentList $argList -Verb RunAs
    exit
}

$ErrorActionPreference = "SilentlyContinue"
$LogFile = "$env:USERPROFILE\LatencyMonitorLite_log.txt"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp | $Message" | Out-File -FilePath $LogFile -Append -Encoding UTF8
}

# Known problematic drivers
$driverFixes = @{
    "ndis.sys"     = "Update NIC driver or use Ethernet"
    "USBPORT.sys"  = "Disable USB power saving"
    "USBXHCI.sys"  = "Update chipset drivers"
    "dxgkrnl.sys"  = "Update GPU driver"
    "nvlddmkm.sys" = "Update NVIDIA driver (clean install)"
    "amdkmdag.sys" = "Update AMD driver (use DDU)"
    "atikmdag.sys" = "Update AMD driver (use DDU)"
    "igdkmd64.sys" = "Update Intel graphics driver"
    "ntoskrnl.exe" = "Check background processes"
    "tcpip.sys"    = "Run NetworkOptimizer.ps1"
    "HDAudBus.sys" = "Update audio driver"
    "portcls.sys"  = "Update audio driver, disable enhancements"
    "ks.sys"       = "Update audio driver"
    "Netwtw06.sys" = "Update Intel Wi-Fi driver or use Ethernet"
    "Netwtw08.sys" = "Update Intel Wi-Fi driver or use Ethernet"
    "Netwtw10.sys" = "Update Intel Wi-Fi 7 driver"
    "intelppm.sys" = "Disable C-States in BIOS"
    "amdppm.sys"   = "Set Ryzen power plan"
}

Clear-Host
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║        ⏱  LATENCY MONITOR LITE  ⏱                          ║" -ForegroundColor Cyan
Write-Host "  ║       Quick 15-Second DPC/ISR Check                         ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Log "Latency Monitor Lite Started"

# ── DPC/ISR Monitoring (15 seconds) ─────────────────────────────────────────
Write-Host "  ► Monitoring DPC & ISR latency (15 seconds)..." -ForegroundColor Cyan
Write-Host ""

$dpcSamples = @()
$isrSamples = @()
$duration = 15
$elapsed = 0
$barWidth = 40

while ($elapsed -lt $duration) {
    $dpcTime = (Get-Counter "\Processor(_Total)\% DPC Time" -ErrorAction SilentlyContinue).CounterSamples[0].CookedValue
    $isrTime = (Get-Counter "\Processor(_Total)\% Interrupt Time" -ErrorAction SilentlyContinue).CounterSamples[0].CookedValue

    if ($null -eq $dpcTime) { $dpcTime = 0 }
    if ($null -eq $isrTime) { $isrTime = 0 }

    $dpcSamples += $dpcTime
    $isrSamples += $isrTime

    $dpcBar = [math]::Min([math]::Round($dpcTime * 2), $barWidth)
    $dpcFill = "█" * $dpcBar + "░" * ($barWidth - $dpcBar)
    $dpcColor = if ($dpcTime -lt 2) { "Green" } elseif ($dpcTime -lt 5) { "Yellow" } else { "Red" }
    $timeLeft = $duration - $elapsed

    Write-Host "`r    DPC [$dpcFill] $([math]::Round($dpcTime,1))%  ISR: $([math]::Round($isrTime,1))%  [${timeLeft}s] " -NoNewline -ForegroundColor $dpcColor

    Start-Sleep -Seconds 1
    $elapsed++
}

Write-Host ""

# Results
$dpcAvg = [math]::Round(($dpcSamples | Measure-Object -Average).Average, 2)
$dpcMax = [math]::Round(($dpcSamples | Measure-Object -Maximum).Maximum, 2)
$isrAvg = [math]::Round(($isrSamples | Measure-Object -Average).Average, 2)
$isrMax = [math]::Round(($isrSamples | Measure-Object -Maximum).Maximum, 2)

Write-Host ""
Write-Host "  ► Results" -ForegroundColor Cyan
Write-Host "    DPC  — avg: ${dpcAvg}%  peak: ${dpcMax}%" -ForegroundColor $(if ($dpcAvg -lt 2) { "Green" } elseif ($dpcAvg -lt 5) { "Yellow" } else { "Red" })
Write-Host "    ISR  — avg: ${isrAvg}%  peak: ${isrMax}%" -ForegroundColor $(if ($isrAvg -lt 1) { "Green" } elseif ($isrAvg -lt 3) { "Yellow" } else { "Red" })

if ($dpcAvg -lt 2 -and $isrAvg -lt 1) {
    Write-Host "    ✓ EXCELLENT — Low latency system!" -ForegroundColor Green
}
elseif ($dpcAvg -lt 5) {
    Write-Host "    ⚠ FAIR — Some latency. Check drivers below." -ForegroundColor Yellow
}
else {
    Write-Host "    ✕ HIGH — Driver issues detected!" -ForegroundColor Red
}

# ── Driver Scan ──────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ► Scanning for known problem drivers..." -ForegroundColor Cyan

$loadedDrivers = Get-CimInstance Win32_SystemDriver | Where-Object { $_.State -eq "Running" }
$found = 0

foreach ($driver in $loadedDrivers) {
    if ($driver.PathName) {
        $fileName = Split-Path $driver.PathName -Leaf
        if ($driverFixes.ContainsKey($fileName)) {
            Write-Host "    ⚠ $fileName" -ForegroundColor Yellow -NoNewline
            Write-Host " — $($driverFixes[$fileName])" -ForegroundColor DarkCyan
            $found++
        }
    }
}

if ($found -eq 0) {
    Write-Host "    ✓ No known problem drivers found" -ForegroundColor Green
}
else {
    Write-Host ""
    Write-Host "    Found $found potential latency sources" -ForegroundColor Yellow
}

# ══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Cyan
Write-Host "  ║   ⏱  QUICK LATENCY CHECK COMPLETE                           ║" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Cyan
Write-Host "  ║   DPC: ${dpcAvg}% avg  $(if ($dpcAvg -lt 2) { '✓' } elseif ($dpcAvg -lt 5) { '⚠' } else { '✕' })    ISR: ${isrAvg}% avg  $(if ($isrAvg -lt 1) { '✓' } elseif ($isrAvg -lt 3) { '⚠' } else { '✕' })" -ForegroundColor Cyan
Write-Host "  ║   Problem drivers: $found" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Cyan
Write-Host "  ║   💡 For full analysis: LatencyMonitor.ps1                  ║" -ForegroundColor Yellow
Write-Host "  ║                                                              ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Log "Latency Monitor Lite Done — DPC avg: ${dpcAvg}%, ISR avg: ${isrAvg}%, Drivers: $found"

Write-Host "  Press Enter to exit..." -ForegroundColor DarkGray
Read-Host
