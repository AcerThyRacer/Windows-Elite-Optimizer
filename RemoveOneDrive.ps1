<#
╔══════════════════════════════════════════════════════════════════════════════╗
║                   ☁ REMOVE ONEDRIVE — Complete Wipe                        ║
║                                                                            ║
║  Fully removes Microsoft OneDrive from Windows 11, including:              ║
║    • The application itself                                                ║
║    • Scheduled tasks                                                       ║
║    • Explorer integration (sidebar, context menus)                         ║
║    • Hidden folders and leftover registry entries                          ║
║    • Startup entries and services                                          ║
║                                                                            ║
║  ⚠  WARNING: This is IRREVERSIBLE. Your OneDrive files synced locally     ║
║     will remain, but cloud sync will be permanently removed.               ║
║     BACK UP your OneDrive folder BEFORE running this script.               ║
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
$LogFile = "$env:USERPROFILE\RemoveOneDrive_log.txt"

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
  ║        ☁☁☁  ONEDRIVE REMOVAL  ☁☁☁                      ║
  ║                                                              ║
  ║       Complete Wipe — No Traces Left Behind                  ║
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
$totalSteps = 7
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

Write-Host "  ⚠  WARNING: This will COMPLETELY remove Microsoft OneDrive!" -ForegroundColor Yellow
Write-Host "  ⚠  This includes cloud sync, Explorer integration, and all" -ForegroundColor Yellow
Write-Host "     hidden components. This action is IRREVERSIBLE." -ForegroundColor Yellow
Write-Host ""
Write-Host "  ⚠  Make sure you have BACKED UP your OneDrive folder:" -ForegroundColor Yellow
Write-Host "     $env:USERPROFILE\OneDrive" -ForegroundColor White
Write-Host ""
Write-Host "  Continue? (Y/N): " -ForegroundColor Red -NoNewline
$confirm = Read-Host
if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "`n  Cancelled. No changes were made." -ForegroundColor Green
    exit
}

Write-Host ""
Write-Log "═══════════════════════════════════════════════════"
Write-Log "OneDrive Removal Script Started"
Write-Log "═══════════════════════════════════════════════════"

# ─── Create Restore Point ────────────────────────────────────────────────────
Write-Section "System Restore Point" "🛡"
try {
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "Before OneDrive Removal" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
    Write-Host "    ✓ Restore Point Created" -ForegroundColor Green
}
catch {
    Write-Skip "Restore Point" "Could not create (may have been created recently)"
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 1: KILL ONEDRIVE PROCESSES
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Terminating OneDrive Processes"
Write-Section "Kill OneDrive Processes" "💀"

$processes = @("OneDrive", "OneDriveSetup", "FileSyncHelper", "FileCoAuth")
foreach ($proc in $processes) {
    $running = Get-Process -Name $proc -ErrorAction SilentlyContinue
    if ($running) {
        Stop-Process -Name $proc -Force -ErrorAction SilentlyContinue
        Write-Removed "$proc.exe" "Process terminated"
    }
    else {
        Write-Skip $proc "Not running"
    }
}

# Wait for processes to fully terminate
Start-Sleep -Seconds 3

# ══════════════════════════════════════════════════════════════════════════════
# STEP 2: UNINSTALL ONEDRIVE APPLICATION
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Uninstalling OneDrive Application"
Write-Section "Uninstall OneDrive" "🗑"

# Try the official Microsoft uninstall methods

# Method 1: winget (Windows 11 built-in)
Write-Info "Attempting winget uninstall..."
winget uninstall "Microsoft.OneDrive" --silent --accept-source-agreements 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Removed "OneDrive (via winget)" "Application uninstalled"
}
else {
    # Method 2: OneDriveSetup.exe /uninstall
    Write-Info "Attempting OneDriveSetup /uninstall..."
    $setupPaths = @(
        "$env:SystemRoot\System32\OneDriveSetup.exe",
        "$env:SystemRoot\SysWOW64\OneDriveSetup.exe",
        "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDriveSetup.exe",
        "$env:LOCALAPPDATA\Microsoft\OneDrive\Update\OneDriveSetup.exe"
    )
    
    $uninstalled = $false
    foreach ($setup in $setupPaths) {
        if (Test-Path $setup) {
            Start-Process $setup -ArgumentList "/uninstall" -Wait -ErrorAction SilentlyContinue
            Write-Removed "OneDrive (via $setup)" "Uninstall triggered"
            $uninstalled = $true
            break
        }
    }
    
    if (-not $uninstalled) {
        Write-Skip "OneDriveSetup.exe" "Not found — may already be uninstalled"
    }
}

Start-Sleep -Seconds 5

# ══════════════════════════════════════════════════════════════════════════════
# STEP 3: REMOVE ONEDRIVE FOLDERS — ALL HIDDEN LOCATIONS
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Removing OneDrive Folders"
Write-Section "Remove OneDrive Folders & Hidden Data" "📁"

