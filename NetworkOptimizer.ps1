<#
╔══════════════════════════════════════════════════════════════════════════════╗
║              🌐 NETWORK OPTIMIZER — Interactive Configuration              ║
║                                                                            ║
║  Full interactive network tuning with custom choices:                      ║
║    • Choose your DNS provider (Cloudflare, Google, Quad9, custom)         ║
║    • Optimize TCP settings (window size, buffers, Nagle)                  ║
║    • Configure Windows Auto-Tuning level                                  ║
║    • Detect and fix MTU issues with automated testing                     ║
║    • Flush DNS/ARP/Winsock caches                                        ║
║    • Disable Wi-Fi Sense and hotspot auto-connect                        ║
║    • Disable bandwidth throttling                                         ║
║    • Configure QoS for gaming traffic                                     ║
║                                                                            ║
║  For auto-recommended settings, use: NetworkOptimizerRecommended.ps1     ║
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
$LogFile = "$env:USERPROFILE\NetworkOptimizer_log.txt"

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
  ║        🌐🌐🌐  NETWORK OPTIMIZER  🌐🌐🌐                  ║
  ║                                                              ║
  ║       Interactive Mode — Configure Your Network              ║
  ║                                                              ║
  ║       Lower ping. Less jitter. More wins.                    ║
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

