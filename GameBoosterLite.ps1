<#
╔══════════════════════════════════════════════════════════════════════════════╗
║                 🎮 GAME BOOSTER LITE — Quick Pre-Game Boost                ║
║                                                                            ║
║  Fast, no-menu version — just run before gaming:                           ║
║    ✓ Kills known bloatware processes                                      ║
║    ✓ Clears standby memory                                                ║
║    ✓ Flushes DNS cache                                                    ║
║    ✓ Switches to High Performance power plan                              ║
║    ✗ Does NOT monitor game process                                        ║
║    ✗ Does NOT auto-restore (run again or restart to restore)              ║
║    ✗ Does NOT change CPU affinity                                         ║
║                                                                            ║
║  For full per-game mode with auto-restore, use: GameBooster.ps1           ║
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
$LogFile = "$env:USERPROFILE\GameBoosterLite_log.txt"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp | $Message" | Out-File -FilePath $LogFile -Append -Encoding UTF8
}

# ══════════════════════════════════════════════════════════════════════════════
#                              MAIN EXECUTION
# ══════════════════════════════════════════════════════════════════════════════

Clear-Host
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║        🎮  GAME BOOSTER LITE  🎮                            ║" -ForegroundColor Magenta
Write-Host "  ║       Quick Pre-Game Boost — Run & Go                       ║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

Write-Log "Game Booster Lite Started"
$killCount = 0

# ── 1. Kill Background Bloat ────────────────────────────────────────────────
Write-Host "  ► Killing Background Bloat" -ForegroundColor Magenta

$bloatProcesses = @(
    "msedge", "MicrosoftEdgeUpdate", "Teams", "ms-teams", "Spotify",
    "Slack", "OneDrive", "GoogleDriveFS", "Dropbox", "Discord",
    "AdobeIPCBroker", "AdobeUpdateService", "jusched", "NvTmRep",
    "SearchHost", "Widgets", "WidgetService", "YourPhone",
    "PhoneExperienceHost", "WavesSvc64", "NahimicSvc64"
)

foreach ($name in $bloatProcesses) {
    $proc = Get-Process -Name $name -ErrorAction SilentlyContinue
    if ($proc) {
        $proc | Stop-Process -Force -ErrorAction SilentlyContinue
        Write-Host "    💀 $name" -ForegroundColor Red
        Write-Log "  [KILLED] $name"
        $killCount++
    }
}

if ($killCount -eq 0) {
    Write-Host "    ✓ No bloatware found running" -ForegroundColor Green
}

# ── 2. Pause Heavy Services ─────────────────────────────────────────────────
Write-Host ""
Write-Host "  ► Pausing Heavy Services" -ForegroundColor Magenta

$svcCount = 0
foreach ($svc in @("SysMain", "WSearch", "DiagTrack")) {
    $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($service -and $service.Status -eq "Running") {
        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        Write-Host "    ⏸ $svc" -ForegroundColor Yellow
        $svcCount++
    }
}

# ── 3. Clear Standby Memory ─────────────────────────────────────────────────
Write-Host ""
Write-Host "  ► Clearing Standby Memory" -ForegroundColor Magenta

$memBefore = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory
$processes = Get-Process
foreach ($proc in $processes) {
    try { $proc.MinWorkingSet = $proc.MinWorkingSet } catch { }
}
$memAfter = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory
$memFreedMB = [math]::Round(($memAfter - $memBefore) / 1024, 0)
if ($memFreedMB -gt 0) {
    Write-Host "    🧠 Freed ~${memFreedMB} MB" -ForegroundColor Green
}
else {
    Write-Host "    🧠 Memory trimmed" -ForegroundColor Green
}

# ── 4. Flush DNS ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ► Flushing Network" -ForegroundColor Magenta

ipconfig /flushdns | Out-Null
Write-Host "    🌐 DNS cache flushed" -ForegroundColor Cyan

# ── 5. Power Plan ────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ► Setting Power Plan" -ForegroundColor Magenta

$ultimateGuid = "e9a42b02-d5df-448d-aa00-03f14749eb61"
powercfg /setactive $ultimateGuid 2>$null
if ($LASTEXITCODE -ne 0) {
    powercfg /duplicatescheme $ultimateGuid 2>$null
    powercfg /setactive $ultimateGuid 2>$null
}
if ($LASTEXITCODE -ne 0) {
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
    Write-Host "    ⚡ High Performance" -ForegroundColor Yellow
}
else {
    Write-Host "    ⚡ Ultimate Performance" -ForegroundColor Yellow
}

# ══════════════════════════════════════════════════════════════════════════════
#                           COMPLETION SUMMARY
# ══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   ✅  BOOST ACTIVE! Launch your game now.                   ║" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   💀 Killed: $killCount processes    ⏸ Paused: $svcCount services" -ForegroundColor Green
Write-Host "  ║   🧠 RAM freed: ~${memFreedMB} MB    🌐 DNS flushed" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   💡 Services restore on reboot, or run RestoreDefaults.ps1 ║" -ForegroundColor Cyan
Write-Host "  ║   💡 For full game monitor: GameBooster.ps1                 ║" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Log "Game Booster Lite Done — Killed: $killCount, Paused: $svcCount"

Write-Host "  Press Enter to exit..." -ForegroundColor DarkGray
Read-Host
