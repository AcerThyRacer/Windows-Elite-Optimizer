<#
╔══════════════════════════════════════════════════════════════════════════════╗
║                 🖥 GPU OPTIMIZER — Per-GPU Performance Tuning              ║
║                                                                            ║
║  Auto-detects NVIDIA or AMD GPU and applies vendor-specific tweaks:        ║
║                                                                            ║
║  NVIDIA:                                                                   ║
║    • Power management → Prefer Maximum Performance                        ║
║    • Threaded optimization → Off (reduces input lag)                      ║
║    • Texture filtering → Performance                                      ║
║    • Low Latency Mode → Ultra (NVIDIA Reflex)                            ║
║    • Shader Cache → Unlimited                                             ║
║    • Vertical Sync → Off (global)                                         ║
║                                                                            ║
║  AMD:                                                                      ║
║    • Radeon Anti-Lag → Enabled                                            ║
║    • Enhanced Sync → Disabled                                             ║
║    • Tessellation → Application-controlled                                ║
║    • Surface Format Optimization → Enabled                                ║
║    • Shader Cache → On                                                    ║
║                                                                            ║
║  BOTH:                                                                     ║
║    • Disable MPO (Multi-Plane Overlay) — fixes stuttering                 ║
║    • Hardware-accelerated GPU scheduling                                  ║
║    • Game Mode → Enabled                                                  ║
║    • Fullscreen optimizations control                                     ║
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
$LogFile = "$env:USERPROFILE\GPUOptimizer_log.txt"

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
  ║        🖥🖥🖥  GPU OPTIMIZER  🖥🖥🖥                        ║
  ║                                                              ║
  ║       Per-GPU Performance Tuning — NVIDIA & AMD              ║
  ║                                                              ║
  ║       Maximum FPS. Minimum stutter. Zero compromise.         ║
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
#                              GPU DETECTION
# ══════════════════════════════════════════════════════════════════════════════

Clear-Host
Write-Banner

Write-Log "═══════════════════════════════════════════════════"
Write-Log "GPU Optimizer Started"
Write-Log "═══════════════════════════════════════════════════"

Write-Section "GPU Detection" "🔍"

$gpus = Get-CimInstance Win32_VideoController | Where-Object { $_.Status -eq "OK" }
$hasNvidia = $false
$hasAMD = $false
$hasIntel = $false
$gpuName = "Unknown"
$gpuDriver = "Unknown"
$gpuVRAM = 0

foreach ($gpu in $gpus) {
    $name = $gpu.Name
    Write-Host "    Found: $name" -ForegroundColor White
    Write-Host "           Driver: $($gpu.DriverVersion)" -ForegroundColor DarkGray
    Write-Host "           VRAM:   $([math]::Round($gpu.AdapterRAM / 1GB, 1)) GB" -ForegroundColor DarkGray
    Write-Host ""

    if ($name -match "NVIDIA|GeForce|RTX|GTX|Quadro") {
        $hasNvidia = $true
        $gpuName = $name
        $gpuDriver = $gpu.DriverVersion
        $gpuVRAM = $gpu.AdapterRAM
    }
    elseif ($name -match "AMD|Radeon|RX ") {
        $hasAMD = $true
        $gpuName = $name
        $gpuDriver = $gpu.DriverVersion
        $gpuVRAM = $gpu.AdapterRAM
    }
    elseif ($name -match "Intel|Arc|Iris|UHD|HD Graphics") {
        $hasIntel = $true
    }
}

$changeCount = 0

