<#
╔══════════════════════════════════════════════════════════════════════════════╗
║                 🧹 BLOAT REMOVER — Windows 11 App Cleanup                  ║
║                                                                            ║
║  Remove ALL pre-installed bloatware with an interactive menu:              ║
║    • Clipchamp, News, Weather, Maps, People, Solitaire                    ║
║    • Xbox Game Bar (optional — some gamers use it)                        ║
║    • Microsoft Teams (personal)                                            ║
║    • 3D Viewer, Paint 3D, Mixed Reality Portal                            ║
║    • Groove Music, Movies & TV                                             ║
║    • Office web stubs                                                      ║
║    • Windows widgets & Copilot                                             ║
║                                                                            ║
║  Features an interactive menu to choose which apps to keep.               ║
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
$LogFile = "$env:USERPROFILE\BloatRemover_log.txt"

# ─── Bloatware Database ─────────────────────────────────────────────────────
# Organized by category. Each app has a package name pattern and safety note.
$bloatCategories = [ordered]@{
    "Communication & Social"      = @(
        @{ Name = "Microsoft.People"; Label = "People"; Safe = $true },
        @{ Name = "microsoft.windowscommunicationsapps"; Label = "Mail & Calendar"; Safe = $true },
        @{ Name = "Microsoft.SkypeApp"; Label = "Skype"; Safe = $true },
        @{ Name = "MicrosoftTeams"; Label = "Teams (Personal)"; Safe = $true },
        @{ Name = "Microsoft.YourPhone"; Label = "Phone Link"; Safe = $true },
        @{ Name = "Microsoft.Todos"; Label = "Microsoft To Do"; Safe = $true }
    )
    "Entertainment & Media"       = @(
        @{ Name = "Microsoft.ZuneMusic"; Label = "Groove Music"; Safe = $true },
        @{ Name = "Microsoft.ZuneVideo"; Label = "Movies & TV"; Safe = $true },
        @{ Name = "Microsoft.MicrosoftSolitaireCollection"; Label = "Solitaire Collection"; Safe = $true },
        @{ Name = "SpotifyAB.SpotifyMusic"; Label = "Spotify (pre-install)"; Safe = $true },
        @{ Name = "Clipchamp.Clipchamp"; Label = "Clipchamp Video Editor"; Safe = $true },
        @{ Name = "Disney.37853FC22B2CE"; Label = "Disney+"; Safe = $true },
        @{ Name = "5A894077.McAfeeSecurity"; Label = "McAfee Security"; Safe = $true },
        @{ Name = "4DF9E0F8.Netflix"; Label = "Netflix"; Safe = $true },
        @{ Name = "Amazon.com.Amazon"; Label = "Amazon"; Safe = $true },
        @{ Name = "Facebook.Facebook"; Label = "Facebook"; Safe = $true },
        @{ Name = "BytedancePte.Ltd.TikTok"; Label = "TikTok"; Safe = $true },
        @{ Name = "FACEBOOK.INSTAGRAM"; Label = "Instagram"; Safe = $true }
    )
    "News & Information"          = @(
        @{ Name = "Microsoft.BingNews"; Label = "Bing News"; Safe = $true },
        @{ Name = "Microsoft.BingWeather"; Label = "Weather"; Safe = $true },
        @{ Name = "Microsoft.BingFinance"; Label = "Money/Finance"; Safe = $true },
        @{ Name = "Microsoft.BingSports"; Label = "Sports"; Safe = $true },
        @{ Name = "Microsoft.BingTravel"; Label = "Travel"; Safe = $true },
        @{ Name = "Microsoft.BingHealthAndFitness"; Label = "Health & Fitness"; Safe = $true },
        @{ Name = "Microsoft.BingFoodAndDrink"; Label = "Food & Drink"; Safe = $true },
        @{ Name = "Microsoft.MicrosoftNews"; Label = "Microsoft News"; Safe = $true }
    )
    "Productivity (Office Stubs)" = @(
        @{ Name = "Microsoft.MicrosoftOfficeHub"; Label = "Office Hub"; Safe = $true },
        @{ Name = "Microsoft.Office.OneNote"; Label = "OneNote"; Safe = $true },
        @{ Name = "Microsoft.MicrosoftStickyNotes"; Label = "Sticky Notes"; Safe = $true },
        @{ Name = "Microsoft.PowerAutomateDesktop"; Label = "Power Automate"; Safe = $true },
        @{ Name = "MicrosoftCorporationII.QuickAssist"; Label = "Quick Assist"; Safe = $true },
        @{ Name = "Microsoft.Getstarted"; Label = "Tips / Get Started"; Safe = $true },
        @{ Name = "Microsoft.549981C3F5F10"; Label = "Cortana"; Safe = $true }
    )
    "Maps & Navigation"           = @(
        @{ Name = "Microsoft.WindowsMaps"; Label = "Windows Maps"; Safe = $true },
        @{ Name = "Microsoft.WindowsAlarms"; Label = "Alarms & Clock"; Safe = $true },
        @{ Name = "Microsoft.WindowsFeedbackHub"; Label = "Feedback Hub"; Safe = $true }
    )
    "3D & Mixed Reality"          = @(
        @{ Name = "Microsoft.Microsoft3DViewer"; Label = "3D Viewer"; Safe = $true },
        @{ Name = "Microsoft.3DBuilder"; Label = "3D Builder"; Safe = $true },
        @{ Name = "Microsoft.MSPaint"; Label = "Paint 3D"; Safe = $true },
        @{ Name = "Microsoft.MixedReality.Portal"; Label = "Mixed Reality Portal"; Safe = $true },
        @{ Name = "Microsoft.Print3D"; Label = "Print 3D"; Safe = $true }
    )
    "Gaming (⚠ Caution)"          = @(
        @{ Name = "Microsoft.XboxApp"; Label = "Xbox App"; Safe = $false },
        @{ Name = "Microsoft.XboxGameOverlay"; Label = "Xbox Game Overlay"; Safe = $false },
        @{ Name = "Microsoft.XboxGamingOverlay"; Label = "Xbox Game Bar"; Safe = $false },
        @{ Name = "Microsoft.XboxIdentityProvider"; Label = "Xbox Identity Provider"; Safe = $false },
        @{ Name = "Microsoft.XboxSpeechToTextOverlay"; Label = "Xbox Speech-to-Text"; Safe = $false },
        @{ Name = "Microsoft.GamingApp"; Label = "Xbox Gaming App"; Safe = $false }
    )
    "Widgets & AI"                = @(
        @{ Name = "MicrosoftWindows.Client.WebExperience"; Label = "Windows Widgets"; Safe = $true },
        @{ Name = "Microsoft.Copilot"; Label = "Windows Copilot"; Safe = $true },
        @{ Name = "Microsoft.Windows.Ai.Copilot.Provider"; Label = "Copilot Provider"; Safe = $true },
        @{ Name = "Microsoft.WindowsCopilotRuntime"; Label = "Copilot Runtime"; Safe = $true }
    )
}

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
  ║        🧹🧹🧹  BLOAT REMOVER  🧹🧹🧹                      ║
  ║                                                              ║
  ║       Windows 11 — Pre-Installed App Cleanup                 ║
  ║                                                              ║
  ║       Remove the junk. Keep what matters.                    ║
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

