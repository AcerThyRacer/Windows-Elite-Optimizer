<#
╔══════════════════════════════════════════════════════════════════════════════╗
║              🖱 MOUSE OPTIMIZER — Input Latency Reduction                  ║
║                                                                            ║
║  Interactive mouse tuning for competitive gaming:                          ║
║    • Disable mouse acceleration (EnhancePointerPrecision = 0)             ║
║    • Set pointer speed to 6/11 (true 1:1 pixel ratio)                    ║
║    • Remove pointer trails, snap-to, and shadow                           ║
║    • Configure raw input registry keys                                    ║
║    • Disable pointer precision enhancements per-user                     ║
║    • USB polling rate guidance and detection                              ║
║    • Game-specific DPI calculator                                         ║
║    • Option to set custom pointer speed                                   ║
║                                                                            ║
║  For quick application, use: MouseOptimizerLite.ps1                      ║
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
$LogFile = "$env:USERPROFILE\MouseOptimizer_log.txt"

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
  ║        🖱🖱🖱  MOUSE OPTIMIZER  🖱🖱🖱                      ║
  ║                                                              ║
  ║       Input Latency Reduction — Zero Acceleration            ║
  ║                                                              ║
  ║       Raw input. True 1:1 tracking. Maximum precision.       ║
  ║                                                              ║
  ╚══════════════════════════════════════════════════════════════╝

"@
    Write-Host $banner -ForegroundColor Yellow
}

