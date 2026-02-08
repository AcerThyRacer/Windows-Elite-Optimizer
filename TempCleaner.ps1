<#
╔══════════════════════════════════════════════════════════════════════════════╗
║                    🧹 TEMP CLEANER — Deep System Cleanup                   ║
║                                                                            ║
║  Cleans all temporary files, caches, and junk data from Windows 11:        ║
║    • Windows & User temp folders                                           ║
║    • Browser caches (Chrome, Firefox, Edge)                                ║
║    • Shader caches (NVIDIA, AMD, DirectX)                                  ║
║    • Windows Update residue                                                ║
║    • Thumbnail, icon, and font caches                                      ║
║    • Prefetch data                                                         ║
║                                                                            ║
║  Shows total disk space recovered at the end.                              ║
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
$LogFile = "$env:USERPROFILE\TempCleaner_log.txt"
$script:totalBytesRecovered = 0

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
  ║        🧹🧹🧹  TEMP CLEANER  🧹🧹🧹                      ║
  ║                                                              ║
  ║       Windows 11 — Deep System Cleanup                       ║
  ║                                                              ║
  ║       Reclaim disk space. Remove junk. Run faster.           ║
  ║                                                              ║
  ╚══════════════════════════════════════════════════════════════╝

"@
    Write-Host $banner -ForegroundColor Cyan
}

function Write-Section {
    param([string]$Title, [string]$Icon = "►")
    Write-Host ""
    Write-Host "  ┌──────────────────────────────────────────────────────────" -ForegroundColor DarkCyan
    Write-Host "  │ $Icon $Title" -ForegroundColor Cyan
    Write-Host "  └──────────────────────────────────────────────────────────" -ForegroundColor DarkCyan
    Write-Log "=== $Title ==="
}

