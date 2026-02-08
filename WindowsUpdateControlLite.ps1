<#
╔══════════════════════════════════════════════════════════════════════════════╗
║          🔄 WINDOWS UPDATE CONTROL LITE — Quick Update Taming              ║
║                                                                            ║
║  Fast, no-menu version that applies the most critical update controls      ║
║  instantly. No interactive prompts — just run and go.                      ║
║                                                                            ║
║  What this does (vs. Full version):                                        ║
║    ✓ Defer feature updates by 30 days                                     ║
║    ✓ Defer quality updates by 7 days                                      ║
║    ✓ Disable auto-restart when logged in                                  ║
║    ✓ Disable delivery optimization P2P                                    ║
║    ✗ Does NOT change active hours (keeps your existing settings)           ║
║    ✗ Does NOT block driver updates (keeps WU driver delivery)             ║
║    ✗ Does NOT suppress notifications                                      ║
║                                                                            ║
║  For full control, use: WindowsUpdateControl.ps1                          ║
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
$LogFile = "$env:USERPROFILE\WindowsUpdateControlLite_log.txt"

# ─── Helpers ─────────────────────────────────────────────────────────────────
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp | $Message" | Out-File -FilePath $LogFile -Append -Encoding UTF8
}

function Write-Applied {
    param([string]$Name, [string]$Detail = "")
    Write-Host "    ✓ $Name" -ForegroundColor Cyan -NoNewline
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
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "  ║        🔄  WINDOWS UPDATE CONTROL LITE  🔄                  ║" -ForegroundColor Blue
Write-Host "  ║       Quick Update Taming — Essential Controls Only         ║" -ForegroundColor Blue
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Blue
Write-Host ""

Write-Log "═══════════════════════════════════════"
Write-Log "Windows Update Control Lite Started"
Write-Log "═══════════════════════════════════════"

$changeCount = 0

# ── 1. Defer Feature Updates — 30 Days ───────────────────────────────────────
Write-Host ""
Write-Host "  ► Update Deferral" -ForegroundColor Blue

$wuPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
Ensure-RegistryPath $wuPolicyPath

Set-ItemProperty -Path $wuPolicyPath -Name "DeferFeatureUpdates" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $wuPolicyPath -Name "DeferFeatureUpdatesPeriodInDays" -Value 30 -Type DWord -Force
Write-Applied "Feature Updates" "Deferred 30 days"
$changeCount++

# ── 2. Defer Quality Updates — 7 Days ───────────────────────────────────────
Set-ItemProperty -Path $wuPolicyPath -Name "DeferQualityUpdates" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $wuPolicyPath -Name "DeferQualityUpdatesPeriodInDays" -Value 7 -Type DWord -Force
Write-Applied "Quality Updates" "Deferred 7 days"
$changeCount++

# ── 3. Disable Auto-Restart ─────────────────────────────────────────────────
Write-Host ""
Write-Host "  ► Restart Control" -ForegroundColor Blue

$auPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
Ensure-RegistryPath $auPolicyPath

# Download + notify (don't auto-install)
Set-ItemProperty -Path $auPolicyPath -Name "AUOptions" -Value 3 -Type DWord -Force
Write-Applied "Update Mode" "Download + notify (no auto-install)"
$changeCount++

# Block restart when logged in
Set-ItemProperty -Path $auPolicyPath -Name "NoAutoRebootWithLoggedOnUsers" -Value 1 -Type DWord -Force
Write-Applied "Auto-Restart" "Blocked when logged in"
$changeCount++

# Don't wake from sleep
Set-ItemProperty -Path $auPolicyPath -Name "AUPowerManagement" -Value 0 -Type DWord -Force
Write-Applied "Wake for Updates" "Disabled"
$changeCount++

# ── 4. Disable Delivery Optimization (P2P) ──────────────────────────────────
Write-Host ""
Write-Host "  ► Delivery Optimization" -ForegroundColor Blue

$doPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"
Ensure-RegistryPath $doPath
Set-ItemProperty -Path $doPath -Name "DODownloadMode" -Value 0 -Type DWord -Force
Write-Applied "P2P Delivery" "Disabled — HTTP only, no upload to strangers"
$changeCount++

# ══════════════════════════════════════════════════════════════════════════════
#                           COMPLETION SUMMARY
# ══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "  ║                                                              ║" -ForegroundColor Blue
Write-Host "  ║   ✅  UPDATES TAMED — $changeCount controls applied!" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Blue
Write-Host "  ║   📦 Features deferred 30d    🔧 Quality deferred 7d       ║" -ForegroundColor Blue
Write-Host "  ║   🔁 No auto-restart          📡 No P2P upload             ║" -ForegroundColor Blue
Write-Host "  ║                                                              ║" -ForegroundColor Blue
Write-Host "  ║   💡 For full control: WindowsUpdateControl.ps1             ║" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Blue
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Blue
Write-Host ""

Write-Log "Windows Update Control Lite Completed — $changeCount changes applied"

Write-Host "  Press Enter to exit..." -ForegroundColor DarkGray
Read-Host
