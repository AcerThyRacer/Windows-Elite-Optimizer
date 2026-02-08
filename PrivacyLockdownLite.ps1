<#
╔══════════════════════════════════════════════════════════════════════════════╗
║              🛡 PRIVACY LOCKDOWN LITE — Quick Privacy Hardening            ║
║                                                                            ║
║  Fast, no-menu privacy hardening. Applies the most impactful              ║
║  privacy tweaks without touching the hosts file or blocking               ║
║  app-level permissions. Safe for daily drivers.                            ║
║                                                                            ║
║  What this does (vs. Full version):                                        ║
║    ✓ Disable telemetry & diagnostic data                                  ║
║    ✓ Disable Activity History & Timeline                                  ║
║    ✓ Disable Advertising ID & app suggestions                             ║
║    ✓ Disable Cortana & web search                                         ║
║    ✓ Disable feedback notifications                                       ║
║    ✗ Does NOT modify hosts file (no domain blocking)                      ║
║    ✗ Does NOT block camera/mic (keeps full app access)                    ║
║    ✗ Does NOT disable location (keeps weather/maps working)               ║
║    ✗ Does NOT disable clipboard history                                   ║
║                                                                            ║
║  For the full lockdown, use: PrivacyLockdown.ps1                          ║
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
$LogFile = "$env:USERPROFILE\PrivacyLockdownLite_log.txt"

# ─── Helpers ─────────────────────────────────────────────────────────────────
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp | $Message" | Out-File -FilePath $LogFile -Append -Encoding UTF8
}

function Write-Applied {
    param([string]$Name, [string]$Detail = "")
    Write-Host "    🔒 $Name" -ForegroundColor Green -NoNewline
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
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║        🛡  PRIVACY LOCKDOWN LITE  🛡                        ║" -ForegroundColor Green
Write-Host "  ║       Quick Privacy Hardening — No Hassle                   ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Log "═══════════════════════════════════════ "
Write-Log "Privacy Lockdown Lite Started"
Write-Log "═══════════════════════════════════════"

$changeCount = 0

# ── 1. Telemetry ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ► Telemetry & Diagnostics" -ForegroundColor Green

$telemetryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
Ensure-RegistryPath $telemetryPath
Set-ItemProperty -Path $telemetryPath -Name "AllowTelemetry" -Value 0 -Type DWord -Force
Write-Applied "Telemetry" "Set to Security/Off"
$changeCount++

# Disable telemetry services
foreach ($svc in @("DiagTrack", "dmwappushservice")) {
    $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($service) {
        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Applied "Service: $svc" "Stopped and disabled"
        $changeCount++
    }
}

# CEIP
$ceipPath = "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows"
Ensure-RegistryPath $ceipPath
Set-ItemProperty -Path $ceipPath -Name "CEIPEnable" -Value 0 -Type DWord -Force
Write-Applied "CEIP" "Opted out"
$changeCount++

# Feedback
$siufPath = "HKCU:\Software\Microsoft\Siuf\Rules"
Ensure-RegistryPath $siufPath
Set-ItemProperty -Path $siufPath -Name "NumberOfSIUFInPeriod" -Value 0 -Type DWord -Force
Write-Applied "Feedback Popups" "Disabled"
$changeCount++

# ── 2. Activity History ─────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ► Activity History & Timeline" -ForegroundColor Green

$activityPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
Ensure-RegistryPath $activityPath
Set-ItemProperty -Path $activityPath -Name "EnableActivityFeed" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $activityPath -Name "PublishUserActivities" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $activityPath -Name "UploadUserActivities" -Value 0 -Type DWord -Force
Write-Applied "Activity History" "Feed, publish, and upload all disabled"
$changeCount++

# ── 3. Advertising ID ───────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ► Advertising & Suggestions" -ForegroundColor Green

$adIdPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
Ensure-RegistryPath $adIdPath
Set-ItemProperty -Path $adIdPath -Name "Enabled" -Value 0 -Type DWord -Force
Write-Applied "Advertising ID" "Disabled"
$changeCount++

$cdPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
Ensure-RegistryPath $cdPath
Set-ItemProperty -Path $cdPath -Name "SystemPaneSuggestionsEnabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $cdPath -Name "SubscribedContent-338388Enabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $cdPath -Name "SubscribedContent-338389Enabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $cdPath -Name "SubscribedContent-310093Enabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $cdPath -Name "SilentInstalledAppsEnabled" -Value 0 -Type DWord -Force
Write-Applied "Start Menu Ads" "All suggestions disabled"
$changeCount++

# ── 4. Cortana ───────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ► Cortana & Web Search" -ForegroundColor Green

$cortanaPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
Ensure-RegistryPath $cortanaPath
Set-ItemProperty -Path $cortanaPath -Name "AllowCortana" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $cortanaPath -Name "DisableWebSearch" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $cortanaPath -Name "ConnectedSearchUseWeb" -Value 0 -Type DWord -Force
Write-Applied "Cortana" "Disabled"
Write-Applied "Web Search" "Disabled — searches stay local"
$changeCount += 2

# ── 5. Copilot ───────────────────────────────────────────────────────────────
$copilotPath = "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot"
Ensure-RegistryPath $copilotPath
Set-ItemProperty -Path $copilotPath -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord -Force
Write-Applied "Copilot" "Disabled"
$changeCount++

# ══════════════════════════════════════════════════════════════════════════════
#                           COMPLETION SUMMARY
# ══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   ✅  PRIVACY LITE — $changeCount changes applied!" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   📡 Telemetry off     🤖 Cortana off                      ║" -ForegroundColor Green
Write-Host "  ║   📋 Timeline off      🎯 Ad ID off                        ║" -ForegroundColor Green
Write-Host "  ║   💬 Feedback off      🌐 Web search off                   ║" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   💡 For full lockdown: PrivacyLockdown.ps1                 ║" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Log "Privacy Lockdown Lite Completed — $changeCount changes applied"

Write-Host "  Press Enter to exit..." -ForegroundColor DarkGray
Read-Host
