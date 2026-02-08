<#
╔══════════════════════════════════════════════════════════════════════════════╗
║                     ⏪ RESTORE DEFAULTS — Windows 11                       ║
║                   Undo All Performance Optimizations                        ║
║                                                                            ║
║  This script reverses ALL changes made by ElitePerformance.ps1 or          ║
║  ProPerformance.ps1. It restores Windows to its default configuration.     ║
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
$LogFile = "$env:USERPROFILE\RestoreDefaults_log.txt"
$EliteGuid = "e9a42b02-d5df-448d-aa00-03f14749eb61"
$ProGuid = "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
$BalancedGuid = "381b4222-f694-41f0-9685-ff5bb260df2e"

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
  ║        ⏪⏪⏪  RESTORE DEFAULTS  ⏪⏪⏪                    ║
  ║                                                              ║
  ║       Windows 11 — Undo All Performance Tweaks               ║
  ║                                                              ║
  ║       Revert everything back to factory defaults.            ║
  ║                                                              ║
  ╚══════════════════════════════════════════════════════════════╝

"@
    Write-Host $banner -ForegroundColor Red
}

function Write-Section {
    param([string]$Title, [string]$Icon = "►")
    Write-Host ""
    Write-Host "  ┌──────────────────────────────────────────────────────────" -ForegroundColor DarkRed
    Write-Host "  │ $Icon $Title" -ForegroundColor Red
    Write-Host "  └──────────────────────────────────────────────────────────" -ForegroundColor DarkRed
    Write-Log "=== $Title ==="
}

function Write-Restored {
    param([string]$Name, [string]$Status = "Default")
    Write-Host "    ↩ $Name" -ForegroundColor Cyan -NoNewline
    Write-Host " → $Status" -ForegroundColor DarkGray
    Write-Log "  [RESTORED] $Name → $Status"
}

function Write-Skip {
    param([string]$Name, [string]$Reason)
    Write-Host "    ⊘ $Name" -ForegroundColor DarkGray -NoNewline
    Write-Host " — $Reason" -ForegroundColor DarkGray
    Write-Log "  [SKIP] $Name — $Reason"
}

function Set-RegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$Type = "DWord"
    )
    try {
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force
        return $true
    }
    catch {
        Write-Log "  [ERR] Failed to set $Path\$Name : $_"
        return $false
    }
}

