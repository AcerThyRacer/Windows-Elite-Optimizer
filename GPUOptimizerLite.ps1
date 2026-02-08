<#
╔══════════════════════════════════════════════════════════════════════════════╗
║            🖥 GPU OPTIMIZER LITE — Quick GPU Performance Fix               ║
║                                                                            ║
║  Auto-detects GPU and applies safe, recommended settings instantly:        ║
║    ✓ Disable MPO (Multi-Plane Overlay) — fixes stuttering                ║
║    ✓ Enable Hardware-Accelerated GPU Scheduling                           ║
║    ✓ Disable Game DVR / background recording                             ║
║    ✓ Disable fullscreen optimizations                                     ║
║    ✓ Enable Game Mode                                                     ║
║    ✓ Vendor-specific: NVIDIA max performance / AMD Anti-Lag               ║
║                                                                            ║
║  For full interactive setup, use: GPUOptimizer.ps1                        ║
║                                                                            ║
║  Run as Administrator — the script will self-elevate if needed.            ║
╚══════════════════════════════════════════════════════════════════════════════╝
#>

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`n[!] Requesting Administrator privileges..." -ForegroundColor Yellow
    $argList = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Start-Process powershell.exe -ArgumentList $argList -Verb RunAs
    exit
}

$ErrorActionPreference = "SilentlyContinue"
$LogFile = "$env:USERPROFILE\GPUOptimizerLite_log.txt"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp | $Message" | Out-File -FilePath $LogFile -Append -Encoding UTF8
}

function Ensure-RegistryPath {
    param([string]$Path)
    if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
}

Clear-Host
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║        🖥  GPU OPTIMIZER LITE  🖥                            ║" -ForegroundColor Green
Write-Host "  ║       Quick GPU Fix — Auto-Detect & Optimize                ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Log "GPU Optimizer Lite Started"
$changeCount = 0

# ── Detect GPU ───────────────────────────────────────────────────────────────
Write-Host "  ► Detecting GPU" -ForegroundColor Green

$gpus = Get-CimInstance Win32_VideoController | Where-Object { $_.Status -eq "OK" }
$hasNvidia = $false; $hasAMD = $false
$gpuName = "Unknown"

foreach ($gpu in $gpus) {
    if ($gpu.Name -match "NVIDIA|GeForce|RTX|GTX") { $hasNvidia = $true; $gpuName = $gpu.Name }
    elseif ($gpu.Name -match "AMD|Radeon|RX ") { $hasAMD = $true; $gpuName = $gpu.Name }
}
Write-Host "    🖥 $gpuName" -ForegroundColor White

# ── NVIDIA Tweaks ────────────────────────────────────────────────────────────
if ($hasNvidia) {
    Write-Host ""
    Write-Host "  ► NVIDIA Optimizations" -ForegroundColor Green

    $nvGlobalPath = "HKLM:\SOFTWARE\NVIDIA Corporation\Global\NVTweak"
    Ensure-RegistryPath $nvGlobalPath
    Set-ItemProperty -Path $nvGlobalPath -Name "PowerPlan" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Host "    ✓ Power: Max Performance" -ForegroundColor Green

    Set-ItemProperty -Path $nvGlobalPath -Name "LowLatencyMode" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Host "    ✓ Low Latency: Ultra" -ForegroundColor Green

    Set-ItemProperty -Path $nvGlobalPath -Name "ThreadedOptimization" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Host "    ✓ Threaded Opt: Off (lower latency)" -ForegroundColor Green
    $changeCount += 3
}

# ── AMD Tweaks ───────────────────────────────────────────────────────────────
if ($hasAMD) {
    Write-Host ""
    Write-Host "  ► AMD Optimizations" -ForegroundColor Red

    $amdRegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000"
    $displayClasses = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" -ErrorAction SilentlyContinue
    foreach ($cls in $displayClasses) {
        $desc = (Get-ItemProperty -Path $cls.PSPath -Name "DriverDesc" -ErrorAction SilentlyContinue).DriverDesc
        if ($desc -match "AMD|Radeon") { $amdRegPath = $cls.PSPath; break }
    }

    Set-ItemProperty -Path $amdRegPath -Name "AntiLag" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Host "    ✓ Anti-Lag: Enabled" -ForegroundColor Green

    Set-ItemProperty -Path $amdRegPath -Name "EnableUlps" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Host "    ✓ ULPS: Disabled" -ForegroundColor Green

    Set-ItemProperty -Path $amdRegPath -Name "ShaderCache" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Host "    ✓ Shader Cache: On" -ForegroundColor Green
    $changeCount += 3
}

# ── Universal Tweaks ─────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ► Universal GPU Settings" -ForegroundColor Green

# MPO
$mpoPath = "HKLM:\SOFTWARE\Microsoft\Windows\Dwm"
Ensure-RegistryPath $mpoPath
Set-ItemProperty -Path $mpoPath -Name "OverlayTestMode" -Value 5 -Type DWord -Force
Write-Host "    ✓ MPO: Disabled (fixes stuttering)" -ForegroundColor Green
$changeCount++

# HAGS
$hagsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
Set-ItemProperty -Path $hagsPath -Name "HwSchMode" -Value 2 -Type DWord -Force
Write-Host "    ✓ HAGS: Enabled" -ForegroundColor Green
$changeCount++

# Game Mode
$gameModePath = "HKCU:\Software\Microsoft\GameBar"
Ensure-RegistryPath $gameModePath
Set-ItemProperty -Path $gameModePath -Name "AutoGameModeEnabled" -Value 1 -Type DWord -Force
Write-Host "    ✓ Game Mode: Enabled" -ForegroundColor Green
$changeCount++

# FSO
$fsoPath = "HKCU:\System\GameConfigStore"
Ensure-RegistryPath $fsoPath
Set-ItemProperty -Path $fsoPath -Name "GameDVR_FSEBehaviorMode" -Value 2 -Type DWord -Force
Set-ItemProperty -Path $fsoPath -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 1 -Type DWord -Force
Write-Host "    ✓ Fullscreen Optimizations: Disabled" -ForegroundColor Green
$changeCount++

# Game DVR
$dvrPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR"
Ensure-RegistryPath $dvrPath
Set-ItemProperty -Path $dvrPath -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force
$gameDvrPolicy = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
Ensure-RegistryPath $gameDvrPolicy
Set-ItemProperty -Path $gameDvrPolicy -Name "AllowGameDVR" -Value 0 -Type DWord -Force
Write-Host "    ✓ Game DVR: Disabled" -ForegroundColor Green
$changeCount++

# ══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   ✅  GPU OPTIMIZED — $changeCount changes applied!" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   🖥 $gpuName" -ForegroundColor Green
Write-Host "  ║   🛡 MPO: Off   ⚡ HAGS: On   🎮 Game Mode: On             ║" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   ⚠  Restart required for HAGS and MPO changes            ║" -ForegroundColor Yellow
Write-Host "  ║   💡 For full control: GPUOptimizer.ps1                     ║" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Log "GPU Optimizer Lite Done — $changeCount changes"

Write-Host "  Press Enter to exit..." -ForegroundColor DarkGray
Read-Host