# ══════════════════════════════════════════════════════════════════════════════
#                              MAIN EXECUTION
# ══════════════════════════════════════════════════════════════════════════════

Clear-Host
Write-Banner

Write-Log "═══════════════════════════════════════════════════"
Write-Log "Bloat Remover Started"
Write-Log "═══════════════════════════════════════════════════"

Write-Host "  This script removes pre-installed Windows 11 apps." -ForegroundColor White
Write-Host "  You can choose which categories to remove." -ForegroundColor DarkGray
Write-Host ""
Write-Host "  ⚠  Removed apps can be reinstalled from the Microsoft Store" -ForegroundColor Yellow
Write-Host "     if you change your mind." -ForegroundColor Yellow
Write-Host ""

# ─── Scan Installed Bloat ───────────────────────────────────────────────────
Write-Section "Scanning Installed Apps" "🔍"

$installedApps = Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue
$totalBloat = 0
$categoryResults = [ordered]@{}

foreach ($category in $bloatCategories.Keys) {
    $found = @()
    foreach ($app in $bloatCategories[$category]) {
        $match = $installedApps | Where-Object { $_.Name -like "*$($app.Name)*" }
        if ($match) {
            $found += @{ App = $app; Package = $match }
            $totalBloat++
        }
    }
    $categoryResults[$category] = $found
}

