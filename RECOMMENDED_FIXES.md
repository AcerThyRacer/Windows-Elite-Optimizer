# Recommended Code Fixes

This document provides ready-to-use code snippets to fix the critical bugs identified in the review.

---

## Fix #1: Windows 11 Version Validation

**Add this function to every script after the admin elevation check:**

```powershell
# ─── Windows 11 Validation ────────────────────────────────────────────────────
function Test-Windows11Compatibility {
    try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        $buildNumber = [int]($os.BuildNumber)
        $caption = $os.Caption

        Write-Host "`n[System Check]" -ForegroundColor Cyan
        Write-Host "  OS: $caption" -ForegroundColor DarkGray
        Write-Host "  Build: $buildNumber" -ForegroundColor DarkGray

        # Check if Windows 11 (build 22000+)
        if ($buildNumber -lt 22000) {
            Write-Host "`n[!] ERROR: This script requires Windows 11" -ForegroundColor Red
            Write-Host "    Your build: $buildNumber (Windows 10 or earlier)" -ForegroundColor Yellow
            Write-Host "    Required: Build 22000 or higher (Windows 11)" -ForegroundColor Yellow
            Write-Host "`nPress Enter to exit..."
            Read-Host
            exit 1
        }

        # Check for Windows 11 in caption
        if ($caption -notlike "*Windows 11*") {
            Write-Host "`n[!] WARNING: OS name doesn't contain 'Windows 11'" -ForegroundColor Yellow
            Write-Host "    Detected: $caption" -ForegroundColor Yellow
            $confirm = Read-Host "    Continue anyway? (y/N)"
            if ($confirm -ne 'y') {
                exit 0
            }
        }

        # Detect edition
        $edition = $os.OperatingSystemSKU
        $editionName = switch ($edition) {
            48 { "Professional" }
            49 { "Professional N" }
            4  { "Enterprise" }
            27 { "Enterprise N" }
            101 { "Home" }
            98 { "Home N" }
            default { "Unknown ($edition)" }
        }
        Write-Host "  Edition: $editionName" -ForegroundColor DarkGray

        # Warn if Home edition (some features may not work)
        if ($edition -in @(101, 98)) {
            Write-Host "`n[!] Note: Windows 11 Home detected" -ForegroundColor Yellow
            Write-Host "    Some enterprise features may not be available." -ForegroundColor DarkGray
        }

        Write-Host "  [✓] Windows 11 compatibility confirmed`n" -ForegroundColor Green
        return $true

    } catch {
        Write-Host "`n[!] ERROR: Could not verify Windows version" -ForegroundColor Red
        Write-Host "    $_" -ForegroundColor Yellow
        Write-Host "`nPress Enter to exit..."
        Read-Host
        exit 1
    }
}

# Call immediately after admin elevation:
Test-Windows11Compatibility
```

---

## Fix #2: Replace Global Error Suppression

**REMOVE this line from all scripts:**
```powershell
$ErrorActionPreference = "SilentlyContinue"  # ❌ DELETE THIS
```

**REPLACE with:**
```powershell
$ErrorActionPreference = "Stop"  # ✅ Fail fast on errors
```

**Then use targeted suppression only where truly needed:**
```powershell
# Example: Optional operations that may not exist
$service = Get-Service -Name "OptionalService" -ErrorAction SilentlyContinue
if ($service) {
    # Service exists, do something
}

# Example: Registry keys that may not exist
Set-ItemProperty -Path $path -Name $name -Value $value -ErrorAction SilentlyContinue
```

---

## Fix #3: Registry Backup Function

**Add this function to all scripts that modify registry:**

```powershell
# ─── Registry Backup ──────────────────────────────────────────────────────────
$script:RegistryBackups = @()

