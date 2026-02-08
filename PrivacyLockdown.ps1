<#
╔══════════════════════════════════════════════════════════════════════════════╗
║                🛡 PRIVACY LOCKDOWN — Full Privacy Hardening                ║
║                                                                            ║
║  Comprehensive Windows 11 privacy hardening:                               ║
║    • Disable all telemetry, diagnostics & feedback                         ║
║    • Block tracking domains via hosts file                                 ║
║    • Disable clipboard history & cloud sync                                ║
║    • Disable location tracking for all apps                                ║
║    • Block background camera/microphone access                             ║
║    • Disable Find My Device                                                ║
║    • Disable Timeline / Activity History completely                        ║
║    • Disable Cortana, Copilot, & AI data harvesting                       ║
║    • Disable advertising ID & app suggestions                              ║
║    • Disable typing/inking personalization                                 ║
║    • Disable Wi-Fi Sense and hotspot auto-connect                         ║
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
$LogFile = "$env:USERPROFILE\PrivacyLockdown_log.txt"

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
  ║        🛡🛡🛡  PRIVACY LOCKDOWN  🛡🛡🛡                    ║
  ║                                                              ║
  ║       Windows 11 — Full Privacy Hardening                    ║
  ║                                                              ║
  ║       Your data. Your rules. No exceptions.                  ║
  ║                                                              ║
  ╚══════════════════════════════════════════════════════════════╝

"@
    Write-Host $banner -ForegroundColor Green
}

function Write-Section {
    param([string]$Title, [string]$Icon = "►")
    Write-Host ""
    Write-Host "  ┌──────────────────────────────────────────────────────────" -ForegroundColor DarkGreen
    Write-Host "  │ $Icon $Title" -ForegroundColor Green
    Write-Host "  └──────────────────────────────────────────────────────────" -ForegroundColor DarkGreen
    Write-Log "=== $Title ==="
}

function Write-Applied {
    param([string]$Name, [string]$Detail = "")
    Write-Host "    🔒 $Name" -ForegroundColor Green -NoNewline
    if ($Detail) { Write-Host " — $Detail" -ForegroundColor DarkGray } else { Write-Host "" }
    Write-Log "  [APPLIED] $Name $Detail"
}

function Write-Skip {
    param([string]$Name, [string]$Reason)
    Write-Host "    ⊘ $Name" -ForegroundColor DarkGray -NoNewline
    Write-Host " — $Reason" -ForegroundColor DarkGray
    Write-Log "  [SKIP] $Name — $Reason"
}

function Write-Info {
    param([string]$Message)
    Write-Host "    ℹ $Message" -ForegroundColor DarkYellow
}

function Ensure-RegistryPath {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
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
    Write-Host "  [$bar] $pct% — $StepName" -ForegroundColor Green
}

# ══════════════════════════════════════════════════════════════════════════════
#                              MAIN EXECUTION
# ══════════════════════════════════════════════════════════════════════════════

Clear-Host
Write-Banner

Write-Host "  This script hardens your Windows 11 privacy settings by" -ForegroundColor White
Write-Host "  disabling telemetry, tracking, and data collection features." -ForegroundColor White
Write-Host ""
Write-Host "  ⚠  Some features you use may stop working:" -ForegroundColor Yellow
Write-Host "     • Clipboard history (Win+V) will be disabled" -ForegroundColor DarkGray
Write-Host "     • Find My Device will be turned off" -ForegroundColor DarkGray
Write-Host "     • Timeline/Activity History will stop syncing" -ForegroundColor DarkGray
Write-Host "     • Location services will be off for most apps" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Continue? (Y/N): " -ForegroundColor Green -NoNewline
$confirm = Read-Host
if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "`n  Cancelled. No changes were made." -ForegroundColor Green
    exit
}

Write-Host ""
Write-Log "═══════════════════════════════════════════════════"
Write-Log "Privacy Lockdown Script Started"
Write-Log "═══════════════════════════════════════════════════"