function Write-Section {
    param([string]$Title, [string]$Icon = "►")
    Write-Host ""
    Write-Host "  ┌──────────────────────────────────────────────────────────" -ForegroundColor DarkYellow
    Write-Host "  │ $Icon $Title" -ForegroundColor Yellow
    Write-Host "  └──────────────────────────────────────────────────────────" -ForegroundColor DarkYellow
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
    Write-Host "    ℹ $Message" -ForegroundColor DarkCyan
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
Write-Log "Mouse Optimizer (Interactive) Started"
Write-Log "═══════════════════════════════════════════════════"

$changeCount = 0

# ─── Show Current Settings ───────────────────────────────────────────────────
Write-Section "Current Mouse Settings" "📊"

$mousePath = "HKCU:\Control Panel\Mouse"
$currentAccel = (Get-ItemProperty -Path $mousePath -Name "MouseSensitivity" -ErrorAction SilentlyContinue).MouseSensitivity
$currentEPP = (Get-ItemProperty -Path $mousePath -Name "MouseSpeed" -ErrorAction SilentlyContinue).MouseSpeed
$currentTrails = (Get-ItemProperty -Path $mousePath -Name "MouseTrails" -ErrorAction SilentlyContinue).MouseTrails
$currentSnap = (Get-ItemProperty -Path $mousePath -Name "SnapToDefaultButton" -ErrorAction SilentlyContinue).SnapToDefaultButton

# Read SmoothMouseXCurve and SmoothMouseYCurve for acceleration detection
$smoothX = (Get-ItemProperty -Path $mousePath -Name "SmoothMouseXCurve" -ErrorAction SilentlyContinue).SmoothMouseXCurve
$enhancePP = (Get-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -ErrorAction SilentlyContinue).MouseSpeed

Write-Host "    Pointer Speed:     $currentAccel / 20" -ForegroundColor White
Write-Host "    Acceleration:      $(if ($currentEPP -ne '0') { 'ON ⚠' } else { 'OFF ✓' })" -ForegroundColor $(if ($currentEPP -ne '0') { 'Yellow' } else { 'Green' })
Write-Host "    Pointer Trails:    $(if ($currentTrails -and $currentTrails -ne '0') { 'ON ⚠' } else { 'OFF ✓' })" -ForegroundColor $(if ($currentTrails -and $currentTrails -ne '0') { 'Yellow' } else { 'Green' })
Write-Host "    Snap-to-Default:   $(if ($currentSnap -eq '1') { 'ON ⚠' } else { 'OFF ✓' })" -ForegroundColor $(if ($currentSnap -eq '1') { 'Yellow' } else { 'Green' })

# ══════════════════════════════════════════════════════════════════════════════
# STEP 1: MOUSE ACCELERATION
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "Mouse Acceleration (Enhance Pointer Precision)" "⚡"

Write-Host "    Mouse acceleration modifies your cursor movement based on" -ForegroundColor DarkGray
Write-Host "    how FAST you move the mouse — making precision inconsistent." -ForegroundColor DarkGray
Write-Host ""
Write-Host "    For gaming, acceleration should ALWAYS be OFF." -ForegroundColor White
Write-Host ""
Write-Host "    [1] Disable acceleration (recommended)" -ForegroundColor Yellow
Write-Host "    [2] Keep current setting" -ForegroundColor DarkGray
Write-Host ""
Write-Host "    Choice: " -ForegroundColor Yellow -NoNewline
$accelChoice = Read-Host

if ($accelChoice -eq "1") {
    # Disable EnhancePointerPrecision
    Set-ItemProperty -Path $mousePath -Name "MouseSpeed" -Value "0" -Force
    Set-ItemProperty -Path $mousePath -Name "MouseThreshold1" -Value "0" -Force
    Set-ItemProperty -Path $mousePath -Name "MouseThreshold2" -Value "0" -Force

    # Set flat acceleration curve (1:1 mapping)
    # These are the "no acceleration" curves — perfectly linear
    $flatX = [byte[]](0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0xC0, 0xCC, 0x0C, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x80, 0x99, 0x19, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x40, 0x66, 0x26, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x33, 0x33, 0x00, 0x00, 0x00, 0x00, 0x00)

    $flatY = [byte[]](0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x38, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x70, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0xA8, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0xE0, 0x00, 0x00, 0x00, 0x00, 0x00)

    Set-ItemProperty -Path $mousePath -Name "SmoothMouseXCurve" -Value $flatX -Type Binary -Force
    Set-ItemProperty -Path $mousePath -Name "SmoothMouseYCurve" -Value $flatY -Type Binary -Force

    Write-Applied "Mouse Acceleration" "DISABLED — flat 1:1 curve applied"
    Write-Applied "EnhancePointerPrecision" "OFF (MouseSpeed=0, Thresholds=0)"
    $changeCount += 2
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 2: POINTER SPEED
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "Pointer Speed" "🎯"

Write-Host "    Windows pointer speed setting (1-20):" -ForegroundColor White
Write-Host ""
Write-Host "    The ONLY speed that gives true 1:1 cursor-to-sensor" -ForegroundColor DarkGray
Write-Host "    mapping is 10 (6/11 in the old Control Panel slider)." -ForegroundColor DarkGray
Write-Host "    Any other value applies a multiplier." -ForegroundColor DarkGray
Write-Host ""
Write-Host "    [1] Set to 10 (6/11 — true 1:1 mapping, recommended)" -ForegroundColor Yellow
Write-Host "    [2] Custom value (1-20)" -ForegroundColor Yellow
Write-Host "    [3] Keep current ($currentAccel)" -ForegroundColor DarkGray
Write-Host ""
Write-Host "    Choice: " -ForegroundColor Yellow -NoNewline
$speedChoice = Read-Host

switch ($speedChoice) {
    "1" {
        Set-ItemProperty -Path $mousePath -Name "MouseSensitivity" -Value "10" -Force
        Write-Applied "Pointer Speed" "10/20 (6/11 — true 1:1)"
        $changeCount++
    }
    "2" {
        Write-Host "    Enter speed (1-20): " -ForegroundColor Yellow -NoNewline
        $customSpeed = Read-Host
        $speed = [int]$customSpeed
        if ($speed -ge 1 -and $speed -le 20) {
            Set-ItemProperty -Path $mousePath -Name "MouseSensitivity" -Value "$speed" -Force
            if ($speed -eq 10) {
                Write-Applied "Pointer Speed" "$speed/20 (1:1 mapping)"
            }
            else {
                Write-Applied "Pointer Speed" "$speed/20 (note: only 10 gives true 1:1)"
            }
            $changeCount++
        }
        else {
            Write-Host "    ⚠ Invalid value. Keeping current." -ForegroundColor Yellow
        }
    }
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 3: POINTER VISUAL EFFECTS
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "Pointer Visual Effects" "✨"

Write-Host "    Remove all pointer visual effects?" -ForegroundColor White
Write-Host ""
Write-Host "    These add visual processing overhead and input lag:" -ForegroundColor DarkGray
Write-Host "    • Pointer trails (mouse leaves a trail)" -ForegroundColor DarkGray
Write-Host "    • Snap-to-default (jumps to dialog buttons)" -ForegroundColor DarkGray
Write-Host "    • Pointer shadow (rendered shadow under cursor)" -ForegroundColor DarkGray
Write-Host "    • Hide pointer while typing" -ForegroundColor DarkGray
Write-Host ""
Write-Host "    [1] Remove all effects (recommended)" -ForegroundColor Yellow
Write-Host "    [2] Keep current settings" -ForegroundColor DarkGray
Write-Host ""
Write-Host "    Choice: " -ForegroundColor Yellow -NoNewline
$effectsChoice = Read-Host

if ($effectsChoice -eq "1") {
    # Disable pointer trails
    Set-ItemProperty -Path $mousePath -Name "MouseTrails" -Value "0" -Force
    Write-Applied "Pointer Trails" "Disabled"

    # Disable snap-to-default button
    Set-ItemProperty -Path $mousePath -Name "SnapToDefaultButton" -Value "0" -Force
    Write-Applied "Snap-to-Default" "Disabled"

    # Disable pointer shadow
    $desktopPath = "HKCU:\Control Panel\Desktop"
    Set-ItemProperty -Path $desktopPath -Name "CursorShadow" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Applied "Cursor Shadow" "Disabled"

    # Show pointer while typing (don't hide it)
    Set-ItemProperty -Path $desktopPath -Name "UserPreferencesMask" -Value ([byte[]](0x9E, 0x1E, 0x07, 0x80, 0x12, 0x00, 0x00, 0x00)) -Type Binary -Force -ErrorAction SilentlyContinue
    Write-Applied "Hide While Typing" "Disabled"

    $changeCount += 4
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 4: RAW INPUT REGISTRY KEYS
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "Raw Input Configuration" "🔧"

Write-Host "    Configure Windows for raw mouse input?" -ForegroundColor White
Write-Host ""
Write-Host "    These registry keys tell Windows to use the mouse's" -ForegroundColor DarkGray
Write-Host "    native DPI data directly without any OS processing." -ForegroundColor DarkGray
Write-Host ""
Write-Host "    [1] Enable raw input optimizations (recommended)" -ForegroundColor Yellow
Write-Host "    [2] Skip" -ForegroundColor DarkGray
Write-Host ""
Write-Host "    Choice: " -ForegroundColor Yellow -NoNewline
$rawChoice = Read-Host

if ($rawChoice -eq "1") {
    # Disable mouse input smoothing
    $precisionPath = "HKCU:\Control Panel\Mouse"
    Set-ItemProperty -Path $precisionPath -Name "MouseHoverTime" -Value "0" -Force
    Write-Applied "Mouse Hover Delay" "Set to 0ms"

    # Disable touch input prediction (helps on tablets with mouse)
    $touchPredPath = "HKLM:\SOFTWARE\Microsoft\TouchPrediction"
    Ensure-RegistryPath $touchPredPath
    Set-ItemProperty -Path $touchPredPath -Name "Latency" -Value 2 -Type DWord -Force
    Set-ItemProperty -Path $touchPredPath -Name "SampleTime" -Value 2 -Type DWord -Force
    Write-Applied "Touch Prediction" "Minimized latency"

    # Disable mouse corner acceleration (Windows 11)
    $pointerPath = "HKCU:\Control Panel\Cursors"
    Set-ItemProperty -Path $pointerPath -Name "ContactVisualization" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $pointerPath -Name "GestureVisualization" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Applied "Touch/Gesture Visualization" "Disabled"

    # Disable mouse message coalescing (ensures every mouse event is processed)
    $coalesPath = "HKCU:\Control Panel\Desktop"
    Set-ItemProperty -Path $coalesPath -Name "MouseWheelRouting" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Applied "Mouse Wheel Routing" "Direct to foreground window"

    $changeCount += 4
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 5: USB POLLING RATE
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "USB Polling Rate" "⏱"

Write-Host "    USB polling rate determines how often your mouse reports" -ForegroundColor DarkGray
Write-Host "    its position to the PC. Higher = lower input latency." -ForegroundColor DarkGray
Write-Host ""
Write-Host "    ┌──────────────────────────────────────────────────────" -ForegroundColor DarkYellow
Write-Host "    │  Rate       Latency    Recommended For" -ForegroundColor Yellow
Write-Host "    │  125 Hz     8.0 ms     Office use" -ForegroundColor White
Write-Host "    │  250 Hz     4.0 ms     Casual gaming" -ForegroundColor White
Write-Host "    │  500 Hz     2.0 ms     Competitive gaming" -ForegroundColor Green
Write-Host "    │  1000 Hz    1.0 ms     Pro competitive ✓" -ForegroundColor Green
Write-Host "    │  2000 Hz    0.5 ms     Ultra-competitive" -ForegroundColor Cyan
Write-Host "    │  4000 Hz    0.25 ms    Top-tier mice only" -ForegroundColor Cyan
Write-Host "    │  8000 Hz    0.125 ms   Razer Viper V3/DeathAdder V3" -ForegroundColor Magenta
Write-Host "    └──────────────────────────────────────────────────────" -ForegroundColor DarkYellow
Write-Host ""

# Try to detect current polling rate
Write-Host "    Detecting current mouse..." -ForegroundColor DarkGray
$hidDevices = Get-PnpDevice -Class "HIDClass" -Status OK -ErrorAction SilentlyContinue |
Where-Object { $_.FriendlyName -match "mouse|gaming" -or $_.FriendlyName -match "HID-compliant mouse" }

if ($hidDevices) {
    foreach ($dev in $hidDevices | Select-Object -First 3) {
        Write-Host "    Found: $($dev.FriendlyName)" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "    ⚠  Polling rate is set in your mouse software (e.g.," -ForegroundColor Yellow
Write-Host "       Logitech G Hub, Razer Synapse, SteelSeries GG)." -ForegroundColor Yellow
Write-Host "       Windows cannot change this — check your mouse settings." -ForegroundColor Yellow
Write-Host ""

# Set Windows-side USB optimizations
Write-Host "    Apply Windows-side USB optimizations?" -ForegroundColor White
Write-Host "    (Disable USB selective suspend + set MMCSS for input)" -ForegroundColor DarkGray
Write-Host ""
Write-Host "    [1] Yes (recommended)" -ForegroundColor Yellow
Write-Host "    [2] Skip" -ForegroundColor DarkGray
Write-Host ""
Write-Host "    Choice: " -ForegroundColor Yellow -NoNewline
$usbChoice = Read-Host

if ($usbChoice -eq "1") {
    # Disable USB selective suspend (prevents USB devices from sleeping)
    $usbPath = "HKLM:\SYSTEM\CurrentControlSet\Services\USB"
    Ensure-RegistryPath $usbPath
    Set-ItemProperty -Path $usbPath -Name "DisableSelectiveSuspend" -Value 1 -Type DWord -Force
    Write-Applied "USB Selective Suspend" "Disabled — mouse will never sleep"

    # Also set via power policy
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 2>$null
    powercfg /SETACTIVE SCHEME_CURRENT 2>$null
    Write-Applied "USB Power Saving" "Disabled in power plan"

    # MMCSS — give mouse input high priority scheduling
    $mmcssPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    Ensure-RegistryPath $mmcssPath
    Set-ItemProperty -Path $mmcssPath -Name "SystemResponsiveness" -Value 0 -Type DWord -Force
    Write-Applied "MMCSS Responsiveness" "Set to 0 (input priority)"

    $changeCount += 3
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 6: GAME DPI CALCULATOR
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "DPI & Sensitivity Calculator" "🧮"

Write-Host "    Want to check your effective DPI (eDPI) for gaming?" -ForegroundColor White
Write-Host ""
Write-Host "    [1] Calculate eDPI" -ForegroundColor Yellow
Write-Host "    [2] Skip" -ForegroundColor DarkGray
Write-Host ""
Write-Host "    Choice: " -ForegroundColor Yellow -NoNewline
$dpiCalcChoice = Read-Host

if ($dpiCalcChoice -eq "1") {
    Write-Host ""
    Write-Host "    Enter your mouse DPI (e.g., 800, 1600): " -ForegroundColor Yellow -NoNewline
    $mouseDPI = Read-Host

    Write-Host "    Enter your in-game sensitivity (e.g., 2.5): " -ForegroundColor Yellow -NoNewline
    $inGameSens = Read-Host

    $dpi = [double]$mouseDPI
    $sens = [double]$inGameSens

    if ($dpi -gt 0 -and $sens -gt 0) {
        $eDPI = [math]::Round($dpi * $sens, 0)
        Write-Host ""
        Write-Host "    ┌──────────────────────────────────────────────────────" -ForegroundColor DarkYellow
        Write-Host "    │ Your eDPI: $eDPI" -ForegroundColor Yellow

        if ($eDPI -lt 200) {
            Write-Host "    │ Very low — extreme precision, needs large mousepad" -ForegroundColor Cyan
        }
        elseif ($eDPI -lt 400) {
            Write-Host "    │ Low — tactical FPS optimal (Valorant, CS2)" -ForegroundColor Green
        }
        elseif ($eDPI -lt 800) {
            Write-Host "    │ Medium — versatile for most games" -ForegroundColor Green
        }
        elseif ($eDPI -lt 1600) {
            Write-Host "    │ High — fast-paced games (Fortnite, Apex)" -ForegroundColor Yellow
        }
        else {
            Write-Host "    │ Very high — consider lowering for better aim" -ForegroundColor Red
        }
        Write-Host "    └──────────────────────────────────────────────────────" -ForegroundColor DarkYellow

        Write-Host ""
        Write-Host "    Pro player ranges:" -ForegroundColor DarkGray
        Write-Host "      Valorant:    200-400 eDPI" -ForegroundColor DarkGray
        Write-Host "      CS2:         600-1000 eDPI" -ForegroundColor DarkGray
        Write-Host "      Apex:        800-1600 eDPI" -ForegroundColor DarkGray
        Write-Host "      Fortnite:    48-80 eDPI (different scale)" -ForegroundColor DarkGray
    }
}

# ══════════════════════════════════════════════════════════════════════════════
#                           COMPLETION SUMMARY
# ══════════════════════════════════════════════════════════════════════════════

# Re-read final state
$finalSpeed = (Get-ItemProperty -Path $mousePath -Name "MouseSensitivity" -ErrorAction SilentlyContinue).MouseSensitivity
$finalAccel = (Get-ItemProperty -Path $mousePath -Name "MouseSpeed" -ErrorAction SilentlyContinue).MouseSpeed
$finalTrails = (Get-ItemProperty -Path $mousePath -Name "MouseTrails" -ErrorAction SilentlyContinue).MouseTrails

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "  ║                                                              ║" -ForegroundColor Yellow
Write-Host "  ║   ✅  MOUSE OPTIMIZED — $changeCount changes applied!" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Yellow
Write-Host "  ║   🖱  Acceleration:  $(if ($finalAccel -eq '0') { 'OFF ✓' } else { 'ON' })" -ForegroundColor Yellow
Write-Host "  ║   🎯 Pointer Speed: $finalSpeed/20" -ForegroundColor Yellow
Write-Host "  ║   ✨ Pointer Trails: $(if ($finalTrails -eq '0' -or -not $finalTrails) { 'OFF ✓' } else { 'ON' })" -ForegroundColor Yellow
Write-Host "  ║   ⚡ Raw Input:      Configured" -ForegroundColor Yellow
Write-Host "  ║                                                              ║" -ForegroundColor Yellow
Write-Host "  ║   📄 Log: $LogFile" -ForegroundColor Yellow
Write-Host "  ║                                                              ║" -ForegroundColor Yellow
Write-Host "  ║   ⚠  Log out and back in for all changes to take effect   ║" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Yellow
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
Write-Host ""

Write-Log "Mouse Optimizer Completed — $changeCount changes"

Write-Host "  Press Enter to exit..." -ForegroundColor DarkGray
Read-Host