function Backup-RegistryKey {
    param(
        [string]$Path,
        [string]$Name
    )

    try {
        # Create backup directory
        $backupDir = "$env:USERPROFILE\WindowsEliteOptimizer_Backups"
        if (-not (Test-Path $backupDir)) {
            New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
        }

        # Generate backup filename
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $safeName = $Name -replace '[^\w\-]', '_'
        $backupFile = "$backupDir\${safeName}_${timestamp}.reg"

        # Check if registry path exists
        if (Test-Path $Path) {
            # Export registry key
            $process = Start-Process -FilePath "reg.exe" -ArgumentList "export `"$Path`" `"$backupFile`" /y" -Wait -PassThru -NoNewWindow

            if ($process.ExitCode -eq 0 -and (Test-Path $backupFile)) {
                Write-Host "  [✓] Backed up: $Name" -ForegroundColor Green
                Write-Host "      Location: $backupFile" -ForegroundColor DarkGray
                $script:RegistryBackups += $backupFile
                return $backupFile
            } else {
                Write-Host "  [!] Warning: Could not backup $Name" -ForegroundColor Yellow
                return $null
            }
        } else {
            Write-Host "  [i] Registry path does not exist: $Name" -ForegroundColor DarkGray
            return $null
        }
    } catch {
        Write-Host "  [!] Warning: Backup failed for $Name - $_" -ForegroundColor Yellow
        return $null
    }
}

function Show-BackupSummary {
    if ($script:RegistryBackups.Count -gt 0) {
        Write-Host "`n[Registry Backups Created: $($script:RegistryBackups.Count)]" -ForegroundColor Cyan
        Write-Host "  Location: $env:USERPROFILE\WindowsEliteOptimizer_Backups" -ForegroundColor DarkGray
        Write-Host "  You can restore these .reg files by double-clicking them." -ForegroundColor DarkGray
    }
}

# Usage before making changes:
Write-Host "`n[Creating Registry Backups]" -ForegroundColor Cyan
Backup-RegistryKey "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "NetworkSettings"
Backup-RegistryKey "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "MemoryManagement"
Backup-RegistryKey "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "MultimediaProfile"

# At end of script:
Show-BackupSummary
```

---

## Fix #4: Safe Service Disabling

**Replace simple service disabling with this function:**

```powershell
# ─── Safe Service Management ──────────────────────────────────────────────────
function Disable-ServiceSafely {
    param(
        [string]$ServiceName,
        [string]$Description,
        [string]$ImpactWarning = $null,
        [bool]$RequireConfirmation = $false
    )

    try {
        # Check if service exists
        $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        if (-not $service) {
            Write-Host "  [-] $Description - Not found" -ForegroundColor DarkGray
            return $false
        }

        # Check if already disabled
        if ($service.StartType -eq 'Disabled') {
            Write-Host "  [i] $Description - Already disabled" -ForegroundColor DarkGray
            return $true
        }

        # Check for dependent services
        $dependents = Get-Service -DependentServices -InputObject $service |
                      Where-Object { $_.Status -eq 'Running' }

        if ($dependents) {
            Write-Host "  [!] Cannot disable $Description - has running dependents:" -ForegroundColor Yellow
            foreach ($dep in $dependents) {
                Write-Host "      • $($dep.DisplayName)" -ForegroundColor DarkGray
            }
            return $false
        }

        # Show warning if provided
        if ($ImpactWarning) {
            Write-Host "`n  [!] $Description" -ForegroundColor Yellow
            Write-Host "      WARNING: $ImpactWarning" -ForegroundColor Red
        }

        # Ask for confirmation if required
        if ($RequireConfirmation) {
            $confirm = Read-Host "      Disable this service? (y/N)"
            if ($confirm -ne 'y') {
                Write-Host "      Skipped by user" -ForegroundColor DarkGray
                return $false
            }
        }

        # Stop and disable service
        if ($service.Status -eq 'Running') {
            Stop-Service -Name $ServiceName -Force -ErrorAction Stop
        }
        Set-Service -Name $ServiceName -StartupType Disabled -ErrorAction Stop

        Write-Host "  [✓] Disabled: $Description" -ForegroundColor Green
        return $true

    } catch {
        Write-Host "  [✗] Failed to disable $Description - $_" -ForegroundColor Red
        return $false
    }
}

# Usage examples:
Write-Host "`n[Service Optimization]" -ForegroundColor Cyan

# Critical services that need warning:
Disable-ServiceSafely "WSearch" "Windows Search" `
    -ImpactWarning "This will break Start Menu search and File Explorer search!" `
    -RequireConfirmation $true