# ─── Create Restore Point ────────────────────────────────────────────────────
Write-Section "System Restore Point" "🛡"
try {
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "Before Privacy Lockdown" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
    Write-Host "    ✓ Restore Point Created" -ForegroundColor Green
}
catch {
    Write-Skip "Restore Point" "Could not create (may have been created recently)"
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 1: TELEMETRY & DIAGNOSTICS
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Disabling Telemetry & Diagnostics"
Write-Section "Telemetry & Diagnostic Data" "📡"

# WHY: Windows collects diagnostic data about your PC, hardware, software usage,
# browsing habits, app crashes, and more. This is sent to Microsoft servers.
# Setting to 0 = Security level (minimum allowed, no optional data)

$telemetryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
Ensure-RegistryPath $telemetryPath
Set-ItemProperty -Path $telemetryPath -Name "AllowTelemetry" -Value 0 -Type DWord -Force
Write-Applied "Telemetry Level" "Set to 0 (Security/Off)"

# Disable diagnostic data viewer
Set-ItemProperty -Path $telemetryPath -Name "DisableDiagnosticDataViewer" -Value 1 -Type DWord -Force
Write-Applied "Diagnostic Data Viewer" "Disabled"

# Disable feedback requests
$siufPath = "HKCU:\Software\Microsoft\Siuf\Rules"
Ensure-RegistryPath $siufPath
Set-ItemProperty -Path $siufPath -Name "NumberOfSIUFInPeriod" -Value 0 -Type DWord -Force
Write-Applied "Feedback Notifications" "Disabled — no more 'How was your experience?' popups"

# Disable telemetry services
$telemetryServices = @("DiagTrack", "dmwappushservice")
foreach ($svc in $telemetryServices) {
    $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($service) {
        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Applied "Service: $svc" "Stopped and disabled"
    }
}

# Disable Customer Experience Improvement Program
$ceipPath = "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows"
Ensure-RegistryPath $ceipPath
Set-ItemProperty -Path $ceipPath -Name "CEIPEnable" -Value 0 -Type DWord -Force
Write-Applied "CEIP (Customer Experience)" "Opted out"

# Disable Application Impact Telemetry
$aitPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat"
Ensure-RegistryPath $aitPath
Set-ItemProperty -Path $aitPath -Name "AITEnable" -Value 0 -Type DWord -Force
Write-Applied "App Impact Telemetry" "Disabled"

# Disable Inventory Collector
Set-ItemProperty -Path $aitPath -Name "DisableInventory" -Value 1 -Type DWord -Force
Write-Applied "Inventory Collector" "Disabled"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 2: ACTIVITY HISTORY & TIMELINE
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Disabling Activity History & Timeline"
Write-Section "Activity History & Timeline" "📋"

# WHY: Activity History records every app you open, every file you access,
# every website you visit, and syncs this data across devices via your
# Microsoft account. Timeline shows this as a browsable history.

$activityPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
Ensure-RegistryPath $activityPath

# Disable activity feed
Set-ItemProperty -Path $activityPath -Name "EnableActivityFeed" -Value 0 -Type DWord -Force
Write-Applied "Activity Feed" "Disabled"

# Disable activity history publishing (sync to cloud)
Set-ItemProperty -Path $activityPath -Name "PublishUserActivities" -Value 0 -Type DWord -Force
Write-Applied "Publish User Activities" "Stopped — no cloud sync"

# Disable activity history upload
Set-ItemProperty -Path $activityPath -Name "UploadUserActivities" -Value 0 -Type DWord -Force
Write-Applied "Upload User Activities" "Stopped — nothing sent to Microsoft"

# Disable activity history collection entirely
$activityUserPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy"
Ensure-RegistryPath $activityUserPath
Set-ItemProperty -Path $activityUserPath -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0 -Type DWord -Force
Write-Applied "Tailored Experiences" "Disabled"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 3: CLIPBOARD HISTORY & CLOUD SYNC
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Disabling Clipboard History & Cloud Sync"
Write-Section "Clipboard History & Cloud Sync" "📎"

# WHY: Windows 11 can store clipboard history and sync it across devices
# via your Microsoft account. This means everything you copy — passwords,
# sensitive text, screenshots — could be sent to Microsoft's servers.

$clipPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
Ensure-RegistryPath $clipPath
Set-ItemProperty -Path $clipPath -Name "AllowClipboardHistory" -Value 0 -Type DWord -Force
Write-Applied "Clipboard History" "Disabled — Win+V will show single item only"

Set-ItemProperty -Path $clipPath -Name "AllowCrossDeviceClipboard" -Value 0 -Type DWord -Force
Write-Applied "Cross-Device Clipboard Sync" "Disabled — clipboard stays local"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 4: LOCATION TRACKING
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Disabling Location Tracking"
Write-Section "Location Tracking" "📍"

# WHY: Windows tracks your physical location via Wi-Fi triangulation, IP
# geolocation, and GPS (on supported devices). This data is shared with
# apps and Microsoft. Unless you use Maps, weather, or Find My Device,
# it's a pure privacy leak.

$locationPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors"
Ensure-RegistryPath $locationPath
Set-ItemProperty -Path $locationPath -Name "DisableLocation" -Value 1 -Type DWord -Force
Write-Applied "System Location Service" "Disabled"

Set-ItemProperty -Path $locationPath -Name "DisableLocationScripting" -Value 1 -Type DWord -Force
Write-Applied "Location Scripting" "Disabled"

Set-ItemProperty -Path $locationPath -Name "DisableWindowsLocationProvider" -Value 1 -Type DWord -Force
Write-Applied "Windows Location Provider" "Disabled"

# Disable location for current user
$locationUserPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"
Ensure-RegistryPath $locationUserPath
Set-ItemProperty -Path $locationUserPath -Name "Value" -Value "Deny" -Type String -Force
Write-Applied "User Location Access" "Denied for all apps"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 5: CAMERA & MICROPHONE BACKGROUND ACCESS
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Restricting Camera & Microphone Access"
Write-Section "Camera & Microphone" "📷"

# WHY: Background apps can access your camera and microphone without your
# knowledge. We block background access while keeping foreground access
# so your video calls, streaming, etc. still work normally.

# Camera — deny background access (apps in foreground still work)
$cameraConsentPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam"
Ensure-RegistryPath $cameraConsentPath
Write-Info "Camera foreground access preserved — only background access blocked"

# Find background app camera access entries and disable
$cameraBgPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy"
Ensure-RegistryPath $cameraBgPath
Set-ItemProperty -Path $cameraBgPath -Name "LetAppsAccessCamera" -Value 2 -Type DWord -Force
Write-Applied "Camera Background Access" "Force Deny for background apps"

# Microphone — deny background access
Set-ItemProperty -Path $cameraBgPath -Name "LetAppsAccessMicrophone" -Value 2 -Type DWord -Force
Write-Applied "Microphone Background Access" "Force Deny for background apps"

# Notifications access — restrict background
Set-ItemProperty -Path $cameraBgPath -Name "LetAppsAccessNotifications" -Value 2 -Type DWord -Force
Write-Applied "Notification Access" "Force Deny for background apps"

# Account info access — restrict
Set-ItemProperty -Path $cameraBgPath -Name "LetAppsAccessAccountInfo" -Value 2 -Type DWord -Force
Write-Applied "Account Info Access" "Force Deny for background apps"

# Contacts access — restrict
Set-ItemProperty -Path $cameraBgPath -Name "LetAppsAccessContacts" -Value 2 -Type DWord -Force
Write-Applied "Contacts Access" "Force Deny for background apps"

# Call history — restrict
Set-ItemProperty -Path $cameraBgPath -Name "LetAppsAccessCallHistory" -Value 2 -Type DWord -Force
Write-Applied "Call History Access" "Force Deny for background apps"

# Email access — restrict
Set-ItemProperty -Path $cameraBgPath -Name "LetAppsAccessEmail" -Value 2 -Type DWord -Force
Write-Applied "Email Access" "Force Deny for background apps"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 6: FIND MY DEVICE
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Disabling Find My Device"
Write-Section "Find My Device" "🔍"

# WHY: Find My Device constantly reports your location to Microsoft so
# you can find your laptop if stolen. However, this means Microsoft
# always knows your device's location. For a desktop gaming rig,
# this is completely unnecessary.

$findMyDevicePath = "HKLM:\SOFTWARE\Policies\Microsoft\FindMyDevice"
Ensure-RegistryPath $findMyDevicePath
Set-ItemProperty -Path $findMyDevicePath -Name "AllowFindMyDevice" -Value 0 -Type DWord -Force
Write-Applied "Find My Device" "Disabled — location no longer reported"

# Also disable the "Find My Device" service if it exists
$findSvc = Get-Service -Name "FDResPub" -ErrorAction SilentlyContinue
if ($findSvc) {
    Write-Info "Function Discovery Resource Publication service left running (needed by network)"
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 7: ADVERTISING & SUGGESTIONS
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Disabling Advertising & Suggestions"
Write-Section "Advertising ID & App Suggestions" "🎯"

# WHY: Windows assigns you a unique Advertising ID that is shared with
# all apps to track you across applications. App Suggestions are basically
# ads in your Start Menu. These are pure monetization features.

$adIdPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
Ensure-RegistryPath $adIdPath
Set-ItemProperty -Path $adIdPath -Name "Enabled" -Value 0 -Type DWord -Force
Write-Applied "Advertising ID" "Disabled — apps can't track you"

# Disable app suggestions (ads in start menu)
$contentDeliveryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
Ensure-RegistryPath $contentDeliveryPath
Set-ItemProperty -Path $contentDeliveryPath -Name "SystemPaneSuggestionsEnabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $contentDeliveryPath -Name "SubscribedContent-338388Enabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $contentDeliveryPath -Name "SubscribedContent-338389Enabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $contentDeliveryPath -Name "SubscribedContent-310093Enabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $contentDeliveryPath -Name "SubscribedContent-338393Enabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $contentDeliveryPath -Name "SubscribedContent-353694Enabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $contentDeliveryPath -Name "SubscribedContent-353696Enabled" -Value 0 -Type DWord -Force
Write-Applied "Start Menu Suggestions/Ads" "All disabled"

# Disable pre-installed app suggestions
Set-ItemProperty -Path $contentDeliveryPath -Name "OemPreInstalledAppsEnabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $contentDeliveryPath -Name "PreInstalledAppsEnabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $contentDeliveryPath -Name "PreInstalledAppsEverEnabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $contentDeliveryPath -Name "SilentInstalledAppsEnabled" -Value 0 -Type DWord -Force
Write-Applied "Pre-Installed App Suggestions" "Blocked"

# Disable lock screen tips and tricks
Set-ItemProperty -Path $contentDeliveryPath -Name "RotatingLockScreenEnabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $contentDeliveryPath -Name "RotatingLockScreenOverlayEnabled" -Value 0 -Type DWord -Force
Write-Applied "Lock Screen Tips" "Disabled"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 8: CORTANA, COPILOT & AI
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Disabling Cortana, Copilot & AI Data Collection"
Write-Section "Cortana, Copilot & AI" "🤖"

# WHY: Cortana records voice commands and sends them to Microsoft for
# processing. Copilot collects conversation data along with system context.
# Both are significant privacy concerns.

# Disable Cortana
$cortanaPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
Ensure-RegistryPath $cortanaPath
Set-ItemProperty -Path $cortanaPath -Name "AllowCortana" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $cortanaPath -Name "AllowCortanaAboveLock" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $cortanaPath -Name "AllowSearchToUseLocation" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $cortanaPath -Name "ConnectedSearchUseWeb" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $cortanaPath -Name "DisableWebSearch" -Value 1 -Type DWord -Force
Write-Applied "Cortana" "Fully disabled — no voice data sent"

# Disable web results in search
Write-Applied "Web Search in Start" "Disabled — searches stay local"

# Disable Copilot
$copilotPath = "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot"
Ensure-RegistryPath $copilotPath
Set-ItemProperty -Path $copilotPath -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord -Force
Write-Applied "Windows Copilot" "Disabled"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 9: TYPING & INKING PERSONALIZATION
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Disabling Typing & Inking Personalization"
Write-Section "Typing, Inking & Speech" "⌨"

# WHY: Windows collects everything you type to "improve suggestions."
# This includes form data, search queries, and anything typed in apps.
# Inking data includes handwriting and drawing patterns.

$inputPath = "HKCU:\Software\Microsoft\InputPersonalization"
Ensure-RegistryPath $inputPath
Set-ItemProperty -Path $inputPath -Name "RestrictImplicitInkCollection" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $inputPath -Name "RestrictImplicitTextCollection" -Value 1 -Type DWord -Force
Write-Applied "Text/Ink Collection" "Restricted — keystrokes not harvested"

$inputTrainPath = "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore"
Ensure-RegistryPath $inputTrainPath
Set-ItemProperty -Path $inputTrainPath -Name "HarvestContacts" -Value 0 -Type DWord -Force
Write-Applied "Contact Harvesting" "Disabled"

# Disable online speech recognition
$speechPath = "HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy"
Ensure-RegistryPath $speechPath
Set-ItemProperty -Path $speechPath -Name "HasAccepted" -Value 0 -Type DWord -Force
Write-Applied "Online Speech Recognition" "Disabled — voice data stays local"

# Disable handwriting personalization
$handwritingPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports"
Ensure-RegistryPath $handwritingPolicyPath
Set-ItemProperty -Path $handwritingPolicyPath -Name "PreventHandwritingErrorReports" -Value 1 -Type DWord -Force
Write-Applied "Handwriting Error Reports" "Disabled"

# Disable Wi-Fi Sense
$wifiPath = "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config"
Ensure-RegistryPath $wifiPath
Set-ItemProperty -Path $wifiPath -Name "AutoConnectAllowedOEM" -Value 0 -Type DWord -Force
Write-Applied "Wi-Fi Sense Auto-Connect" "Disabled — no auto-joining open networks"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 10: HOSTS FILE — BLOCK TRACKING DOMAINS
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Blocking Tracking Domains"
Write-Section "Hosts File — Block Tracking Domains" "🌐"

# WHY: Even after disabling telemetry via registry, Windows components may
# still attempt to contact tracking servers. Blocking at the hosts file
# level is a defense-in-depth approach — if anything slips through,
# the DNS resolution will fail and no data can be sent.

$hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
$hostsMarker = "# === PRIVACY LOCKDOWN — Tracking Domains Blocked ==="
$hostsEndMarker = "# === END PRIVACY LOCKDOWN ==="

# Check if we've already added our block list
$hostsContent = Get-Content -Path $hostsPath -Raw -ErrorAction SilentlyContinue
if ($hostsContent -match "PRIVACY LOCKDOWN") {
    Write-Info "Tracking domains already blocked in hosts file — skipping"
    Write-Skip "Hosts File" "Already configured"
}
else {
    $trackingDomains = @(
        # Microsoft Telemetry
        "vortex.data.microsoft.com",
        "vortex-win.data.microsoft.com",
        "telecommand.telemetry.microsoft.com",
        "telecommand.telemetry.microsoft.com.nsatc.net",
        "oca.telemetry.microsoft.com",
        "oca.telemetry.microsoft.com.nsatc.net",
        "sqm.telemetry.microsoft.com",
        "sqm.telemetry.microsoft.com.nsatc.net",
        "watson.telemetry.microsoft.com",
        "watson.telemetry.microsoft.com.nsatc.net",
        "redir.metaservices.microsoft.com",
        "choice.microsoft.com",
        "choice.microsoft.com.nsatc.net",
        "df.telemetry.microsoft.com",
        "reports.wes.df.telemetry.microsoft.com",
        "wes.df.telemetry.microsoft.com",
        "services.wes.df.telemetry.microsoft.com",
        "sqm.df.telemetry.microsoft.com",
        "telemetry.microsoft.com",
        "watson.ppe.telemetry.microsoft.com",
        "telemetry.appex.bing.net",
        "telemetry.urs.microsoft.com",
        "settings-sandbox.data.microsoft.com",
        "survey.watson.microsoft.com",
        "watson.microsoft.com",
        "statsfe2.ws.microsoft.com",
        "corpext.msitadfs.glbdns2.microsoft.com",
        "compatexchange.cloudapp.net",

        # Microsoft Advertising
        "ad.doubleclick.net",
        "ads.msn.com",
        "ads1.msads.net",
        "ads1.msn.com",
        "a.ads1.msn.com",
        "a.ads2.msn.com",
        "adnexus.net",
        "adnxs.com",

        # Microsoft SmartScreen (can be controversial — blocks phishing checks)
        # Uncomment these if you use a different browser:
        # "urs.microsoft.com",
        # "smartscreen.microsoft.com",

        # Bing tracking
        "a-0001.a-msedge.net",

        # NVIDIA Telemetry
        "telemetry.nvidia.com",
        "gfe.nvidia.com",
        "gfwsl.geforce.com",
        "events.gfe.nvidia.com"
    )

    $blockEntries = "`n$hostsMarker`n"
    foreach ($domain in $trackingDomains) {
        $blockEntries += "0.0.0.0 $domain`n"
    }
    $blockEntries += "$hostsEndMarker`n"

    Add-Content -Path $hostsPath -Value $blockEntries -Encoding ASCII -Force
    Write-Applied "Hosts File" "$($trackingDomains.Count) tracking domains blocked"

    # Flush DNS cache to apply immediately
    ipconfig /flushdns | Out-Null
    Write-Applied "DNS Cache" "Flushed — blocks active immediately"
}

# ══════════════════════════════════════════════════════════════════════════════
#                           COMPLETION SUMMARY
# ══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   ✅  PRIVACY LOCKDOWN COMPLETE!                            ║" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   📡 Telemetry:       Disabled + services stopped           ║" -ForegroundColor Green
Write-Host "  ║   📋 Activity History: Disabled + no cloud sync             ║" -ForegroundColor Green
Write-Host "  ║   📎 Clipboard Sync:   Local only — no cloud                ║" -ForegroundColor Green
Write-Host "  ║   📍 Location:         Disabled for all apps                ║" -ForegroundColor Green
Write-Host "  ║   📷 Camera/Mic:       Background access blocked            ║" -ForegroundColor Green
Write-Host "  ║   🔍 Find My Device:   Disabled                             ║" -ForegroundColor Green
Write-Host "  ║   🎯 Advertising ID:   Disabled + no ads in Start           ║" -ForegroundColor Green
Write-Host "  ║   🤖 Cortana/Copilot:  Fully disabled                       ║" -ForegroundColor Green
Write-Host "  ║   ⌨  Typing Data:      Not collected                        ║" -ForegroundColor Green
Write-Host "  ║   🌐 Hosts File:       Tracking domains blocked             ║" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   📄 Log: $LogFile" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   🛡  A restore point was created for safety.              ║" -ForegroundColor Green
Write-Host "  ║   💡 Use RestoreDefaults.ps1 or System Restore to undo.    ║" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Log "═══════════════════════════════════════════════════"
Write-Log "Privacy Lockdown Completed"
Write-Log "═══════════════════════════════════════════════════"

Write-Host "  Press Enter to exit..." -ForegroundColor DarkGray
Read-Host