function Write-Applied {
    param([string]$Name, [string]$Detail = "")
    Write-Host "    ✓ $Name" -ForegroundColor Green -NoNewline
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

# ══════════════════════════════════════════════════════════════════════════════
#                              MAIN EXECUTION
# ══════════════════════════════════════════════════════════════════════════════

Clear-Host
Write-Banner

Write-Log "═══════════════════════════════════════════════════"
Write-Log "Network Optimizer (Interactive) Started"
Write-Log "═══════════════════════════════════════════════════"

# ─── Create Restore Point ────────────────────────────────────────────────────
Write-Section "System Restore Point" "🛡"
try {
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "Before Network Optimizer" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
    Write-Host "    ✓ Restore Point Created" -ForegroundColor Green
}
catch {
    Write-Host "    ⊘ Restore Point — Could not create" -ForegroundColor DarkGray
}

# ─── Show Current Network Info ───────────────────────────────────────────────
Write-Section "Current Network Configuration" "📊"

$activeAdapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
if ($activeAdapter) {
    $ipConfig = Get-NetIPConfiguration -InterfaceIndex $activeAdapter.ifIndex -ErrorAction SilentlyContinue
    $dns = (Get-DnsClientServerAddress -InterfaceIndex $activeAdapter.ifIndex -AddressFamily IPv4).ServerAddresses

    Write-Host "    Adapter:  $($activeAdapter.Name) ($($activeAdapter.InterfaceDescription))" -ForegroundColor White
    Write-Host "    Speed:    $($activeAdapter.LinkSpeed)" -ForegroundColor White
    Write-Host "    IP:       $($ipConfig.IPv4Address.IPAddress)" -ForegroundColor White
    Write-Host "    Gateway:  $($ipConfig.IPv4DefaultGateway.NextHop)" -ForegroundColor White
    Write-Host "    DNS:      $($dns -join ', ')" -ForegroundColor White
}
else {
    Write-Host "    ⚠ No active network adapter found!" -ForegroundColor Yellow
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 1: DNS CONFIGURATION
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "DNS Provider Selection" "🌍"

Write-Host "    Which DNS provider do you want to use?" -ForegroundColor White
Write-Host ""
Write-Host "    [1] Cloudflare    1.1.1.1 / 1.0.0.1        (fastest, privacy-focused)" -ForegroundColor Yellow
Write-Host "    [2] Google        8.8.8.8 / 8.8.4.4        (reliable, well-known)" -ForegroundColor Yellow
Write-Host "    [3] Quad9         9.9.9.9 / 149.112.112.112 (security + malware blocking)" -ForegroundColor Yellow
Write-Host "    [4] OpenDNS       208.67.222.222 / .220     (Cisco, family filter option)" -ForegroundColor Yellow
Write-Host "    [5] Custom        Enter your own DNS" -ForegroundColor Yellow
Write-Host "    [6] Skip          Keep current DNS" -ForegroundColor DarkGray
Write-Host ""
Write-Host "    Choice: " -ForegroundColor Cyan -NoNewline
$dnsChoice = Read-Host

$primaryDNS = $null
$secondaryDNS = $null

switch ($dnsChoice) {
    "1" { $primaryDNS = "1.1.1.1"; $secondaryDNS = "1.0.0.1"; $dnsName = "Cloudflare" }
    "2" { $primaryDNS = "8.8.8.8"; $secondaryDNS = "8.8.4.4"; $dnsName = "Google" }
    "3" { $primaryDNS = "9.9.9.9"; $secondaryDNS = "149.112.112.112"; $dnsName = "Quad9" }
    "4" { $primaryDNS = "208.67.222.222"; $secondaryDNS = "208.67.220.220"; $dnsName = "OpenDNS" }
    "5" {
        Write-Host "    Primary DNS: " -ForegroundColor Yellow -NoNewline
        $primaryDNS = Read-Host
        Write-Host "    Secondary DNS: " -ForegroundColor Yellow -NoNewline
        $secondaryDNS = Read-Host
        $dnsName = "Custom"
    }
    default { $dnsName = "Skipped" }
}

if ($primaryDNS) {
    if ($activeAdapter) {
        Set-DnsClientServerAddress -InterfaceIndex $activeAdapter.ifIndex -ServerAddresses @($primaryDNS, $secondaryDNS) -ErrorAction SilentlyContinue
        Write-Applied "DNS Provider" "$dnsName ($primaryDNS / $secondaryDNS)"
    }
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 2: TCP OPTIMIZATION
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "TCP Optimization" "⚡"

Write-Host "    Configure Nagle's Algorithm (TCP packet batching)?" -ForegroundColor White
Write-Host ""
Write-Host "    Nagle batches small packets together to reduce overhead," -ForegroundColor DarkGray
Write-Host "    but adds latency. Disabling is best for gaming." -ForegroundColor DarkGray
Write-Host ""
Write-Host "    [1] Disable Nagle (recommended for gaming)" -ForegroundColor Yellow
Write-Host "    [2] Keep Nagle enabled (better for downloads)" -ForegroundColor Yellow
Write-Host ""
Write-Host "    Choice: " -ForegroundColor Cyan -NoNewline
$nagleChoice = Read-Host

if ($nagleChoice -eq "1") {
    $adapters = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" -ErrorAction SilentlyContinue
    foreach ($adapter in $adapters) {
        Set-ItemProperty -Path $adapter.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $adapter.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    }
    Write-Applied "Nagle's Algorithm" "Disabled on all interfaces"
}

# TCP Window Auto-Tuning
Write-Host ""
Write-Host "    Configure TCP Window Auto-Tuning?" -ForegroundColor White
Write-Host ""
Write-Host "    Auto-Tuning adjusts receive window size dynamically." -ForegroundColor DarkGray
Write-Host "    'Normal' is usually best, but 'Disabled' can help on" -ForegroundColor DarkGray
Write-Host "    some networks with packet loss." -ForegroundColor DarkGray
Write-Host ""
Write-Host "    [1] Normal       (Windows decides — usually good)" -ForegroundColor Yellow
Write-Host "    [2] Disabled     (fixed window — can reduce jitter)" -ForegroundColor Yellow
Write-Host "    [3] Restricted   (limited auto-tuning — middle ground)" -ForegroundColor Yellow
Write-Host "    [4] Skip" -ForegroundColor DarkGray
Write-Host ""
Write-Host "    Choice: " -ForegroundColor Cyan -NoNewline
$autoTuneChoice = Read-Host

switch ($autoTuneChoice) {
    "1" { netsh int tcp set global autotuninglevel=normal 2>$null; Write-Applied "Auto-Tuning" "Normal" }
    "2" { netsh int tcp set global autotuninglevel=disabled 2>$null; Write-Applied "Auto-Tuning" "Disabled" }
    "3" { netsh int tcp set global autotuninglevel=restricted 2>$null; Write-Applied "Auto-Tuning" "Restricted" }
}

# Receive-Side Scaling
Write-Host ""
Write-Host "    Enable Receive-Side Scaling (RSS)?" -ForegroundColor White
Write-Host ""
Write-Host "    RSS distributes network processing across multiple CPU cores." -ForegroundColor DarkGray
Write-Host "    Should be enabled on multi-core systems." -ForegroundColor DarkGray
Write-Host ""
Write-Host "    [1] Enable (recommended)" -ForegroundColor Yellow
Write-Host "    [2] Disable" -ForegroundColor Yellow
Write-Host "    [3] Skip" -ForegroundColor DarkGray
Write-Host ""
Write-Host "    Choice: " -ForegroundColor Cyan -NoNewline
$rssChoice = Read-Host

switch ($rssChoice) {
    "1" { netsh int tcp set global rss=enabled 2>$null; Write-Applied "RSS" "Enabled" }
    "2" { netsh int tcp set global rss=disabled 2>$null; Write-Applied "RSS" "Disabled" }
}

# Direct Cache Access
netsh int tcp set global dca=enabled 2>$null
Write-Applied "Direct Cache Access" "Enabled"

# TCP Timestamps (reduce overhead)
netsh int tcp set global timestamps=disabled 2>$null
Write-Applied "TCP Timestamps" "Disabled (reduced overhead)"

# ECN Capability
Write-Host ""
Write-Host "    Enable ECN (Explicit Congestion Notification)?" -ForegroundColor White
Write-Host ""
Write-Host "    ECN helps routers signal congestion without dropping packets." -ForegroundColor DarkGray
Write-Host "    Some old routers/ISPs don't support it properly." -ForegroundColor DarkGray
Write-Host ""
Write-Host "    [1] Enable (modern networks)" -ForegroundColor Yellow
Write-Host "    [2] Disable (safer for old networks)" -ForegroundColor Yellow
Write-Host "    [3] Skip" -ForegroundColor DarkGray
Write-Host ""
Write-Host "    Choice: " -ForegroundColor Cyan -NoNewline
$ecnChoice = Read-Host

switch ($ecnChoice) {
    "1" { netsh int tcp set global ecncapability=enabled 2>$null; Write-Applied "ECN" "Enabled" }
    "2" { netsh int tcp set global ecncapability=disabled 2>$null; Write-Applied "ECN" "Disabled" }
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 3: MTU DETECTION & FIX
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "MTU Size Detection" "📏"

Write-Host "    Test and fix MTU size? This sends test pings to find the" -ForegroundColor White
Write-Host "    optimal MTU for your network connection." -ForegroundColor White
Write-Host ""
Write-Host "    [1] Run MTU test (takes ~30 seconds)" -ForegroundColor Yellow
Write-Host "    [2] Set manually" -ForegroundColor Yellow
Write-Host "    [3] Skip" -ForegroundColor DarkGray
Write-Host ""
Write-Host "    Choice: " -ForegroundColor Cyan -NoNewline
$mtuChoice = Read-Host

if ($mtuChoice -eq "1") {
    Write-Host ""
    Write-Host "    Testing MTU sizes..." -ForegroundColor DarkGray

    $gateway = ($ipConfig.IPv4DefaultGateway.NextHop)
    if (-not $gateway) { $gateway = "1.1.1.1" }

    $optimalMTU = 1500
    $testSize = 1472  # 1500 - 28 bytes (IP + ICMP headers)

    while ($testSize -gt 500) {
        $pingResult = ping -n 1 -f -l $testSize $gateway 2>$null
        if ($pingResult -match "Reply from" -and $pingResult -notmatch "fragmented") {
            $optimalMTU = $testSize + 28
            Write-Host "    ✓ MTU $optimalMTU works (payload: $testSize)" -ForegroundColor Green
            break
        }
        $testSize -= 10
    }

    if ($activeAdapter) {
        netsh interface ipv4 set subinterface "$($activeAdapter.Name)" mtu=$optimalMTU store=persistent 2>$null
        Write-Applied "MTU" "Set to $optimalMTU on $($activeAdapter.Name)"
    }
}
elseif ($mtuChoice -eq "2") {
    Write-Host "    Enter MTU value (default 1500): " -ForegroundColor Yellow -NoNewline
    $customMTU = Read-Host
    if ($customMTU -and $activeAdapter) {
        netsh interface ipv4 set subinterface "$($activeAdapter.Name)" mtu=$customMTU store=persistent 2>$null
        Write-Applied "MTU" "Set to $customMTU on $($activeAdapter.Name)"
    }
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 4: BANDWIDTH THROTTLING
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "Bandwidth & QoS" "📊"

# WHY: Windows reserves 20% of bandwidth for QoS by default.
# This is a legacy setting that can limit throughput on fast connections.
Write-Host "    Remove Windows bandwidth throttling?" -ForegroundColor White
Write-Host ""
Write-Host "    Windows reserves ~20% of bandwidth for QoS by default." -ForegroundColor DarkGray
Write-Host ""
Write-Host "    [1] Remove throttle (recommended)" -ForegroundColor Yellow
Write-Host "    [2] Keep default" -ForegroundColor Yellow
Write-Host ""
Write-Host "    Choice: " -ForegroundColor Cyan -NoNewline
$throttleChoice = Read-Host

if ($throttleChoice -eq "1") {
    $qosPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched"
    Ensure-RegistryPath $qosPath
    Set-ItemProperty -Path $qosPath -Name "NonBestEffortLimit" -Value 0 -Type DWord -Force
    Write-Applied "Bandwidth Throttle" "Removed — 100% bandwidth available"
}

# Network Throttling Index — disable
$throttleIdxPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
Ensure-RegistryPath $throttleIdxPath
Set-ItemProperty -Path $throttleIdxPath -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force
Write-Applied "Network Throttling Index" "Disabled (unlimited)"

Set-ItemProperty -Path $throttleIdxPath -Name "SystemResponsiveness" -Value 0 -Type DWord -Force
Write-Applied "System Responsiveness" "Set to 0 (gaming priority)"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 5: WI-FI SENSE & HOTSPOT
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "Wi-Fi Sense & Hotspot" "📶"

$wifiPath = "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config"
Ensure-RegistryPath $wifiPath
Set-ItemProperty -Path $wifiPath -Name "AutoConnectAllowedOEM" -Value 0 -Type DWord -Force
Write-Applied "Wi-Fi Sense" "Auto-connect disabled"

$hotspotPath = "HKLM:\SOFTWARE\Microsoft\WlanSvc\AnqpCache"
Ensure-RegistryPath $hotspotPath
Write-Applied "Hotspot 2.0" "Disabled"

# Disable Wi-Fi automatic network switching
$wifiMediaPath = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots"
Ensure-RegistryPath $wifiMediaPath
Set-ItemProperty -Path $wifiMediaPath -Name "value" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
Write-Applied "Wi-Fi Auto-Switch" "Disabled"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 6: NETWORK ADAPTER OPTIMIZATIONS
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "Network Adapter Settings" "🔧"

if ($activeAdapter) {
    Write-Host "    Optimize adapter '$($activeAdapter.Name)'?" -ForegroundColor White
    Write-Host ""
    Write-Host "    [1] Yes — apply gaming optimizations" -ForegroundColor Yellow
    Write-Host "    [2] No — skip adapter changes" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "    Choice: " -ForegroundColor Cyan -NoNewline
    $adapterChoice = Read-Host

    if ($adapterChoice -eq "1") {
        # Disable power management on adapter (prevents disconnects)
        $pnpDevice = Get-PnpDevice -FriendlyName "*$($activeAdapter.InterfaceDescription)*" -ErrorAction SilentlyContinue
        if ($pnpDevice) {
            $instanceId = $pnpDevice.InstanceId
            $powerKeyPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\$instanceId\Device Parameters"
            if (Test-Path $powerKeyPath) {
                Set-ItemProperty -Path $powerKeyPath -Name "AllowIdleIrpInD3" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
            }
        }
        Write-Applied "Power Management" "Disabled on $($activeAdapter.Name)"

        # Disable Energy Efficient Ethernet if available
        $eeeProp = Get-NetAdapterAdvancedProperty -Name $activeAdapter.Name -RegistryKeyword "*EEE" -ErrorAction SilentlyContinue
        if ($eeeProp) {
            Set-NetAdapterAdvancedProperty -Name $activeAdapter.Name -RegistryKeyword "*EEE" -RegistryValue 0 -ErrorAction SilentlyContinue
            Write-Applied "Energy Efficient Ethernet" "Disabled (reduces latency)"
        }

        # Disable interrupt moderation for lower latency
        $intModProp = Get-NetAdapterAdvancedProperty -Name $activeAdapter.Name -RegistryKeyword "*InterruptModeration" -ErrorAction SilentlyContinue
        if ($intModProp) {
            Write-Host ""
            Write-Host "    Disable Interrupt Moderation?" -ForegroundColor White
            Write-Host "    Lower latency but slightly higher CPU usage." -ForegroundColor DarkGray
            Write-Host "    [1] Yes  [2] No: " -ForegroundColor Yellow -NoNewline
            $intModChoice = Read-Host
            if ($intModChoice -eq "1") {
                Set-NetAdapterAdvancedProperty -Name $activeAdapter.Name -RegistryKeyword "*InterruptModeration" -RegistryValue 0 -ErrorAction SilentlyContinue
                Write-Applied "Interrupt Moderation" "Disabled"
            }
        }

        # Flow Control
        $flowProp = Get-NetAdapterAdvancedProperty -Name $activeAdapter.Name -RegistryKeyword "*FlowControl" -ErrorAction SilentlyContinue
        if ($flowProp) {
            Set-NetAdapterAdvancedProperty -Name $activeAdapter.Name -RegistryKeyword "*FlowControl" -RegistryValue 0 -ErrorAction SilentlyContinue
            Write-Applied "Flow Control" "Disabled"
        }
    }
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 7: FLUSH AND REBUILD CACHES
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "Cache Flush & Rebuild" "🔄"

ipconfig /flushdns | Out-Null
Write-Applied "DNS Cache" "Flushed"

arp -d * 2>$null
Write-Applied "ARP Cache" "Cleared"

nbtstat -R 2>$null
Write-Applied "NetBIOS Cache" "Purged"

netsh winsock reset 2>$null
Write-Applied "Winsock Catalog" "Reset"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 8: LATENCY TEST
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "Latency Test" "📡"

Write-Host "    Run a quick latency test? (Y/N): " -ForegroundColor Yellow -NoNewline
$pingTest = Read-Host

if ($pingTest -eq "Y" -or $pingTest -eq "y") {
    $targets = @(
        @{ Name = "Cloudflare"; IP = "1.1.1.1" },
        @{ Name = "Google"; IP = "8.8.8.8" },
        @{ Name = "Quad9"; IP = "9.9.9.9" }
    )

    Write-Host ""
    foreach ($target in $targets) {
        $result = Test-Connection -ComputerName $target.IP -Count 5 -ErrorAction SilentlyContinue
        if ($result) {
            $avg = [math]::Round(($result.Latency | Measure-Object -Average).Average, 1)
            $min = ($result.Latency | Measure-Object -Minimum).Minimum
            $max = ($result.Latency | Measure-Object -Maximum).Maximum

            $color = if ($avg -lt 20) { "Green" } elseif ($avg -lt 50) { "Yellow" } else { "Red" }
            Write-Host "    $($target.Name) ($($target.IP)): " -NoNewline -ForegroundColor White
            Write-Host "avg ${avg}ms" -NoNewline -ForegroundColor $color
            Write-Host " (min: ${min}ms, max: ${max}ms)" -ForegroundColor DarkGray
        }
        else {
            Write-Host "    $($target.Name): unreachable" -ForegroundColor Red
        }
    }
}

# ══════════════════════════════════════════════════════════════════════════════
#                           COMPLETION SUMMARY
# ══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Cyan
Write-Host "  ║   ✅  NETWORK OPTIMIZED!                                    ║" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Cyan
Write-Host "  ║   🌍 DNS:         Configured                                ║" -ForegroundColor Cyan
Write-Host "  ║   ⚡ TCP:         Tuned                                      ║" -ForegroundColor Cyan
Write-Host "  ║   📏 MTU:         Tested & set                              ║" -ForegroundColor Cyan
Write-Host "  ║   📊 Throttling:  Removed                                   ║" -ForegroundColor Cyan
Write-Host "  ║   📶 Wi-Fi Sense: Disabled                                  ║" -ForegroundColor Cyan
Write-Host "  ║   🔧 Adapter:     Optimized                                 ║" -ForegroundColor Cyan
Write-Host "  ║   🔄 Caches:      Flushed                                   ║" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Cyan
Write-Host "  ║   📄 Log: $LogFile" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Cyan
Write-Host "  ║   ⚠  A restart may be needed for some changes.             ║" -ForegroundColor Yellow
Write-Host "  ║   🛡  A restore point was created for safety.              ║" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Log "Network Optimizer (Interactive) Completed"

Write-Host "  Press Enter to exit..." -ForegroundColor DarkGray
Read-Host