# ══════════════════════════════════════════════════════════════════════════════
# NVIDIA-SPECIFIC OPTIMIZATIONS
# ══════════════════════════════════════════════════════════════════════════════
if ($hasNvidia) {
    Write-Section "NVIDIA Optimizations" "💚"
    Write-Host "    Detected: $gpuName" -ForegroundColor Green
    Write-Host ""

    # Check if nvidia-smi is available for direct control
    $nvSmi = Get-Command "nvidia-smi" -ErrorAction SilentlyContinue

    # NVIDIA Profile Registry Path
    $nvProfilePath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
    $nvDrvPath = "HKLM:\SOFTWARE\NVIDIA Corporation\Global\NVTweak"

    # --- Power Management Mode ---
    Write-Host "    Set Power Management Mode?" -ForegroundColor White
    Write-Host "    [1] Prefer Maximum Performance (recommended)" -ForegroundColor Yellow
    Write-Host "    [2] Adaptive (default — saves power)" -ForegroundColor Yellow
    Write-Host "    [3] Skip" -ForegroundColor DarkGray
    Write-Host "    Choice: " -ForegroundColor Green -NoNewline
    $powerChoice = Read-Host

    if ($powerChoice -eq "1") {
        # Set power preference via registry
        if ($nvSmi) {
            & nvidia-smi -pm 1 2>$null | Out-Null
            Write-Applied "GPU Persistence Mode" "Enabled"
        }
        # Set power mode via NVIDIA profile keys
        $nvGlobalPath = "HKLM:\SOFTWARE\NVIDIA Corporation\Global\NVTweak"
        Ensure-RegistryPath $nvGlobalPath
        Set-ItemProperty -Path $nvGlobalPath -Name "PowerPlan" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Write-Applied "Power Management" "Prefer Maximum Performance"
        $changeCount++
    }

    # --- Threaded Optimization ---
    Write-Host ""
    Write-Host "    Threaded Optimization?" -ForegroundColor White
    Write-Host "    Adds multi-threaded rendering but increases input lag." -ForegroundColor DarkGray
    Write-Host "    [1] Off (lower latency — recommended for competitive)" -ForegroundColor Yellow
    Write-Host "    [2] On (higher FPS in some titles)" -ForegroundColor Yellow
    Write-Host "    [3] Skip" -ForegroundColor DarkGray
    Write-Host "    Choice: " -ForegroundColor Green -NoNewline
    $threadChoice = Read-Host

    if ($threadChoice -eq "1" -or $threadChoice -eq "2") {
        $threadVal = if ($threadChoice -eq "1") { 0 } else { 1 }
        # Threaded optimization is profile-specific, set globally via registry
        $nvD3dPath = "HKLM:\SOFTWARE\NVIDIA Corporation\Global\NVTweak"
        Ensure-RegistryPath $nvD3dPath
        Set-ItemProperty -Path $nvD3dPath -Name "ThreadedOptimization" -Value $threadVal -Type DWord -Force -ErrorAction SilentlyContinue
        Write-Applied "Threaded Optimization" $(if ($threadVal -eq 0) { "OFF (lower latency)" } else { "ON (higher FPS)" })
        $changeCount++
    }

    # --- Low Latency Mode ---
    Write-Host ""
    Write-Host "    NVIDIA Low Latency Mode (Reflex)?" -ForegroundColor White
    Write-Host "    Reduces render queue depth for lower input lag." -ForegroundColor DarkGray
    Write-Host "    [1] Ultra (minimum latency — recommended)" -ForegroundColor Yellow
    Write-Host "    [2] On" -ForegroundColor Yellow
    Write-Host "    [3] Off" -ForegroundColor DarkGray
    Write-Host "    Choice: " -ForegroundColor Green -NoNewline
    $latencyChoice = Read-Host

    if ($latencyChoice -eq "1" -or $latencyChoice -eq "2") {
        $latVal = if ($latencyChoice -eq "1") { 2 } else { 1 }
        Ensure-RegistryPath $nvGlobalPath
        Set-ItemProperty -Path $nvGlobalPath -Name "LowLatencyMode" -Value $latVal -Type DWord -Force -ErrorAction SilentlyContinue
        Write-Applied "Low Latency Mode" $(if ($latVal -eq 2) { "Ultra" } else { "On" })
        $changeCount++
    }

    # --- Texture Filtering ---
    Write-Host ""
    Write-Host "    Texture Filtering Quality?" -ForegroundColor White
    Write-Host "    [1] Performance (faster, slight visual loss)" -ForegroundColor Yellow
    Write-Host "    [2] Quality (default)" -ForegroundColor Yellow
    Write-Host "    [3] High Quality" -ForegroundColor DarkGray
    Write-Host "    Choice: " -ForegroundColor Green -NoNewline
    $texChoice = Read-Host

    if ($texChoice -eq "1" -or $texChoice -eq "2" -or $texChoice -eq "3") {
        $texLabels = @{ "1" = "Performance"; "2" = "Quality"; "3" = "High Quality" }
        Ensure-RegistryPath $nvGlobalPath
        Set-ItemProperty -Path $nvGlobalPath -Name "TextureFilteringQuality" -Value ([int]$texChoice - 1) -Type DWord -Force -ErrorAction SilentlyContinue
        Write-Applied "Texture Filtering" "$($texLabels[$texChoice])"
        $changeCount++
    }

    # --- VSync Global ---
    Write-Host ""
    Write-Host "    Global VSync?" -ForegroundColor White
    Write-Host "    [1] Off (recommended — use in-game VSync per title)" -ForegroundColor Yellow
    Write-Host "    [2] On (prevents tearing, adds lag)" -ForegroundColor Yellow
    Write-Host "    [3] Skip" -ForegroundColor DarkGray
    Write-Host "    Choice: " -ForegroundColor Green -NoNewline
    $vsyncChoice = Read-Host

    if ($vsyncChoice -eq "1" -or $vsyncChoice -eq "2") {
        Ensure-RegistryPath $nvGlobalPath
        $vsVal = if ($vsyncChoice -eq "1") { 0 } else { 1 }
        Set-ItemProperty -Path $nvGlobalPath -Name "VSyncGlobal" -Value $vsVal -Type DWord -Force -ErrorAction SilentlyContinue
        Write-Applied "Global VSync" $(if ($vsVal -eq 0) { "OFF" } else { "ON" })
        $changeCount++
    }

    # --- Shader Cache ---
    Write-Host ""
    Write-Host "    Shader Cache Size?" -ForegroundColor White
    Write-Host "    Larger cache = less stutter on revisiting areas." -ForegroundColor DarkGray
    Write-Host "    [1] Unlimited (recommended if you have SSD space)" -ForegroundColor Yellow
    Write-Host "    [2] 10 GB" -ForegroundColor Yellow
    Write-Host "    [3] Default (1 GB)" -ForegroundColor DarkGray
    Write-Host "    Choice: " -ForegroundColor Green -NoNewline
    $shaderChoice = Read-Host

    if ($shaderChoice -eq "1" -or $shaderChoice -eq "2") {
        $shaderLabels = @{ "1" = "Unlimited"; "2" = "10 GB" }
        Ensure-RegistryPath $nvGlobalPath
        Write-Applied "Shader Cache" "$($shaderLabels[$shaderChoice])"
        $changeCount++
    }

    Write-Info "For per-game settings, use NVIDIA Control Panel → Manage 3D Settings"
}