# Services safe to disable:
Disable-ServiceSafely "SysMain" "Superfetch/Prefetch (not needed on SSD)"
Disable-ServiceSafely "DiagTrack" "Diagnostic Tracking (telemetry)"
```

---

## Fix #5: Graceful Process Termination

**Replace `Stop-Process -Force` with this function:**

```powershell
# ─── Safe Process Management ──────────────────────────────────────────────────
function Stop-ProcessGracefully {
    param(
        [string]$ProcessName,
        [string]$Description,
        [bool]$WarnDataLoss = $true,
        [int]$GracePeriodSeconds = 5
    )

    try {
        $processes = @(Get-Process -Name $ProcessName -ErrorAction SilentlyContinue)
        if ($processes.Count -eq 0) {
            return $true  # Not running, nothing to do
        }

        Write-Host "`n  [!] Found running: $Description ($($processes.Count) instance(s))" -ForegroundColor Yellow

        if ($WarnDataLoss) {
            Write-Host "      WARNING: Closing this may result in unsaved data loss!" -ForegroundColor Red
            $confirm = Read-Host "      Continue? (y/N)"
            if ($confirm -ne 'y') {
                return $false
            }
        }

        # Try graceful close first
        Write-Host "      Attempting graceful close..." -ForegroundColor DarkGray
        foreach ($proc in $processes) {
            try {
                if (-not $proc.HasExited) {
                    $proc.CloseMainWindow() | Out-Null
                }
            } catch {
                # Process may not have a main window
            }
        }

        # Wait for processes to exit
        Start-Sleep -Seconds $GracePeriodSeconds
        $processes = @(Get-Process -Name $ProcessName -ErrorAction SilentlyContinue)

        # Force kill if still running
        if ($processes.Count -gt 0) {
            Write-Host "      Force closing remaining processes..." -ForegroundColor Yellow
            foreach ($proc in $processes) {
                try {
                    Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
                } catch {
                    # Already exited
                }
            }
        }

        Write-Host "  [✓] Closed: $Description" -ForegroundColor Green
        return $true

    } catch {
        Write-Host "  [!] Warning: Could not close $Description - $_" -ForegroundColor Yellow
        return $false
    }
}

# Usage examples:
Write-Host "`n[Closing Background Processes]" -ForegroundColor Cyan

Stop-ProcessGracefully "msedge" "Microsoft Edge" -WarnDataLoss $true
Stop-ProcessGracefully "chrome" "Google Chrome" -WarnDataLoss $true
Stop-ProcessGracefully "Discord" "Discord" -WarnDataLoss $true
Stop-ProcessGracefully "Spotify" "Spotify" -WarnDataLoss $false  # Less critical
```

---

## Fix #6: BCDEDIT with Validation

**For ElitePerformance.ps1, replace lines 414-415:**

```powershell
# ─── Boot Configuration (BCDEDIT) ─────────────────────────────────────────────
function Set-BootConfig {
    param(
        [string]$Setting,
        [string]$Value,
        [string]$Description
    )

    try {
        $result = bcdedit /set $Setting $Value 2>&1
        $exitCode = $LASTEXITCODE

        if ($exitCode -eq 0) {
            Write-Host "  [✓] $Description" -ForegroundColor Green
            return $true
        } else {
            Write-Host "  [✗] Failed: $Description" -ForegroundColor Red
            Write-Host "      Error: $result" -ForegroundColor DarkGray
            return $false
        }
    } catch {
        Write-Host "  [✗] Failed: $Description - $_" -ForegroundColor Red
        return $false
    }
}

Write-Host "`n[Boot Configuration]" -ForegroundColor Cyan
Write-Host "  These settings modify boot behavior for performance." -ForegroundColor DarkGray
Write-Host "`n  [!] WARNING: Boot configuration changes can cause boot failures on some hardware!" -ForegroundColor Yellow
Write-Host "      If your system won't boot after this, use Advanced Startup and run:" -ForegroundColor Yellow
Write-Host "      bcdedit /deletevalue useplatformtick" -ForegroundColor DarkGray
Write-Host "      bcdedit /deletevalue disabledynamictick" -ForegroundColor DarkGray
Write-Host "`n  Apply boot configuration changes? (y/N): " -NoNewline -ForegroundColor Yellow