Write-Host "    📊 Found $totalBloat removable bloatware apps" -ForegroundColor Yellow
Write-Host ""

# ─── Interactive Category Menu ───────────────────────────────────────────────
Write-Section "Choose What to Remove" "📋"

Write-Host ""
Write-Host "  ┌──────────────────────────────────────────────────────────" -ForegroundColor DarkRed
Write-Host "  │  [A] Remove ALL bloatware (except Gaming)" -ForegroundColor Yellow
Write-Host "  │  [G] Remove ALL including Gaming/Xbox apps" -ForegroundColor Red
Write-Host "  │  [C] Choose by category" -ForegroundColor Yellow
Write-Host "  │  [Q] Quit — don't remove anything" -ForegroundColor DarkGray
Write-Host "  └──────────────────────────────────────────────────────────" -ForegroundColor DarkRed
Write-Host ""
Write-Host "  Choice: " -ForegroundColor Red -NoNewline
$mainChoice = Read-Host

if ($mainChoice -eq "Q" -or $mainChoice -eq "q") {
    Write-Host "`n  Cancelled. No apps removed." -ForegroundColor DarkGray
    exit
}

$categoriesToRemove = @()

if ($mainChoice -eq "A" -or $mainChoice -eq "a") {
    $categoriesToRemove = $bloatCategories.Keys | Where-Object { $_ -ne "Gaming (⚠ Caution)" }
}
elseif ($mainChoice -eq "G" -or $mainChoice -eq "g") {
    Write-Host ""
    Write-Host "  ⚠  WARNING: Removing Xbox Game Bar may break:" -ForegroundColor Yellow
    Write-Host "     • Win+G overlay" -ForegroundColor DarkGray
    Write-Host "     • Game capture/recording" -ForegroundColor DarkGray
    Write-Host "     • FPS counter overlay" -ForegroundColor DarkGray
    Write-Host "     • Some Xbox Live features" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Proceed? (Y/N): " -ForegroundColor Red -NoNewline
    $confirmGaming = Read-Host
    if ($confirmGaming -eq "Y" -or $confirmGaming -eq "y") {
        $categoriesToRemove = $bloatCategories.Keys
    }
    else {
        $categoriesToRemove = $bloatCategories.Keys | Where-Object { $_ -ne "Gaming (⚠ Caution)" }
    }
}
elseif ($mainChoice -eq "C" -or $mainChoice -eq "c") {
    # Per-category selection
    $catIndex = 1
    $catMap = @{}
    Write-Host ""
    foreach ($category in $bloatCategories.Keys) {
        $count = $categoryResults[$category].Count
        if ($count -gt 0) {
            $color = if ($category -match "Gaming") { "Yellow" } else { "White" }
            Write-Host "    [$catIndex] $category ($count apps found)" -ForegroundColor $color
            $catMap[$catIndex] = $category
        }
        else {
            Write-Host "    [$catIndex] $category (none installed)" -ForegroundColor DarkGray
            $catMap[$catIndex] = $category
        }
        $catIndex++
    }
    Write-Host ""
    Write-Host "  Enter category numbers to remove (comma-separated, e.g., 1,2,3): " -ForegroundColor Yellow -NoNewline
    $catChoices = Read-Host

    $selectedNums = $catChoices -split "," | ForEach-Object { $_.Trim() -as [int] } | Where-Object { $_ -gt 0 }
    foreach ($num in $selectedNums) {
        if ($catMap.ContainsKey($num)) {
            $categoriesToRemove += $catMap[$num]
        }
    }
}