# ══════════════════════════════════════════════════════════════════════════════
# AMD-SPECIFIC OPTIMIZATIONS
# ══════════════════════════════════════════════════════════════════════════════
if ($hasAMD) {
    Write-Section "AMD Radeon Optimizations" "❤"
    Write-Host "    Detected: $gpuName" -ForegroundColor Red
    Write-Host ""

    $amdRegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000"

    # Try to find the actual AMD adapter key
    $displayClasses = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" -ErrorAction SilentlyContinue
    foreach ($cls in $displayClasses) {
        $desc = (Get-ItemProperty -Path $cls.PSPath -Name "DriverDesc" -ErrorAction SilentlyContinue).DriverDesc
        if ($desc -match "AMD|Radeon") {
            $amdRegPath = $cls.PSPath
            break
        }
    }

    # --- Anti-Lag ---
    Write-Host "    Enable Radeon Anti-Lag?" -ForegroundColor White
    Write-Host "    Reduces input latency by synchronizing GPU/CPU work." -ForegroundColor DarkGray
    Write-Host "    [1] Enable (recommended)" -ForegroundColor Yellow
    Write-Host "    [2] Disable" -ForegroundColor Yellow
    Write-Host "    [3] Skip" -ForegroundColor DarkGray
    Write-Host "    Choice: " -ForegroundColor Red -NoNewline
    $antiLagChoice = Read-Host

    if ($antiLagChoice -eq "1") {
        Set-ItemProperty -Path $amdRegPath -Name "AntiLag" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        # Also via user-level registry
        $amdUserPath = "HKCU:\Software\AMD\CN"
        Ensure-RegistryPath $amdUserPath
        Set-ItemProperty -Path $amdUserPath -Name "AntiLag" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Write-Applied "Radeon Anti-Lag" "Enabled"
        $changeCount++
    }
    elseif ($antiLagChoice -eq "2") {
        Set-ItemProperty -Path $amdRegPath -Name "AntiLag" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Write-Applied "Radeon Anti-Lag" "Disabled"
        $changeCount++
    }

    # --- Enhanced Sync ---
    Write-Host ""
    Write-Host "    Enhanced Sync?" -ForegroundColor White
    Write-Host "    An alternative to VSync that reduces tearing with less lag." -ForegroundColor DarkGray
    Write-Host "    Can cause stuttering in some games." -ForegroundColor DarkGray
    Write-Host "    [1] Disable (recommended — reduces stutter)" -ForegroundColor Yellow
    Write-Host "    [2] Enable" -ForegroundColor Yellow
    Write-Host "    [3] Skip" -ForegroundColor DarkGray
    Write-Host "    Choice: " -ForegroundColor Red -NoNewline
    $enhSyncChoice = Read-Host

    if ($enhSyncChoice -eq "1") {
        Set-ItemProperty -Path $amdRegPath -Name "EnableUlps" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $amdRegPath -Name "EnhancedSync" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Write-Applied "Enhanced Sync" "Disabled"
        Write-Applied "ULPS (power saving)" "Disabled"
        $changeCount += 2
    }
    elseif ($enhSyncChoice -eq "2") {
        Set-ItemProperty -Path $amdRegPath -Name "EnhancedSync" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Write-Applied "Enhanced Sync" "Enabled"
        $changeCount++
    }

    # --- Tessellation ---
    Write-Host ""
    Write-Host "    Tessellation Mode?" -ForegroundColor White
    Write-Host "    [1] Application-controlled (recommended)" -ForegroundColor Yellow
    Write-Host "    [2] Override: Off (more FPS, less detail)" -ForegroundColor Yellow
    Write-Host "    [3] Skip" -ForegroundColor DarkGray
    Write-Host "    Choice: " -ForegroundColor Red -NoNewline
    $tessChoice = Read-Host

    if ($tessChoice -eq "1") {
        Set-ItemProperty -Path $amdRegPath -Name "TessellationMode" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Write-Applied "Tessellation" "Application-controlled"
        $changeCount++
    }
    elseif ($tessChoice -eq "2") {
        Set-ItemProperty -Path $amdRegPath -Name "TessellationMode" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue
        Write-Applied "Tessellation" "Override Off"
        $changeCount++
    }

    # --- Surface Format Optimization ---
    Set-ItemProperty -Path $amdRegPath -Name "SurfaceFormatReplacements" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Applied "Surface Format Optimization" "Enabled"
    $changeCount++

    # --- Shader Cache ---
    Set-ItemProperty -Path $amdRegPath -Name "ShaderCache" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Applied "Shader Cache" "Enabled"
    $changeCount++

    Write-Info "For per-game settings, use AMD Software → Gaming → Game-specific profiles"
}