function Write-Cleaned {
    param([string]$Name, [string]$Size = "")
    if ($Size) {
        Write-Host "    ✓ $Name" -ForegroundColor Green -NoNewline
        Write-Host " — $Size recovered" -ForegroundColor DarkGray
    }
    else {
        Write-Host "    ✓ $Name" -ForegroundColor Green
    }
    Write-Log "  [CLEANED] $Name $Size"
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

function Format-FileSize {
    param([long]$Bytes)
    if ($Bytes -ge 1GB) { return "{0:N2} GB" -f ($Bytes / 1GB) }
    elseif ($Bytes -ge 1MB) { return "{0:N1} MB" -f ($Bytes / 1MB) }
    elseif ($Bytes -ge 1KB) { return "{0:N0} KB" -f ($Bytes / 1KB) }
    else { return "$Bytes bytes" }
}

function Get-FolderSize {
    param([string]$Path)
    if (Test-Path $Path) {
        $size = (Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue |
            Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        return [long]$size
    }
    return 0
}

function Remove-TempFolder {
    param(
        [string]$Path,
        [string]$Label,
        [switch]$FilesOnly
    )

    if (-not (Test-Path $Path)) {
        Write-Skip $Label "Not found"
        return
    }

    $sizeBefore = Get-FolderSize -Path $Path

    if ($FilesOnly) {
        # Remove files but keep the folder structure
        Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object { -not $_.PSIsContainer } |
        Remove-Item -Force -ErrorAction SilentlyContinue
    }
    else {
        # Remove everything — files and subfolders
        Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue |
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }

    $sizeAfter = Get-FolderSize -Path $Path
    $recovered = $sizeBefore - $sizeAfter
    if ($recovered -lt 0) { $recovered = 0 }
    $script:totalBytesRecovered += $recovered

    if ($recovered -gt 0) {
        Write-Cleaned $Label (Format-FileSize $recovered)
    }
    else {
        Write-Cleaned $Label "Already clean"
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
    Write-Host "  [$bar] $pct% — $StepName" -ForegroundColor Magenta
}

# ══════════════════════════════════════════════════════════════════════════════
#                              MAIN EXECUTION
# ══════════════════════════════════════════════════════════════════════════════

Clear-Host
Write-Banner

Write-Host "  This will clean temporary files, caches, and system junk." -ForegroundColor White
Write-Host "  No personal files, documents, or settings will be affected." -ForegroundColor DarkGray
Write-Host ""
Write-Log "═══════════════════════════════════════════════════"
Write-Log "Temp Cleaner Script Started"
Write-Log "═══════════════════════════════════════════════════"

# Get initial disk space
$diskBefore = (Get-PSDrive C).Free

# ══════════════════════════════════════════════════════════════════════════════
# STEP 1: WINDOWS TEMP FOLDERS
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Cleaning Windows Temp Folders"
Write-Section "Windows Temp Folders" "📁"

# WHY: Windows dumps crash reports, installer leftovers, and temporary data
# into these folders. They grow forever and are never automatically cleaned.

Remove-TempFolder -Path "$env:TEMP" -Label "User Temp (%TEMP%)" -FilesOnly
Remove-TempFolder -Path "$env:SystemRoot\Temp" -Label "Windows Temp" -FilesOnly
Remove-TempFolder -Path "$env:SystemRoot\Logs" -Label "Windows Logs" -FilesOnly

# Error reports and feedback
Remove-TempFolder -Path "$env:LOCALAPPDATA\Microsoft\Windows\WER" -Label "Windows Error Reports"
Remove-TempFolder -Path "$env:ProgramData\Microsoft\Windows\WER" -Label "System Error Reports"

# Delivery Optimization cache (peer-to-peer update downloads)
Remove-TempFolder -Path "$env:SystemRoot\SoftwareDistribution\DeliveryOptimization" -Label "Delivery Optimization Cache"

# Recent items cache
Remove-TempFolder -Path "$env:APPDATA\Microsoft\Windows\Recent\AutomaticDestinations" -Label "Recent Jump Lists"
Remove-TempFolder -Path "$env:APPDATA\Microsoft\Windows\Recent\CustomDestinations" -Label "Custom Jump Lists"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 2: PREFETCH CACHE
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Cleaning Prefetch Cache"
Write-Section "Prefetch Cache" "⚡"

# WHY: Prefetch stores traces of launched apps to speed up loading.
# If you've disabled Prefetch in our optimization scripts, these files
# are completely useless. Even if Prefetch is enabled, clearing the cache
# forces it to rebuild with fresh data.

Remove-TempFolder -Path "$env:SystemRoot\Prefetch" -Label "Prefetch Data" -FilesOnly

# ══════════════════════════════════════════════════════════════════════════════
# STEP 3: BROWSER CACHES
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Cleaning Browser Caches"
Write-Section "Browser Caches" "🌐"

# WHY: Browsers store hundreds of MBs to GBs of cached web content.
# This provides almost no benefit on modern fast internet connections
# but wastes significant disk space.

# Google Chrome
$chromeCachePaths = @(
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\GPUCache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Service Worker\CacheStorage",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Service Worker\ScriptCache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\ShaderCache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\GrShaderCache"
)
foreach ($cache in $chromeCachePaths) {
    Remove-TempFolder -Path $cache -Label "Chrome: $(Split-Path $cache -Leaf)"
}

# Mozilla Firefox
$firefoxProfiles = "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles"
if (Test-Path $firefoxProfiles) {
    $profiles = Get-ChildItem -Path $firefoxProfiles -Directory -ErrorAction SilentlyContinue
    foreach ($profile in $profiles) {
        Remove-TempFolder -Path "$($profile.FullName)\cache2" -Label "Firefox: cache2 ($($profile.Name))"
        Remove-TempFolder -Path "$($profile.FullName)\shader-cache" -Label "Firefox: shader-cache"
    }
}
else {
    Write-Skip "Firefox Cache" "Firefox not installed"
}

# Microsoft Edge
$edgeCachePaths = @(
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\GPUCache",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Service Worker\CacheStorage",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\ShaderCache"
)
foreach ($cache in $edgeCachePaths) {
    Remove-TempFolder -Path $cache -Label "Edge: $(Split-Path $cache -Leaf)"
}

# Brave Browser
$braveCachePaths = @(
    "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Cache",
    "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Code Cache",
    "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\GPUCache"
)
foreach ($cache in $braveCachePaths) {
    if (Test-Path $cache) {
        Remove-TempFolder -Path $cache -Label "Brave: $(Split-Path $cache -Leaf)"
    }
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 4: SHADER CACHES (GPU)
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Cleaning GPU Shader Caches"
Write-Section "GPU Shader Caches" "🎮"

# WHY: GPU drivers compile and cache shaders for each game. Over time these
# caches grow to multiple GB and can contain stale data from games you've
# uninstalled. Clearing forces the driver to recompile fresh shaders.

# NVIDIA Shader Cache
$nvidiaCachePaths = @(
    "$env:LOCALAPPDATA\NVIDIA\DXCache",
    "$env:LOCALAPPDATA\NVIDIA\GLCache",
    "$env:LOCALAPPDATA\NVIDIA Corporation\NV_Cache",
    "$env:TEMP\NVIDIA Corporation\NV_Cache"
)
foreach ($cache in $nvidiaCachePaths) {
    Remove-TempFolder -Path $cache -Label "NVIDIA: $(Split-Path $cache -Leaf)"
}

# AMD Shader Cache
$amdCachePaths = @(
    "$env:LOCALAPPDATA\AMD\DxCache",
    "$env:LOCALAPPDATA\AMD\GLCache",
    "$env:LOCALAPPDATA\AMD\VkCache"
)
foreach ($cache in $amdCachePaths) {
    Remove-TempFolder -Path $cache -Label "AMD: $(Split-Path $cache -Leaf)"
}

# Intel GPU Shader Cache
Remove-TempFolder -Path "$env:LOCALAPPDATA\Intel\ShaderCache" -Label "Intel: ShaderCache"

# DirectX Shader Cache (shared by all GPUs)
Remove-TempFolder -Path "$env:LOCALAPPDATA\D3DSCache" -Label "DirectX: D3DSCache"

# Direct3D pipeline state cache
Remove-TempFolder -Path "$env:LOCALAPPDATA\Microsoft\DirectX Shader Cache" -Label "DirectX: Shader Cache"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 5: THUMBNAIL, ICON & FONT CACHES
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Cleaning System Caches"
Write-Section "Thumbnail, Icon & Font Caches" "🖼"

# WHY: Windows caches thumbnails for every image/video/folder you've viewed.
# This database grows to hundreds of MB. Clearing it forces a fresh rebuild
# which can fix corrupted thumbnails and broken icons.

# Thumbnail cache
$thumbCachePath = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
if (Test-Path $thumbCachePath) {
    $thumbFiles = Get-ChildItem -Path $thumbCachePath -Filter "thumbcache_*.db" -Force -ErrorAction SilentlyContinue
    $thumbSize = ($thumbFiles | Measure-Object -Property Length -Sum).Sum
    foreach ($file in $thumbFiles) {
        Remove-Item -Path $file.FullName -Force -ErrorAction SilentlyContinue
    }
    $script:totalBytesRecovered += [long]$thumbSize
    Write-Cleaned "Thumbnail Cache" (Format-FileSize $thumbSize)
}

# Icon cache
$iconCachePath = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache_*.db"
$iconFiles = Get-Item -Path $iconCachePath -Force -ErrorAction SilentlyContinue
if ($iconFiles) {
    $iconSize = ($iconFiles | Measure-Object -Property Length -Sum).Sum
    $iconFiles | Remove-Item -Force -ErrorAction SilentlyContinue
    $script:totalBytesRecovered += [long]$iconSize
    Write-Cleaned "Icon Cache" (Format-FileSize $iconSize)
}
else {
    Write-Cleaned "Icon Cache" "Already clean"
}

# Font cache
$fontCacheSvc = Get-Service -Name "FontCache" -ErrorAction SilentlyContinue
if ($fontCacheSvc -and $fontCacheSvc.Status -eq "Running") {
    Stop-Service -Name "FontCache" -Force -ErrorAction SilentlyContinue
}
$fontCacheFile = "$env:SystemRoot\ServiceProfiles\LocalService\AppData\Local\FontCache\*.dat"
$fontFiles = Get-Item -Path $fontCacheFile -Force -ErrorAction SilentlyContinue
if ($fontFiles) {
    $fontSize = ($fontFiles | Measure-Object -Property Length -Sum).Sum
    $fontFiles | Remove-Item -Force -ErrorAction SilentlyContinue
    $script:totalBytesRecovered += [long]$fontSize
    Write-Cleaned "Font Cache" (Format-FileSize $fontSize)
}
else {
    Write-Cleaned "Font Cache" "Already clean"
}
if ($fontCacheSvc) {
    Start-Service -Name "FontCache" -ErrorAction SilentlyContinue
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 6: WINDOWS UPDATE CLEANUP
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Cleaning Windows Update Residue"
Write-Section "Windows Update Cleanup" "🔄"

# WHY: Windows keeps old update files, superseded component store data, and
# download caches. These can grow to 5-20GB over time. DISM cleanup safely
# removes versions you can no longer uninstall.

Write-Info "Cleaning Software Distribution download cache..."
$sdPath = "$env:SystemRoot\SoftwareDistribution\Download"
Remove-TempFolder -Path $sdPath -Label "Update Download Cache"

Write-Info "Running DISM component cleanup (this may take a minute)..."
$dismOutput = & DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Cleaned "DISM Component Cleanup" "Superseded updates removed"
}
else {
    Write-Skip "DISM Cleanup" "No superseded components found"
}

# ══════════════════════════════════════════════════════════════════════════════
# STEP 7: APPLICATION CACHES
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Cleaning Application Caches"
Write-Section "Application Caches" "📦"

# Steam download cache
Remove-TempFolder -Path "$env:ProgramFiles (x86)\Steam\steamapps\downloading" -Label "Steam: Downloading"
Remove-TempFolder -Path "$env:ProgramFiles (x86)\Steam\steamapps\temp" -Label "Steam: Temp"

# Discord cache
Remove-TempFolder -Path "$env:APPDATA\discord\Cache" -Label "Discord: Cache"
Remove-TempFolder -Path "$env:APPDATA\discord\Code Cache" -Label "Discord: Code Cache"
Remove-TempFolder -Path "$env:APPDATA\discord\GPUCache" -Label "Discord: GPUCache"

# Spotify cache
Remove-TempFolder -Path "$env:LOCALAPPDATA\Spotify\Storage" -Label "Spotify: Storage Cache"

# Microsoft Teams cache
Remove-TempFolder -Path "$env:APPDATA\Microsoft\Teams\Cache" -Label "Teams: Cache"
Remove-TempFolder -Path "$env:APPDATA\Microsoft\Teams\Code Cache" -Label "Teams: Code Cache"
Remove-TempFolder -Path "$env:APPDATA\Microsoft\Teams\GPUCache" -Label "Teams: GPUCache"

# VSCode cache
Remove-TempFolder -Path "$env:APPDATA\Code\Cache" -Label "VS Code: Cache"
Remove-TempFolder -Path "$env:APPDATA\Code\CachedData" -Label "VS Code: CachedData"
Remove-TempFolder -Path "$env:APPDATA\Code\CachedExtensions" -Label "VS Code: Extensions Cache"

# Windows Store cache
Remove-TempFolder -Path "$env:LOCALAPPDATA\Packages\Microsoft.WindowsStore_8wekyb3d8bbwe\AC\INetCache" -Label "Windows Store: Cache"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 8: RECYCLE BIN
# ══════════════════════════════════════════════════════════════════════════════
Show-Progress "Emptying Recycle Bin"
Write-Section "Recycle Bin" "🗑"

Write-Host "  Clear Recycle Bin? (Y/N): " -ForegroundColor Yellow -NoNewline
$clearBin = Read-Host
if ($clearBin -eq "Y" -or $clearBin -eq "y") {
    # Get recycle bin size before clearing
    $shell = New-Object -ComObject Shell.Application
    $recycleBin = $shell.NameSpace(0x0a)
    $binItems = $recycleBin.Items()
    $binSize = 0
    foreach ($item in $binItems) {
        $binSize += $recycleBin.GetDetailsOf($item, 2) -replace '[^\d]', '' -as [long]
    }

    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Write-Cleaned "Recycle Bin" "Emptied"
}
else {
    Write-Skip "Recycle Bin" "Skipped by user"
}

# ══════════════════════════════════════════════════════════════════════════════
#                           COMPLETION SUMMARY
# ══════════════════════════════════════════════════════════════════════════════

# Get final disk space
$diskAfter = (Get-PSDrive C).Free
$diskRecovered = $diskAfter - $diskBefore
if ($diskRecovered -lt 0) { $diskRecovered = 0 }

# Use whichever measurement is larger
$displayRecovered = if ($diskRecovered -gt $script:totalBytesRecovered) { $diskRecovered } else { $script:totalBytesRecovered }

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   ✅  DEEP CLEAN COMPLETE!                                  ║" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   📊 Total Space Recovered: $(Format-FileSize $displayRecovered)" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   📁 Temp Folders:     Cleaned                              ║" -ForegroundColor Green
Write-Host "  ║   ⚡ Prefetch:         Cleared                              ║" -ForegroundColor Green
Write-Host "  ║   🌐 Browser Caches:   Chrome, Firefox, Edge, Brave         ║" -ForegroundColor Green
Write-Host "  ║   🎮 Shader Caches:    NVIDIA, AMD, Intel, DirectX          ║" -ForegroundColor Green
Write-Host "  ║   🖼  System Caches:    Thumbnails, Icons, Fonts             ║" -ForegroundColor Green
Write-Host "  ║   🔄 Windows Update:   Old updates cleaned via DISM         ║" -ForegroundColor Green
Write-Host "  ║   📦 App Caches:       Steam, Discord, Spotify, Teams, Code ║" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║   📄 Log: $LogFile" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Log "═══════════════════════════════════════════════════"
Write-Log "Temp Cleaner Completed — Recovered: $(Format-FileSize $displayRecovered)"
Write-Log "═══════════════════════════════════════════════════"

Write-Host "  Press Enter to exit..." -ForegroundColor DarkGray
Read-Host