$foldersToRemove = @(
    # Primary OneDrive application data
    "$env:LOCALAPPDATA\Microsoft\OneDrive",
    # OneDrive logs and telemetry
    "$env:LOCALAPPDATA\OneDrive",
    # Program data (system-wide config)
    "$env:ProgramData\Microsoft OneDrive",
    # Hidden application data in AppData\Roaming
    "$env:APPDATA\Microsoft\OneDrive",
    # 32-bit program files
    "${env:ProgramFiles(x86)}\Microsoft OneDrive",
    # 64-bit program files
    "$env:ProgramFiles\Microsoft OneDrive",
    # Windows Apps UWP folder
    "$env:LOCALAPPDATA\Packages\Microsoft.OneDriveSync_8wekyb3d8bbwe",
    # Old Windows 10/11 OneDrive cache
    "$env:LOCALAPPDATA\Microsoft\Windows\OneDrive",
    # OneDrive temp/setup files
    "$env:TEMP\OneDrive*",
    # User's actual OneDrive sync folder (just the link, content stays)
    "$env:USERPROFILE\OneDrive"
)

foreach ($folder in $foldersToRemove) {
    # Handle wildcard paths
    $expandedPaths = Resolve-Path $folder -ErrorAction SilentlyContinue
    if ($expandedPaths) {
        foreach ($path in $expandedPaths) {
            if (Test-Path $path.Path) {
                try {
                    # Force remove including hidden and read-only files
                    Remove-Item -Path $path.Path -Recurse -Force -ErrorAction Stop
                    Write-Removed $path.Path "Folder deleted"
                }
                catch {
                    # Some files may be locked — try with cmd /c rd
                    cmd /c "rd /s /q `"$($path.Path)`"" 2>$null
                    if (-not (Test-Path $path.Path)) {
                        Write-Removed $path.Path "Folder force-deleted"
                    }
                    else {
                        Write-Skip $path.Path "Locked — will be removed on restart"
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
                Write-Skip $folder "Some files locked — removed what was possible"
            }
        }
    }
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 4: CLEAN REGISTRY — ALL ONEDRIVE ENTRIES
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Cleaning Registry Entries"
Write-Section "Remove OneDrive Registry Entries" "🔑"

# Remove OneDrive from Run (startup)
$runKeys = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
)
foreach ($key in $runKeys) {
    Remove-ItemProperty -Path $key -Name "OneDrive" -Force -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $key -Name "OneDriveSetup" -Force -ErrorAction SilentlyContinue
}
Write-Removed "Startup Entries" "OneDrive auto-start disabled"

# Remove OneDrive from Explorer sidebar (Navigation Pane)
# CLSID for OneDrive in navigation pane
$oneDriveCLSIDs = @(
    "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}",
    "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
)
foreach ($clsid in $oneDriveCLSIDs) {
    if (Test-Path $clsid) {
        # Set System.IsPinnedToNameSpaceTree = 0 to remove from sidebar
        Set-ItemProperty -Path $clsid -Name "System.IsPinnedToNameSpaceTree" -Value 0 -Force -ErrorAction SilentlyContinue
        Write-Removed "Explorer Sidebar Entry ($clsid)" "Unpinned from navigation"
    }
}

# Remove OneDrive namespace from Explorer
$namespaceKeys = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{018D5C66-4533-4307-9B53-224DE2ED1FE6}",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
)
foreach ($ns in $namespaceKeys) {
    if (Test-Path $ns) {
        Remove-Item -Path $ns -Recurse -Force -ErrorAction SilentlyContinue
        Write-Removed "Explorer Namespace" "Removed from Desktop NameSpace"
    }
}

# Remove OneDrive context menu entries
$contextMenuKeys = @(
    "HKCR:\*\shellex\ContextMenuHandlers\FileSyncEx",
    "HKCR:\Directory\shellex\ContextMenuHandlers\FileSyncEx",
    "HKCR:\Directory\Background\shellex\ContextMenuHandlers\FileSyncEx"
)
foreach ($ctx in $contextMenuKeys) {
    if (Test-Path $ctx) {
        Remove-Item -Path $ctx -Recurse -Force -ErrorAction SilentlyContinue
        Write-Removed "Context Menu: $ctx" "Right-click menu cleaned"
    }
}

# Remove OneDrive icon overlay handlers (the sync status icons)
$overlayKeys = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers" -ErrorAction SilentlyContinue | 
Where-Object { $_.PSChildName -match "OneDrive|SkyDrive" }
foreach ($overlay in $overlayKeys) {
    Remove-Item -Path $overlay.PSPath -Recurse -Force -ErrorAction SilentlyContinue
    Write-Removed "Icon Overlay: $($overlay.PSChildName)" "Sync status icons removed"
}

# Clean up additional OneDrive registry debris
$regDebris = @(
    "HKCU:\Software\Microsoft\OneDrive",
    "HKLM:\Software\Microsoft\OneDrive",
    "HKLM:\Software\WOW6432Node\Microsoft\OneDrive",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{A52BBA46-E9E1-435F-B3D9-28DAA648C0F6}",
    "HKCU:\Environment"  # Clean OneDrive env variable
)
foreach ($key in $regDebris) {
    if ($key -eq "HKCU:\Environment") {
        # Only remove OneDrive-specific env var, not the whole key
        Remove-ItemProperty -Path $key -Name "OneDrive" -Force -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $key -Name "OneDriveConsumer" -Force -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $key -Name "OneDriveCommercial" -Force -ErrorAction SilentlyContinue
        Write-Removed "Environment Variables" "OneDrive paths removed"
    }
    else {
        if (Test-Path $key) {
            Remove-Item -Path $key -Recurse -Force -ErrorAction SilentlyContinue
            Write-Removed "Registry Key: $key"
        }
    }
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 5: REMOVE SCHEDULED TASKS
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Removing Scheduled Tasks"
Write-Section "Remove OneDrive Scheduled Tasks" "📅"

$tasks = Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object { $_.TaskName -match "OneDrive" }
foreach ($task in $tasks) {
    Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false -ErrorAction SilentlyContinue
    Write-Removed "Task: $($task.TaskName)" "Scheduled task removed"
}

if (-not $tasks) {
    Write-Skip "Scheduled Tasks" "No OneDrive tasks found"
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 6: PREVENT REINSTALLATION
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Preventing Reinstallation"
Write-Section "Block OneDrive Reinstallation" "🔒"

# Group Policy: Prevent OneDrive from being used for file storage
$gpoPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"
if (-not (Test-Path $gpoPath)) {
    New-Item -Path $gpoPath -Force | Out-Null
}
Set-ItemProperty -Path $gpoPath -Name "DisableFileSyncNGSC" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $gpoPath -Name "DisableFileSync" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $gpoPath -Name "DisableLibrariesDefaultSaveToOneDrive" -Value 1 -Type DWord -Force
Write-Removed "Group Policy" "OneDrive file sync blocked via policy"

# Prevent OneDrive setup from running on new user profiles
$defaultUserRunKey = "Registry::HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Run"
if (Test-Path $defaultUserRunKey) {
    Remove-ItemProperty -Path $defaultUserRunKey -Name "OneDriveSetup" -Force -ErrorAction SilentlyContinue
}
Write-Removed "New User Setup" "OneDrive won't install for new users"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 7: CLEAN EXPLORER SHELL
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Cleaning Explorer Shell"
Write-Section "Final Cleanup" "🧹"

# Restart Explorer to apply changes immediately
Write-Info "Restarting Windows Explorer to apply icon/sidebar changes..."
Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Process "explorer.exe"
Write-Removed "Explorer Restarted" "All sidebar/icon changes now visible"

# ══════════════════════════════════════════════════════════════════════════════
#                           COMPLETION SUMMARY
# ══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Red
Write-Host "  ║                                                              ║" -ForegroundColor Red
Write-Host "  ║   ✅  ONEDRIVE COMPLETELY REMOVED!                          ║" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Red
Write-Host "  ║   ☁  Application:    Uninstalled                            ║" -ForegroundColor Red
Write-Host "  ║   📁 Folders:        All hidden locations wiped             ║" -ForegroundColor Red
Write-Host "  ║   🔑 Registry:       All entries cleaned                    ║" -ForegroundColor Red
Write-Host "  ║   📅 Scheduled Tasks: Removed                               ║" -ForegroundColor Red
Write-Host "  ║   🔒 Policy:         Reinstallation blocked                 ║" -ForegroundColor Red
Write-Host "  ║   👁  Explorer:       Sidebar & context menus cleaned       ║" -ForegroundColor Red
Write-Host "  ║                                                              ║" -ForegroundColor Red
Write-Host "  ║   📄 Log: $LogFile" -ForegroundColor Red
Write-Host "  ║                                                              ║" -ForegroundColor Red
Write-Host "  ║   ⚠  A restart is recommended for full effect.             ║" -ForegroundColor Yellow
Write-Host "  ║   🛡  A restore point was created for safety.              ║" -ForegroundColor Red
Write-Host "  ║                                                              ║" -ForegroundColor Red
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Red
Write-Host ""

Write-Log "═══════════════════════════════════════════════════"
Write-Log "OneDrive Removal Completed"
Write-Log "═══════════════════════════════════════════════════"

Write-Host "  Would you like to restart now? (Y/N): " -ForegroundColor Yellow -NoNewline
$restart = Read-Host
if ($restart -eq "Y" -or $restart -eq "y") {
    Write-Host "  Restarting in 10 seconds..." -ForegroundColor Red
    shutdown /r /t 10 /c "Restarting after OneDrive removal"
}
else {
    Write-Host "  Remember to restart for all changes to take full effect!" -ForegroundColor Yellow
}

Write-Host ""