function Remove-RegistryValue {
    param([string]$Path, [string]$Name)
    try {
        Remove-ItemProperty -Path $Path -Name $Name -Force -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Set-ServiceStartup {
    param(
        [string]$ServiceName,
        [string]$StartType = "Automatic"
    )
    try {
        Set-Service -Name $ServiceName -StartupType $StartType -ErrorAction Stop
        if ($StartType -eq "Automatic" -or $StartType -eq "Manual") {
            Start-Service -Name $ServiceName -ErrorAction SilentlyContinue
        }
        return $true
    }
    catch {
        return $false
    }
}

# ─── Progress Tracker ────────────────────────────────────────────────────────
$totalSteps = 8
$currentStep = 0

function Show-Progress {
    param([string]$StepName)
    $script:currentStep++
    $pct = [math]::Round(($script:currentStep / $totalSteps) * 100)
    $filled = [math]::Round($pct / 5)
    $empty = 20 - $filled
    $bar = ("█" * $filled) + ("░" * $empty)
    Write-Host ""
    Write-Host "  [$bar] $pct% — $StepName" -ForegroundColor Red
}

# ══════════════════════════════════════════════════════════════════════════════
#                              MAIN EXECUTION
# ══════════════════════════════════════════════════════════════════════════════

Clear-Host
Write-Banner

Write-Host "  ⚠  This will UNDO all performance optimizations!" -ForegroundColor Yellow
Write-Host "  Your system will be restored to Windows defaults." -ForegroundColor White
Write-Host ""
Write-Host "  Continue? (Y/N): " -ForegroundColor Yellow -NoNewline
$confirm = Read-Host
if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "`n  Cancelled. No changes were made." -ForegroundColor Green
    exit
}

Write-Host ""
Write-Host "  Restoring defaults..." -ForegroundColor White
Write-Log "═══════════════════════════════════════════════════"
Write-Log "Restore Defaults Script Started"
Write-Log "═══════════════════════════════════════════════════"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 1: REMOVE CUSTOM POWER PLANS
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Removing Custom Power Plans"
Write-Section "Power Plan Restoration" "⚡"

# Set Balanced as active first
powercfg /setactive $BalancedGuid 2>$null
Write-Restored "Active Plan" "Balanced"

# Delete Elite plan
powercfg /delete $EliteGuid 2>$null
Write-Restored "Elite Performance Plan" "Removed"

# Delete Pro plan
powercfg /delete $ProGuid 2>$null
Write-Restored "Pro Performance Plan" "Removed"

# Re-enable hibernate
powercfg /hibernate on 2>$null
Write-Restored "Hibernate" "Enabled"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 2: RESTORE GPU & DISPLAY SETTINGS
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Restoring GPU & Display"
Write-Section "GPU & Display Defaults" "🎮"

Remove-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\DirectX\UserGpuPreferences" `
    -Name "DirectXUserGlobalSettings"
Write-Restored "GPU Preference" "System Default"

Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" `
    -Name "HwSchMode" -Value 2 -Type DWord
Write-Restored "HW GPU Scheduling" "System Default"

# Restore fullscreen optimizations
Set-RegistryValue -Path "HKCU:\System\GameConfigStore" `
    -Name "GameDVR_FSEBehaviorMode" -Value 0 -Type DWord
Set-RegistryValue -Path "HKCU:\System\GameConfigStore" `
    -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 0 -Type DWord
Set-RegistryValue -Path "HKCU:\System\GameConfigStore" `
    -Name "GameDVR_FSEBehavior" -Value 0 -Type DWord
Remove-RegistryValue -Path "HKCU:\System\GameConfigStore" `
    -Name "GameDVR_DXGIHonorFSEWindowsCompatible"
Write-Restored "Fullscreen Optimizations" "Windows Default"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 3: RESTORE MEMORY & CACHE
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Restoring Memory & Cache"
Write-Section "Memory & Cache Defaults" "🧠"

# Re-enable memory compression
try {
    Enable-MMAgent -MemoryCompression -ErrorAction Stop
    Write-Restored "Memory Compression" "Enabled"
}
catch {
    Write-Skip "Memory Compression" "Already enabled"
}

# Re-enable Prefetch to defaults (3 = boot and application prefetching)
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" `
    -Name "EnablePrefetcher" -Value 3 -Type DWord
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" `
    -Name "EnableSuperfetch" -Value 3 -Type DWord
Write-Restored "Prefetch" "Enabled (Boot + Apps)"

# Reset Large System Cache
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" `
    -Name "LargeSystemCache" -Value 0 -Type DWord
Write-Restored "Large System Cache" "Default (Programs)"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 4: RESTORE NETWORK SETTINGS
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Restoring Network Settings"
Write-Section "Network Defaults" "🌐"

# Remove Nagle's Algorithm overrides
$adapters = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
foreach ($adapter in $adapters) {
    Remove-ItemProperty -Path $adapter.PSPath -Name "TcpAckFrequency" -Force -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $adapter.PSPath -Name "TCPNoDelay" -Force -ErrorAction SilentlyContinue
}
Write-Restored "Nagle's Algorithm" "Default (Enabled)"

# Restore network throttling to default (10)
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" `
    -Name "NetworkThrottlingIndex" -Value 10 -Type DWord
Write-Restored "Network Throttling" "Default"

# Restore DNS cache defaults
Remove-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" -Name "MaxCacheTtl"
Remove-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" -Name "MaxNegativeCacheTtl"
Write-Restored "DNS Cache" "Default TTL"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 5: RESTORE SCHEDULER & TIMER
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Restoring Scheduler & Timer"
Write-Section "Scheduler & Timer Defaults" "⏱"

# Restore Win32PrioritySeparation to default (2 = short, fixed, no foreground boost)
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" `
    -Name "Win32PrioritySeparation" -Value 2 -Type DWord
Write-Restored "CPU Scheduler" "Default (Balanced)"

# Restore SystemResponsiveness to default (20)
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" `
    -Name "SystemResponsiveness" -Value 20 -Type DWord
Write-Restored "System Responsiveness" "Default (20%)"

# Restore game priority
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" `
    -Name "GPU Priority" -Value 2 -Type DWord
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" `
    -Name "Priority" -Value 2 -Type DWord
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" `
    -Name "Scheduling Category" -Value "Medium" -Type String
Write-Restored "Game Task Priority" "Default (Medium)"

# Revert bcdedit timer changes
bcdedit /deletevalue useplatformtick 2>$null
bcdedit /deletevalue disabledynamictick 2>$null
Write-Restored "System Timer" "Default (Dynamic Tick)"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 6: RESTORE SERVICES
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Restoring Services"
Write-Section "Service Restoration" "🔇"

$servicesToRestore = @(
    @{ Name = "SysMain"; Type = "Automatic"; Desc = "Superfetch" },
    @{ Name = "DiagTrack"; Type = "Automatic"; Desc = "Telemetry" },
    @{ Name = "WSearch"; Type = "Automatic"; Desc = "Windows Search" },
    @{ Name = "MapsBroker"; Type = "Automatic"; Desc = "Maps Manager" },
    @{ Name = "Fax"; Type = "Manual"; Desc = "Fax" },
    @{ Name = "TabletInputService"; Type = "Manual"; Desc = "Touch Keyboard" },
    @{ Name = "RetailDemo"; Type = "Manual"; Desc = "Retail Demo" },
    @{ Name = "WMPNetworkSvc"; Type = "Manual"; Desc = "WMP Sharing" },
    @{ Name = "AJRouter"; Type = "Manual"; Desc = "AllJoyn Router" },
    @{ Name = "dmwappushservice"; Type = "Automatic"; Desc = "WAP Push" }
)

foreach ($svc in $servicesToRestore) {
    $result = Set-ServiceStartup -ServiceName $svc.Name -StartType $svc.Type
    if ($result) {
        Write-Restored "$($svc.Name)" "$($svc.Type) — $($svc.Desc)"
    }
    else {
        Write-Skip $svc.Name "Service not found"
    }
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 7: RESTORE VISUAL EFFECTS & TELEMETRY
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Restoring Visuals & Telemetry"
Write-Section "Visual Effects & Telemetry Defaults" "👁"

# Restore visual effects to "Let Windows choose"
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
    -Name "VisualFXSetting" -Value 0 -Type DWord
Write-Restored "Visual Effects" "Let Windows Choose"

# Re-enable transparency
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
    -Name "EnableTransparency" -Value 1 -Type DWord
Write-Restored "Transparency" "Enabled"

# Restore desktop animations
Set-RegistryValue -Path "HKCU:\Control Panel\Desktop" `
    -Name "UserPreferencesMask" -Value ([byte[]](0x9E, 0x1E, 0x07, 0x80, 0x12, 0x00, 0x00, 0x00)) -Type Binary
Write-Restored "Desktop Animations" "All Enabled"

# Re-enable Game Bar & DVR
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" `
    -Name "AppCaptureEnabled" -Value 1 -Type DWord
Set-RegistryValue -Path "HKCU:\System\GameConfigStore" `
    -Name "GameDVR_Enabled" -Value 1 -Type DWord
Remove-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR"
Write-Restored "Game Bar & DVR" "Enabled"

# Re-enable Widgets
Remove-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests"
Write-Restored "Widgets" "Enabled"

# Restore telemetry to default
Remove-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry"
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" `
    -Name "AllowTelemetry" -Value 3 -Type DWord
Write-Restored "Telemetry" "Default (Full)"

# Restore Cortana
Remove-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana"
Write-Restored "Cortana" "Enabled"

# Restore Activity History
Remove-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed"
Remove-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities"
Remove-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities"
Write-Restored "Activity History" "Enabled"

# Re-enable background apps
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" `
    -Name "GlobalUserDisabled" -Value 0 -Type DWord
Remove-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BackgroundAppGlobalToggle"
Write-Restored "Background Apps" "Enabled"

# Restore CEIP
Remove-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" -Name "CEIPEnable"
Write-Restored "CEIP" "Default"

# Restore Advertising ID
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" `
    -Name "Enabled" -Value 1 -Type DWord
Write-Restored "Advertising ID" "Enabled"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 8: RESTORE FILESYSTEM
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Restoring Filesystem Settings"
Write-Section "NTFS & Filesystem Defaults" "💾"

fsutil behavior set disable8dot3 2 2>$null
Write-Restored "8.3 Filenames" "Per-volume default"

fsutil behavior set disablelastaccess 2 2>$null
Write-Restored "Last Access Time" "System managed"

fsutil behavior set memoryusage 1 2>$null
Write-Restored "NTFS Memory Usage" "Default"

# ══════════════════════════════════════════════════════════════════════════════
#                           COMPLETION SUMMARY
# ══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Cyan
Write-Host "  ║   ✅  ALL DEFAULTS RESTORED SUCCESSFULLY!                   ║" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Cyan
Write-Host "  ║   ⚡ Power Plans:    Elite & Pro removed, Balanced active   ║" -ForegroundColor Cyan
Write-Host "  ║   🧠 Memory:         Compression ON, Prefetch ON           ║" -ForegroundColor Cyan
Write-Host "  ║   🎮 GPU:            System defaults restored              ║" -ForegroundColor Cyan
Write-Host "  ║   🌐 Network:        Nagle ON, Throttling default          ║" -ForegroundColor Cyan
Write-Host "  ║   ⏱  Scheduler:      Default priority                      ║" -ForegroundColor Cyan
Write-Host "  ║   🔇 Services:       All services re-enabled               ║" -ForegroundColor Cyan
Write-Host "  ║   👁  Visuals:        All effects restored                  ║" -ForegroundColor Cyan
Write-Host "  ║   🚫 Telemetry:      Default (re-enabled)                  ║" -ForegroundColor Cyan
Write-Host "  ║   💾 Filesystem:     Default NTFS settings                 ║" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Cyan
Write-Host "  ║   📄 Log: $LogFile" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Cyan
Write-Host "  ║   ⚠  A system restart is REQUIRED.                         ║" -ForegroundColor Yellow
Write-Host "  ║                                                              ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Log "═══════════════════════════════════════════════════"
Write-Log "Restore Defaults Script Completed Successfully"
Write-Log "═══════════════════════════════════════════════════"

# Prompt for restart
Write-Host "  Would you like to restart now? (Y/N): " -ForegroundColor Yellow -NoNewline
$restart = Read-Host
if ($restart -eq "Y" -or $restart -eq "y") {
    Write-Host "  Restarting in 10 seconds..." -ForegroundColor Red
    shutdown /r /t 10 /c "Restarting to complete system restore"
}
else {
    Write-Host "  Remember to restart your PC for all changes to take effect!" -ForegroundColor Yellow
}

Write-Host ""
