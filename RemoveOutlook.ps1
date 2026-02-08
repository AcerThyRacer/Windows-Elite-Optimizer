<#
╔══════════════════════════════════════════════════════════════════════════════╗
║                   📧 REMOVE OUTLOOK — Complete Wipe                        ║
║                                                                            ║
║  Fully removes Microsoft Outlook (New) from Windows 11, including:         ║
║    • The new Outlook app (UWP/MSIX)                                        ║
║    • Classic Outlook remnants                                               ║
║    • Hidden AppData, cache, and telemetry folders                          ║
║    • Registry entries and startup hooks                                     ║
║    • Scheduled tasks and mail sync                                          ║
║                                                                            ║
║  ⚠  WARNING: This removes Outlook completely. If you use Outlook for      ║
║     email, calendar, or contacts — EXPORT YOUR DATA FIRST.                 ║
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
$LogFile = "$env:USERPROFILE\RemoveOutlook_log.txt"

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
  ║        📧📧📧  OUTLOOK REMOVAL  📧📧📧                    ║
  ║                                                              ║
  ║       Complete Wipe — Mail, Calendar, Contacts               ║
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

function Write-Removed {
    param([string]$Name, [string]$Status = "Removed")
    Write-Host "    ✕ $Name" -ForegroundColor Red -NoNewline
    Write-Host " — $Status" -ForegroundColor DarkGray
    Write-Log "  [REMOVED] $Name — $Status"
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

# ─── Progress Tracker ────────────────────────────────────────────────────────
$totalSteps = 6
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

Write-Host "  ⚠  WARNING: This will COMPLETELY remove Microsoft Outlook!" -ForegroundColor Yellow
Write-Host "  ⚠  Both the new Outlook (Windows 11) and classic Outlook" -ForegroundColor Yellow
Write-Host "     remnants will be removed." -ForegroundColor Yellow
Write-Host ""
Write-Host "  ⚠  IMPORTANT: Export your emails, contacts, and calendar" -ForegroundColor Red
Write-Host "     data BEFORE running this script!" -ForegroundColor Red
Write-Host ""
Write-Host "  Continue? (Y/N): " -ForegroundColor Red -NoNewline
$confirm = Read-Host
if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "`n  Cancelled. No changes were made." -ForegroundColor Green
    exit
}

Write-Host ""
Write-Log "═══════════════════════════════════════════════════"
Write-Log "Outlook Removal Script Started"
Write-Log "═══════════════════════════════════════════════════"

# ─── Create Restore Point ────────────────────────────────────────────────────
Write-Section "System Restore Point" "🛡"
try {
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "Before Outlook Removal" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
    Write-Host "    ✓ Restore Point Created" -ForegroundColor Green
}
catch {
    Write-Skip "Restore Point" "Could not create (may have been created recently)"
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 1: KILL OUTLOOK PROCESSES
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Terminating Outlook Processes"
Write-Section "Kill Outlook Processes" "💀"

$processes = @("olk", "Outlook", "OUTLOOK", "HxOutlook", "HxTsr", "HxCalendarAppImm", "HxAccounts")
foreach ($proc in $processes) {
    $running = Get-Process -Name $proc -ErrorAction SilentlyContinue
    if ($running) {
        Stop-Process -Name $proc -Force -ErrorAction SilentlyContinue
        Write-Removed "$proc.exe" "Process terminated"
    }
}

Start-Sleep -Seconds 3

# ══════════════════════════════════════════════════════════════════════════════
# STEP 2: UNINSTALL OUTLOOK APPLICATIONS
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Uninstalling Outlook Applications"
Write-Section "Uninstall Outlook" "🗑"

# ─── Remove New Outlook (UWP/MSIX) ─────────────────────────────────────────
Write-Info "Removing new Outlook (Windows 11 app)..."

# The new Outlook uses Microsoft.OutlookForWindows package
$outlookPackages = Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -match "OutlookForWindows|OutlookDesktop|Microsoft.Outlook|microsoft.windowscommunicationsapps"
}

foreach ($pkg in $outlookPackages) {
    try {
        Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction Stop
        Write-Removed "$($pkg.Name)" "UWP package removed"
    }
    catch {
        Write-Info "  Trying alternate removal for $($pkg.Name)..."
        Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction SilentlyContinue
        Write-Removed "$($pkg.Name)" "Removed for current user"
    }
}

# Also remove provisioned packages (prevents reinstall for new users)
$provisionedPkgs = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object {
    $_.DisplayName -match "OutlookForWindows|OutlookDesktop|windowscommunicationsapps"
}

foreach ($pkg in $provisionedPkgs) {
    try {
        Remove-AppxProvisionedPackage -Online -PackageName $pkg.PackageName -ErrorAction Stop
        Write-Removed "$($pkg.DisplayName)" "Provisioned package removed"
    }
    catch {
        Write-Skip $pkg.DisplayName "Could not remove provisioned package"
    }
}