# ─── Remove Selected Apps ───────────────────────────────────────────────────
$removedCount = 0
$failedCount = 0

foreach ($category in $categoriesToRemove) {
    $appsInCategory = $categoryResults[$category]
    if ($appsInCategory.Count -eq 0) { continue }

    Write-Section "Removing: $category" "🗑"

    foreach ($item in $appsInCategory) {
        $app = $item.App
        $packages = $item.Package

        foreach ($pkg in $packages) {
            try {
                # Remove for current user
                Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction Stop

                # Remove provisioned package (prevents reinstall on new users)
                $provisioned = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue |
                Where-Object { $_.DisplayName -like "*$($app.Name)*" }
                if ($provisioned) {
                    Remove-AppxProvisionedPackage -Online -PackageName $provisioned.PackageName -ErrorAction SilentlyContinue | Out-Null
                }

                Write-Host "    ✕ $($app.Label)" -ForegroundColor Red -NoNewline
                Write-Host " — Removed" -ForegroundColor DarkGray
                Write-Log "  [REMOVED] $($app.Label) ($($app.Name))"
                $removedCount++
            }
            catch {
                Write-Host "    ⚠ $($app.Label)" -ForegroundColor Yellow -NoNewline
                Write-Host " — Could not remove (system protected)" -ForegroundColor DarkGray
                Write-Log "  [FAILED] $($app.Label) — $($_.Exception.Message)"
                $failedCount++
            }
        }
    }
}

# ─── Disable Background Apps ────────────────────────────────────────────────
Write-Section "Disable Background Apps" "🔇"

$bgAppsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
if (Test-Path $bgAppsPath) {
    Set-ItemProperty -Path $bgAppsPath -Name "GlobalUserDisabled" -Value 1 -Type DWord -Force
    Write-Host "    🔇 Background app access disabled globally" -ForegroundColor Green
    Write-Log "  [APPLIED] Background apps disabled"
}

# Prevent removed apps from auto-reinstalling
$cdmPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
if (Test-Path $cdmPath) {
    Set-ItemProperty -Path $cdmPath -Name "SilentInstalledAppsEnabled" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $cdmPath -Name "ContentDeliveryAllowed" -Value 0 -Type DWord -Force
    Write-Host "    🔇 Silent app reinstallation blocked" -ForegroundColor Green
    Write-Log "  [APPLIED] Silent app installs blocked"
}

# ══════════════════════════════════════════════════════════════════════════════
#                           COMPLETION SUMMARY
# ══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Red
Write-Host "  ║                                                              ║" -ForegroundColor Red
Write-Host "  ║   ✅  BLOAT REMOVED!                                        ║" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Red
Write-Host "  ║   🗑  Removed:   $removedCount apps" -ForegroundColor Red
Write-Host "  ║   ⚠  Protected: $failedCount apps (could not remove)" -ForegroundColor Red
Write-Host "  ║   🔇  Background apps disabled                              ║" -ForegroundColor Red
Write-Host "  ║   🔇  Silent reinstall blocked                              ║" -ForegroundColor Red
Write-Host "  ║                                                              ║" -ForegroundColor Red
Write-Host "  ║   📄 Log: $LogFile" -ForegroundColor Red
Write-Host "  ║                                                              ║" -ForegroundColor Red
Write-Host "  ║   💡 Removed apps can be reinstalled from Microsoft Store   ║" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Red
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Red
Write-Host ""

Write-Log "Bloat Remover Done — Removed: $removedCount, Failed: $failedCount"

Write-Host "  Press Enter to exit..." -ForegroundColor DarkGray
Read-Host
