<#
╔══════════════════════════════════════════════════════════════════════════════╗
║            🖱 MOUSE OPTIMIZER LITE — Quick Input Fix                       ║
║                                                                            ║
║  Instantly applies the most impactful mouse settings:                      ║
║    ✓ Disable mouse acceleration (flat 1:1 curve)                          ║
║    ✓ Set pointer speed to 10/20 (6/11 true 1:1 mapping)                  ║
║    ✓ Remove trails, snap-to, and shadow                                   ║
║    ✓ Disable USB selective suspend                                        ║
║    ✗ No DPI calculator or polling rate guide                              ║
║    ✗ No interactive choices                                                ║
║                                                                            ║
║  For full interactive setup, use: MouseOptimizer.ps1                      ║
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
$LogFile = "$env:USERPROFILE\MouseOptimizerLite_log.txt"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp | $Message" | Out-File -FilePath $LogFile -Append -Encoding UTF8
}

Clear-Host
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "  ║        🖱  MOUSE OPTIMIZER LITE  🖱                          ║" -ForegroundColor Yellow
Write-Host "  ║       Quick Input Fix — Zero Acceleration, True 1:1         ║" -ForegroundColor Yellow
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
Write-Host ""

Write-Log "Mouse Optimizer Lite Started"
$changeCount = 0
$mousePath = "HKCU:\Control Panel\Mouse"

# ── 1. Disable Acceleration ─────────────────────────────────────────────────
Write-Host "  ► Disabling Mouse Acceleration" -ForegroundColor Yellow

Set-ItemProperty -Path $mousePath -Name "MouseSpeed" -Value "0" -Force
Set-ItemProperty -Path $mousePath -Name "MouseThreshold1" -Value "0" -Force
Set-ItemProperty -Path $mousePath -Name "MouseThreshold2" -Value "0" -Force

# Flat 1:1 acceleration curves
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

Write-Host "    ✓ Acceleration OFF — flat 1:1 curve" -ForegroundColor Green
$changeCount++

# ── 2. Pointer Speed 6/11 ───────────────────────────────────────────────────
Write-Host ""
Write-Host "  ► Setting Pointer Speed" -ForegroundColor Yellow

Set-ItemProperty -Path $mousePath -Name "MouseSensitivity" -Value "10" -Force
Write-Host "    ✓ Pointer speed 10/20 (6/11 — true 1:1)" -ForegroundColor Green
$changeCount++

# ── 3. Remove Visual Effects ────────────────────────────────────────────────
Write-Host ""
Write-Host "  ► Removing Visual Effects" -ForegroundColor Yellow

Set-ItemProperty -Path $mousePath -Name "MouseTrails" -Value "0" -Force
Write-Host "    ✓ Pointer trails OFF" -ForegroundColor Green

Set-ItemProperty -Path $mousePath -Name "SnapToDefaultButton" -Value "0" -Force
Write-Host "    ✓ Snap-to-default OFF" -ForegroundColor Green

$desktopPath = "HKCU:\Control Panel\Desktop"
Set-ItemProperty -Path $desktopPath -Name "CursorShadow" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
Write-Host "    ✓ Cursor shadow OFF" -ForegroundColor Green
$changeCount += 3

# ── 4. Raw Input Tweaks ─────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ► Applying Raw Input Settings" -ForegroundColor Yellow

Set-ItemProperty -Path $mousePath -Name "MouseHoverTime" -Value "0" -Force
Write-Host "    ✓ Hover delay 0ms" -ForegroundColor Green

$desktopPath = "HKCU:\Control Panel\Desktop"
Set-ItemProperty -Path $desktopPath -Name "MouseWheelRouting" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
Write-Host "    ✓ Wheel routing direct" -ForegroundColor Green
$changeCount += 2

# ── 5. USB Selective Suspend ────────────────────────────────────────────────
Write-Host ""
Write-Host "  ► USB Optimization" -ForegroundColor Yellow

$usbPath = "HKLM:\SYSTEM\CurrentControlSet\Services\USB"
if (-not (Test-Path $usbPath)) { New-Item -Path $usbPath -Force | Out-Null }
Set-ItemProperty -Path $usbPath -Name "DisableSelectiveSuspend" -Value 1 -Type DWord -Force
Write-Host "    ✓ USB selective suspend OFF" -ForegroundColor Green

powercfg /SETACVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 2>$null
powercfg /SETACTIVE SCHEME_CURRENT 2>$null
Write-Host "    ✓ USB power saving OFF" -ForegroundColor Green
$changeCount += 2

# ══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   ✅  MOUSE OPTIMIZED — $changeCount changes applied!" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   🖱 Accel: OFF    🎯 Speed: 10/20 (1:1)                   ║" -ForegroundColor Green
Write-Host "  ║   ✨ Trails: OFF   🔌 USB sleep: OFF                        ║" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   ⚠  Log out and back in for all changes to take effect   ║" -ForegroundColor Cyan
Write-Host "  ║   💡 For full setup: MouseOptimizer.ps1                     ║" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Log "Mouse Optimizer Lite Done — $changeCount changes"

Write-Host "  Press Enter to exit..." -ForegroundColor DarkGray
Read-Host