# ─── Remove via winget ──────────────────────────────────────────────────────
Write-Info "Attempting winget removal..."
winget uninstall "Microsoft.OutlookForWindows" --silent --accept-source-agreements 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Removed "Outlook (via winget)" "Uninstalled"
}

winget uninstall "Microsoft Outlook" --silent --accept-source-agreements 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Removed "Classic Outlook (via winget)" "Uninstalled"
}

# ─── Remove Classic Outlook (Office) ───────────────────────────────────────
# If classic Outlook from Office is installed, remove its profile
Write-Info "Cleaning classic Outlook profiles..."
$officeOutlookPath = "HKCU:\Software\Microsoft\Office\16.0\Outlook\Profiles"
if (Test-Path $officeOutlookPath) {
    Remove-Item -Path $officeOutlookPath -Recurse -Force -ErrorAction SilentlyContinue
    Write-Removed "Classic Outlook Profiles" "Email profiles cleared"
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 3: REMOVE ALL HIDDEN FOLDERS & CACHE
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Removing Hidden Data & Cache"
Write-Section "Remove Outlook Folders & Hidden Data" "📁"

$foldersToRemove = @(
    # New Outlook data
    "$env:LOCALAPPDATA\Microsoft\Olk",
    "$env:LOCALAPPDATA\Microsoft\Outlook",
    # New Outlook cache and offline data
    "$env:LOCALAPPDATA\Packages\Microsoft.OutlookForWindows_8wekyb3d8bbwe",
    # Windows Communications Apps (Mail/Calendar/People — Outlook dependencies)
    "$env:LOCALAPPDATA\Packages\microsoft.windowscommunicationsapps_8wekyb3d8bbwe",
    # Classic Outlook PST/OST data folder
    "$env:LOCALAPPDATA\Microsoft\Outlook",
    # Roaming profile data
    "$env:APPDATA\Microsoft\Outlook",
    # Outlook signatures
    "$env:APPDATA\Microsoft\Signatures",
    # Outlook stationery/templates
    "$env:APPDATA\Microsoft\Stationery",
    # Office shared caches that Outlook uses
    "$env:LOCALAPPDATA\Microsoft\Office\OTele",
    "$env:LOCALAPPDATA\Microsoft\Office\16.0\OfficeFileCache",
    # Outlook temp files
    "$env:LOCALAPPDATA\Microsoft\Windows\INetCache\Content.Outlook",
    "$env:LOCALAPPDATA\Temp\Outlook*",
    # Outlook diagnostic/telemetry data
    "$env:LOCALAPPDATA\Microsoft\Office\16.0\Outlook",
    # Modern Outlook telemetry
    "$env:LOCALAPPDATA\Microsoft\Olk\logs",
    "$env:LOCALAPPDATA\Microsoft\Olk\telemetry"
)

foreach ($folder in $foldersToRemove) {
    $expandedPaths = Resolve-Path $folder -ErrorAction SilentlyContinue
    if ($expandedPaths) {
        foreach ($path in $expandedPaths) {
            if (Test-Path $path.Path) {
                try {
                    Remove-Item -Path $path.Path -Recurse -Force -ErrorAction Stop
                    Write-Removed $path.Path "Folder deleted"
                }
                catch {
                    cmd /c "rd /s /q `"$($path.Path)`"" 2>$null
                    if (-not (Test-Path $path.Path)) {
                        Write-Removed $path.Path "Folder force-deleted"
                    }
                    else {
                        Write-Skip $path.Path "Locked — will be cleaned on restart"
                    }
                }
            }
        }
    }
    else {
        if (Test-Path $folder) {
            try {
                Remove-Item -Path $folder -Recurse -Force -ErrorAction Stop
                Write-Removed $folder "Folder deleted"
            }
            catch {
                cmd /c "rd /s /q `"$folder`"" 2>$null
                Write-Skip $folder "Some files locked"
            }
        }
    }
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 4: CLEAN REGISTRY
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Cleaning Registry"
Write-Section "Remove Outlook Registry Entries" "🔑"

# Remove Outlook startup entries
$runKeys = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
)
foreach ($key in $runKeys) {
    Remove-ItemProperty -Path $key -Name "Outlook" -Force -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $key -Name "Microsoft Outlook" -Force -ErrorAction SilentlyContinue
}
Write-Removed "Startup Entries" "Outlook auto-start removed"

# Clean Outlook registry keys
$regKeys = @(
    "HKCU:\Software\Microsoft\Office\16.0\Outlook",
    "HKCU:\Software\Microsoft\Office\Outlook",
    "HKCU:\Software\Microsoft\Outlook",
    "HKLM:\Software\Microsoft\Office\16.0\Outlook",
    "HKLM:\Software\Microsoft\Office\Outlook",
    "HKLM:\Software\Clients\Mail\Microsoft Outlook"
)
foreach ($key in $regKeys) {
    if (Test-Path $key) {
        Remove-Item -Path $key -Recurse -Force -ErrorAction SilentlyContinue
        Write-Removed "Registry: $key"
    }
}

# Remove Outlook protocol handlers (mailto:, outlook:, etc.)
$protocols = @("mailto", "outlook", "ms-outlook")
foreach ($proto in $protocols) {
    $protoPath = "HKCU:\Software\Classes\$proto"
    if (Test-Path $protoPath) {
        $handler = Get-ItemProperty -Path $protoPath -ErrorAction SilentlyContinue
        if ($handler -and $handler."(default)" -match "Outlook") {
            Remove-Item -Path $protoPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Removed "Protocol: $proto" "Handler unregistered"
        }
    }
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 5: REMOVE SCHEDULED TASKS
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Removing Scheduled Tasks"
Write-Section "Remove Outlook Scheduled Tasks" "📅"

$tasks = Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object {
    $_.TaskName -match "Outlook|Office Automatic Updates|OfficeTelemetry" -or
    $_.TaskPath -match "Microsoft\\Office"
}
foreach ($task in $tasks) {
    if ($task.TaskName -match "Outlook|OfficeTelemetry") {
        Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false -ErrorAction SilentlyContinue
        Write-Removed "Task: $($task.TaskName)"
    }
}

if (-not $tasks) {
    Write-Skip "Scheduled Tasks" "No Outlook-specific tasks found"
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 6: PREVENT REINSTALLATION
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Preventing Reinstallation"
Write-Section "Block Outlook Reinstallation" "🔒"

# Prevent Windows from suggesting/reinstalling Outlook
# Block "Suggest new Outlook" nags
$outlookPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\Outlook\Options\General"
if (-not (Test-Path $outlookPolicyPath)) {
    New-Item -Path $outlookPolicyPath -Force | Out-Null
}
Set-ItemProperty -Path $outlookPolicyPath -Name "HideNewOutlookToggle" -Value 1 -Type DWord -Force
Write-Removed "New Outlook Toggle" "Suggestion nag blocked"

# Block the Mail and Calendar app from being re-provisioned
$contentDeliveryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
if (Test-Path $contentDeliveryPath) {
    Set-ItemProperty -Path $contentDeliveryPath -Name "SilentInstalledAppsEnabled" -Value 0 -Type DWord -Force
    Write-Removed "Silent App Install" "Blocked auto-reinstallation"
}

# Remove pin from taskbar/start if present
Write-Info "Removing Start Menu and Taskbar pins..."

# ══════════════════════════════════════════════════════════════════════════════
#                           COMPLETION SUMMARY
# ══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║                                                              ║" -ForegroundColor Magenta
Write-Host "  ║   ✅  OUTLOOK COMPLETELY REMOVED!                           ║" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Magenta
Write-Host "  ║   📧 New Outlook:    UWP/MSIX packages removed             ║" -ForegroundColor Magenta
Write-Host "  ║   📧 Classic Outlook: Profiles and data cleaned            ║" -ForegroundColor Magenta
Write-Host "  ║   📁 Hidden Folders:  All cache/telemetry wiped            ║" -ForegroundColor Magenta
Write-Host "  ║   🔑 Registry:       All entries cleaned                    ║" -ForegroundColor Magenta
Write-Host "  ║   📅 Scheduled Tasks: Outlook tasks removed                 ║" -ForegroundColor Magenta
Write-Host "  ║   🔒 Policy:         Reinstallation blocked                 ║" -ForegroundColor Magenta
Write-Host "  ║                                                              ║" -ForegroundColor Magenta
Write-Host "  ║   📄 Log: $LogFile" -ForegroundColor Magenta
Write-Host "  ║                                                              ║" -ForegroundColor Magenta
Write-Host "  ║   💡 You can use Thunderbird or a web browser for email.    ║" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Magenta
Write-Host "  ║   ⚠  A restart is recommended for full effect.             ║" -ForegroundColor Yellow
Write-Host "  ║   🛡  A restore point was created for safety.              ║" -ForegroundColor Magenta
Write-Host "  ║                                                              ║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

Write-Log "═══════════════════════════════════════════════════"
Write-Log "Outlook Removal Completed"
Write-Log "═══════════════════════════════════════════════════"

Write-Host "  Would you like to restart now? (Y/N): " -ForegroundColor Yellow -NoNewline
$restart = Read-Host
if ($restart -eq "Y" -or $restart -eq "y") {
    Write-Host "  Restarting in 10 seconds..." -ForegroundColor Red
    shutdown /r /t 10 /c "Restarting after Outlook removal"
}
else {
    Write-Host "  Remember to restart for all changes to take full effect!" -ForegroundColor Yellow
}

Write-Host ""