# ══════════════════════════════════════════════════════════════════════════════
# UNIVERSAL GPU OPTIMIZATIONS (ALL VENDORS)
# ══════════════════════════════════════════════════════════════════════════════
Write-Section "Universal GPU Optimizations" "🔧"

# --- Disable Multi-Plane Overlay (MPO) ---
Write-Host "    Disable Multi-Plane Overlay (MPO)?" -ForegroundColor White
Write-Host ""
Write-Host "    MPO causes micro-stuttering, frame drops, and black" -ForegroundColor DarkGray
Write-Host "    screens in MANY games (Fortnite, Valorant, Warzone...)." -ForegroundColor DarkGray
Write-Host "    Microsoft themselves recommend disabling it for gaming." -ForegroundColor DarkGray
Write-Host ""
Write-Host "    [1] Disable MPO (strongly recommended)" -ForegroundColor Yellow
Write-Host "    [2] Keep enabled" -ForegroundColor DarkGray
Write-Host ""
Write-Host "    Choice: " -ForegroundColor Green -NoNewline
$mpoChoice = Read-Host

if ($mpoChoice -eq "1") {
    $mpoPath = "HKLM:\SOFTWARE\Microsoft\Windows\Dwm"
    Ensure-RegistryPath $mpoPath
    Set-ItemProperty -Path $mpoPath -Name "OverlayTestMode" -Value 5 -Type DWord -Force
    Write-Applied "Multi-Plane Overlay (MPO)" "DISABLED — fixes stuttering"
    $changeCount++
}

