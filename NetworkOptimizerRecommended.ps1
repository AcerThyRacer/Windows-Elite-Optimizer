<#
╔══════════════════════════════════════════════════════════════════════════════╗
║          🌐 NETWORK OPTIMIZER RECOMMENDED — Auto-Apply Best Settings       ║
║                                                                            ║
║  Applies our recommended network optimizations instantly:                   ║
║    ✓ DNS set to Cloudflare (1.1.1.1 / 1.0.0.1)                           ║
║    ✓ Nagle's algorithm disabled on all adapters                           ║
║    ✓ TCP auto-tuning set to Normal                                        ║
║    ✓ RSS enabled, timestamps disabled                                     ║
║    ✓ Bandwidth throttling removed                                         ║
║    ✓ Wi-Fi Sense disabled                                                 ║
║    ✓ DNS/ARP/Winsock caches flushed                                      ║
║                                                                            ║
║  For interactive configuration, use: NetworkOptimizer.ps1                 ║
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

$ErrorActionPreference = "SilentlyContinue"
$LogFile = "$env:USERPROFILE\NetworkOptimizerRecommended_log.txt"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp | $Message" | Out-File -FilePath $LogFile -Append -Encoding UTF8
}

function Write-Applied {
    param([string]$Name, [string]$Detail = "")
    Write-Host "    ✓ $Name" -ForegroundColor Green -NoNewline
    if ($Detail) { Write-Host " — $Detail" -ForegroundColor DarkGray } else { Write-Host "" }
    Write-Log "  [APPLIED] $Name $Detail"
}

function Ensure-RegistryPath {
    param([string]$Path)
    if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
}

# ══════════════════════════════════════════════════════════════════════════════
#                              MAIN EXECUTION
# ══════════════════════════════════════════════════════════════════════════════

Clear-Host
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║        🌐  NETWORK OPTIMIZER — RECOMMENDED  🌐              ║" -ForegroundColor Cyan
Write-Host "  ║       Auto-Apply Best Network Settings for Gaming           ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Log "Network Optimizer (Recommended) Started"
$changeCount = 0

# ── 1. DNS — Cloudflare ─────────────────────────────────────────────────────
Write-Host "  ► DNS Configuration" -ForegroundColor Cyan

$activeAdapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
if ($activeAdapter) {
    Set-DnsClientServerAddress -InterfaceIndex $activeAdapter.ifIndex -ServerAddresses @("1.1.1.1", "1.0.0.1") -ErrorAction SilentlyContinue
    Write-Applied "DNS" "Cloudflare (1.1.1.1 / 1.0.0.1)"
    $changeCount++
}
else {
    Write-Host "    ⚠ No active adapter found" -ForegroundColor Yellow
}

# ── 2. Disable Nagle's Algorithm ────────────────────────────────────────────
Write-Host ""
Write-Host "  ► TCP Optimization" -ForegroundColor Cyan

$adapters = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" -ErrorAction SilentlyContinue
foreach ($adapter in $adapters) {
    Set-ItemProperty -Path $adapter.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $adapter.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
}
Write-Applied "Nagle's Algorithm" "Disabled on all interfaces"
$changeCount++

# TCP settings
netsh int tcp set global autotuninglevel=normal 2>$null
Write-Applied "Auto-Tuning" "Normal"
$changeCount++

netsh int tcp set global rss=enabled 2>$null
Write-Applied "Receive-Side Scaling" "Enabled"
$changeCount++

netsh int tcp set global timestamps=disabled 2>$null
Write-Applied "TCP Timestamps" "Disabled"
$changeCount++

netsh int tcp set global dca=enabled 2>$null
Write-Applied "Direct Cache Access" "Enabled"
$changeCount++

# ── 3. Bandwidth Throttling ─────────────────────────────────────────────────
Write-Host ""
Write-Host "  ► Bandwidth & Throttling" -ForegroundColor Cyan

$qosPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched"
Ensure-RegistryPath $qosPath
Set-ItemProperty -Path $qosPath -Name "NonBestEffortLimit" -Value 0 -Type DWord -Force
Write-Applied "QoS Bandwidth Reserve" "Removed (100% available)"
$changeCount++

$throttlePath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
Ensure-RegistryPath $throttlePath
Set-ItemProperty -Path $throttlePath -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force
Set-ItemProperty -Path $throttlePath -Name "SystemResponsiveness" -Value 0 -Type DWord -Force
Write-Applied "Network Throttling" "Disabled (unlimited)"
Write-Applied "System Responsiveness" "Gaming priority (0)"
$changeCount += 2

# ── 4. Wi-Fi Sense ──────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ► Wi-Fi Sense" -ForegroundColor Cyan

$wifiPath = "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config"
Ensure-RegistryPath $wifiPath
Set-ItemProperty -Path $wifiPath -Name "AutoConnectAllowedOEM" -Value 0 -Type DWord -Force
Write-Applied "Wi-Fi Sense" "Disabled"
$changeCount++

# ── 5. Flush Caches ─────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ► Flushing Caches" -ForegroundColor Cyan

ipconfig /flushdns | Out-Null
Write-Applied "DNS Cache" "Flushed"

arp -d * 2>$null
Write-Applied "ARP Cache" "Cleared"

nbtstat -R 2>$null
Write-Applied "NetBIOS Cache" "Purged"

netsh winsock reset 2>$null
Write-Applied "Winsock" "Reset"

$changeCount += 4

# ══════════════════════════════════════════════════════════════════════════════
#                           COMPLETION SUMMARY
# ══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Cyan
Write-Host "  ║   ✅  NETWORK OPTIMIZED — $changeCount settings applied!" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Cyan
Write-Host "  ║   🌍 DNS: Cloudflare     ⚡ Nagle: Off                      ║" -ForegroundColor Cyan
Write-Host "  ║   📊 Throttle: Removed   📶 Wi-Fi Sense: Off               ║" -ForegroundColor Cyan
Write-Host "  ║   🔄 Caches: Flushed     🔧 TCP: Tuned                     ║" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Cyan
Write-Host "  ║   💡 For full control: NetworkOptimizer.ps1                 ║" -ForegroundColor Yellow
Write-Host "  ║   ⚠  Restart may be needed for some changes.               ║" -ForegroundColor Yellow
Write-Host "  ║                                                              ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Log "Network Optimizer (Recommended) Done — $changeCount changes"

Write-Host "  Press Enter to exit..." -ForegroundColor DarkGray
Read-Host