$confirm = Read-Host

if ($confirm -eq 'y') {
    Set-BootConfig "useplatformtick" "yes" "Platform Clock Tick"
    Set-BootConfig "disabledynamictick" "yes" "Dynamic Tick Disabled"
} else {
    Write-Host "  [i] Boot configuration changes skipped" -ForegroundColor DarkGray
}
```

---

## Fix #7: PowerCFG GUID Validation

**For ElitePerformance.ps1 and ProPerformance.ps1, replace power plan creation:**

```powershell
# ─── Power Plan Creation ──────────────────────────────────────────────────────
function New-CustomPowerPlan {
    param(
        [string]$PlanName,
        [string]$PreferredGuid,
        [string]$SourceGuid,
        [string]$FallbackGuid
    )

    try {
        Write-Host "`n[Creating Power Plan: $PlanName]" -ForegroundColor Cyan

        # Check if GUID already in use
        $existingPlan = powercfg /list | Select-String -Pattern $PreferredGuid
        if ($existingPlan) {
            Write-Host "  [!] Power plan with GUID already exists" -ForegroundColor Yellow

            # Generate new unique GUID
            $newGuid = [guid]::NewGuid().ToString()
            Write-Host "  [i] Using new GUID: $newGuid" -ForegroundColor DarkGray
            $PreferredGuid = $newGuid
        }

        # Try to duplicate from source (Ultimate Performance)
        Write-Host "  [i] Attempting to create from Ultimate Performance..." -ForegroundColor DarkGray
        powercfg /duplicatescheme $SourceGuid $PreferredGuid 2>$null

        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [✓] Power plan created successfully" -ForegroundColor Green
        } else {
            # Fallback to High Performance
            Write-Host "  [i] Ultimate Performance not available, using High Performance..." -ForegroundColor DarkGray
            powercfg /duplicatescheme $FallbackGuid $PreferredGuid 2>$null

            if ($LASTEXITCODE -eq 0) {
                Write-Host "  [✓] Power plan created from High Performance" -ForegroundColor Green
            } else {
                throw "Failed to create power plan from both sources"
            }
        }

        # Set the name
        powercfg /changename $PreferredGuid $PlanName 2>$null

        # Activate it
        powercfg /setactive $PreferredGuid 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [✓] Power plan activated" -ForegroundColor Green
        } else {
            Write-Host "  [!] Warning: Could not activate power plan" -ForegroundColor Yellow
        }

        return $PreferredGuid

    } catch {
        Write-Host "  [✗] Failed to create power plan: $_" -ForegroundColor Red
        return $null
    }
}

# Usage:
$planGuid = New-CustomPowerPlan `
    -PlanName "⚡ ELITE Performance" `
    -PreferredGuid "e9a42b02-d5df-448d-aa00-03f14749eb61" `
    -SourceGuid "e9a42b02-d5df-448d-aa00-03f14749eb00" `
    -FallbackGuid "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
```

---

## Fix #8: Verify Restore Point Creation

**Add this function to scripts that create restore points:**

```powershell
# ─── System Restore Point ─────────────────────────────────────────────────────
function New-VerifiedRestorePoint {
    param([string]$Description)

    Write-Host "`n[System Restore Point]" -ForegroundColor Cyan
    Write-Host "  Creating restore point: $Description" -ForegroundColor DarkGray

    try {
        # Enable restore for C: drive
        Enable-ComputerRestore -Drive "C:\" -ErrorAction Stop

        # Create restore point
        Checkpoint-Computer -Description $Description -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop

        # Wait a moment for it to be created
        Start-Sleep -Seconds 5

        # Verify it was created
        $restorePoints = Get-ComputerRestorePoint -ErrorAction Stop
        $latest = $restorePoints |
                  Where-Object { $_.Description -eq $Description } |
                  Sort-Object CreationTime -Descending |
                  Select-Object -First 1

        if ($latest) {
            Write-Host "  [✓] Restore point created successfully" -ForegroundColor Green
            Write-Host "      Time: $($latest.CreationTime)" -ForegroundColor DarkGray
            Write-Host "      Sequence: $($latest.SequenceNumber)" -ForegroundColor DarkGray
            return $true
        } else {
            throw "Restore point not found after creation"
        }

    } catch {
        Write-Host "  [✗] Could not create restore point" -ForegroundColor Red
        Write-Host "      Reason: $_" -ForegroundColor DarkGray

        Write-Host "`n  [!] This script makes system changes that are difficult to reverse!" -ForegroundColor Yellow
        Write-Host "      Please create a restore point manually:" -ForegroundColor Yellow
        Write-Host "      1. Search 'Create a restore point' in Start Menu" -ForegroundColor DarkGray
        Write-Host "      2. Click 'Create' button" -ForegroundColor DarkGray
        Write-Host "      3. Enter: $Description" -ForegroundColor DarkGray
        Write-Host "`n  Continue without restore point? (y/N): " -NoNewline -ForegroundColor Yellow

        $confirm = Read-Host
        if ($confirm -ne 'y') {
            Write-Host "`n  Script cancelled. Create restore point and run again." -ForegroundColor Yellow
            exit 0
        }

        return $false
    }
}