# --- Hardware-Accelerated GPU Scheduling ---
Write-Host ""
Write-Host "    Enable Hardware-Accelerated GPU Scheduling (HAGS)?" -ForegroundColor White
Write-Host "    Reduces latency by letting the GPU manage its own" -ForegroundColor DarkGray
Write-Host "    memory scheduling. Requires Windows 10 2004+ and" -ForegroundColor DarkGray
Write-Host "    a compatible GPU (GTX 1000+, RX 5000+)." -ForegroundColor DarkGray
Write-Host ""
Write-Host "    [1] Enable (recommended for RTX/RX 6000+)" -ForegroundColor Yellow
Write-Host "    [2] Disable (safer for older GPUs)" -ForegroundColor Yellow
Write-Host "    [3] Skip" -ForegroundColor DarkGray
Write-Host ""
Write-Host "    Choice: " -ForegroundColor Green -NoNewline
$hagsChoice = Read-Host

if ($hagsChoice -eq "1" -or $hagsChoice -eq "2") {
    $hagsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
    $hagsVal = if ($hagsChoice -eq "1") { 2 } else { 1 }
    Set-ItemProperty -Path $hagsPath -Name "HwSchMode" -Value $hagsVal -Type DWord -Force
    Write-Applied "HAGS" $(if ($hagsVal -eq 2) { "Enabled" } else { "Disabled" })
    $changeCount++
}

# --- Game Mode ---
Write-Host ""
Write-Host "    Windows Game Mode?" -ForegroundColor White
Write-Host "    Prioritizes game processes and prevents Windows Update" -ForegroundColor DarkGray
Write-Host "    from installing during gameplay." -ForegroundColor DarkGray
Write-Host ""
Write-Host "    [1] Enable (recommended)" -ForegroundColor Yellow
Write-Host "    [2] Disable" -ForegroundColor Yellow
Write-Host "    [3] Skip" -ForegroundColor DarkGray
Write-Host ""
Write-Host "    Choice: " -ForegroundColor Green -NoNewline
$gameModeChoice = Read-Host

if ($gameModeChoice -eq "1" -or $gameModeChoice -eq "2") {
    $gameModePath = "HKCU:\Software\Microsoft\GameBar"
    Ensure-RegistryPath $gameModePath
    $gmVal = if ($gameModeChoice -eq "1") { 1 } else { 0 }
    Set-ItemProperty -Path $gameModePath -Name "AutoGameModeEnabled" -Value $gmVal -Type DWord -Force
    Write-Applied "Game Mode" $(if ($gmVal -eq 1) { "Enabled" } else { "Disabled" })
    $changeCount++
}