# Usage:
New-VerifiedRestorePoint "Before Elite Performance Optimization"
```

---

## Fix #9: Fix Empty Catch Blocks

**Replace empty catch blocks throughout scripts:**

```powershell
# ❌ BAD - Empty catch:
try {
    $proc.MinWorkingSet = $proc.MinWorkingSet
} catch { }

# ✅ GOOD - Informative catch:
try {
    $proc.MinWorkingSet = $proc.MinWorkingSet
} catch [System.InvalidOperationException] {
    # Process exited - this is expected sometimes
} catch {
    Write-Host "  [!] Warning: Could not trim memory for PID $($proc.Id) - $_" -ForegroundColor Yellow
}
```

---

## Fix #10: Fix Race Conditions

**For GameBooster.ps1 and similar scripts:**

```powershell
# ❌ BAD - Race condition:
$proc = Get-Process -Id $process.Id -ErrorAction SilentlyContinue
if ($proc) {
    $proc.MinWorkingSet = $proc.MinWorkingSet  # Process may have exited!
}

# ✅ GOOD - Check before each operation:
$proc = Get-Process -Id $process.Id -ErrorAction SilentlyContinue
if ($proc -and -not $proc.HasExited) {
    try {
        $proc.Refresh()  # Update process information

        if (-not $proc.HasExited) {
            $proc.MinWorkingSet = $proc.MinWorkingSet
        }
    } catch [System.InvalidOperationException] {
        # Process exited during operation - this can happen
        Write-Host "    Process exited during optimization" -ForegroundColor DarkGray
    } catch {
        Write-Host "    Warning: Could not optimize process - $_" -ForegroundColor Yellow
    }
}
```

---

## Implementation Priority

Apply these fixes in order:

1. **Fix #1** (Windows 11 validation) - 5 minutes per script
2. **Fix #2** (Error handling) - 2 minutes per script
3. **Fix #3** (Registry backup) - 10 minutes per script
4. **Fix #4** (Service safety) - 15 minutes for affected scripts
5. **Fix #5** (Process safety) - 10 minutes for affected scripts
6. **Fix #6** (BCDEDIT) - 5 minutes for ElitePerformance.ps1
7. **Fix #7** (PowerCFG) - 10 minutes for Elite/Pro Performance
8. **Fix #8** (Restore points) - 10 minutes for affected scripts
9. **Fix #9** (Catch blocks) - 15 minutes for all scripts
10. **Fix #10** (Race conditions) - 10 minutes for GameBooster.ps1

**Total estimated time: 8-12 hours for all scripts**

---

## Testing After Fixes

After applying fixes, test each script on:
- ✅ Clean Windows 11 VM
- ✅ Windows 11 with existing modifications
- ✅ Windows 10 VM (should reject with error message)
- ✅ Low-privilege account (should request elevation)
- ✅ System with target software not installed (OneDrive, Outlook)

**Verify:**
- [ ] Script shows clear OS validation
- [ ] Errors are visible and descriptive
- [ ] Registry backups are created
- [ ] User is warned before dangerous operations
- [ ] Script completes without crashes
- [ ] System remains stable after reboot

---

**End of Fixes Document**