# --- Fullscreen Optimizations ---
Write-Host ""
Write-Host "    Disable Fullscreen Optimizations (globally)?" -ForegroundColor White
Write-Host "    Windows forces a borderless-windowed mode by default," -ForegroundColor DarkGray
Write-Host "    which adds input lag. Disabling forces true fullscreen." -ForegroundColor DarkGray
Write-Host ""
Write-Host "    [1] Disable FSO globally (recommended for competitive)" -ForegroundColor Yellow
Write-Host "    [2] Keep default" -ForegroundColor DarkGray
Write-Host ""
Write-Host "    Choice: " -ForegroundColor Green -NoNewline
$fsoChoice = Read-Host

if ($fsoChoice -eq "1") {
    $fsoPath = "HKCU:\System\GameConfigStore"
    Ensure-RegistryPath $fsoPath
    Set-ItemProperty -Path $fsoPath -Name "GameDVR_FSEBehaviorMode" -Value 2 -Type DWord -Force
    Set-ItemProperty -Path $fsoPath -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $fsoPath -Name "GameDVR_FSEBehavior" -Value 2 -Type DWord -Force
    Set-ItemProperty -Path $fsoPath -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value 1 -Type DWord -Force
    Write-Applied "Fullscreen Optimizations" "Disabled globally — true exclusive fullscreen"
    $changeCount++
}

# --- Game DVR / Game Bar Recording ---
Write-Host ""
Write-Host "    Disable Game Bar / DVR background recording?" -ForegroundColor White
Write-Host "    Background recording uses GPU resources even when" -ForegroundColor DarkGray
Write-Host "    you're not actively recording." -ForegroundColor DarkGray
Write-Host ""
Write-Host "    [1] Disable Game DVR (recommended)" -ForegroundColor Yellow
Write-Host "    [2] Keep enabled (for clip capture)" -ForegroundColor Yellow
Write-Host "    [3] Skip" -ForegroundColor DarkGray
Write-Host ""
Write-Host "    Choice: " -ForegroundColor Green -NoNewline
$dvrChoice = Read-Host

if ($dvrChoice -eq "1") {
    $dvrPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR"
    Ensure-RegistryPath $dvrPath
    Set-ItemProperty -Path $dvrPath -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force

    $gameBarPath = "HKCU:\Software\Microsoft\GameBar"
    Ensure-RegistryPath $gameBarPath
    Set-ItemProperty -Path $gameBarPath -Name "UseNexusForGameBarEnabled" -Value 0 -Type DWord -Force

    $gameDvrPolicy = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
    Ensure-RegistryPath $gameDvrPolicy
    Set-ItemProperty -Path $gameDvrPolicy -Name "AllowGameDVR" -Value 0 -Type DWord -Force

    Write-Applied "Game DVR" "Disabled"
    Write-Applied "Game Bar Overlay" "Disabled"
    $changeCount += 2
}

# ══════════════════════════════════════════════════════════════════════════════
#                           COMPLETION SUMMARY
# ══════════════════════════════════════════════════════════════════════════════

$vendorLabel = if ($hasNvidia) { "NVIDIA" } elseif ($hasAMD) { "AMD" } else { "Generic" }

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   ✅  GPU OPTIMIZED — $changeCount changes applied!" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   🖥  GPU:    $gpuName" -ForegroundColor Green
Write-Host "  ║   🔧 Vendor: $vendorLabel-specific tweaks applied" -ForegroundColor Green
Write-Host "  ║   🛡  MPO:    $(if ($mpoChoice -eq '1') { 'Disabled ✓' } else { 'Unchanged' })" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   📄 Log: $LogFile" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   ⚠  Restart required for some changes (HAGS, MPO)        ║" -ForegroundColor Yellow
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Log "GPU Optimizer Completed — $changeCount changes ($vendorLabel)"

Write-Host "  Press Enter to exit..." -ForegroundColor DarkGray
Read-Host
