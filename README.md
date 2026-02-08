# ⚡ Windows Elite Optimizer

> **23 PowerShell scripts that unlock maximum performance, privacy, and control from your Windows 11 machine.**

![Windows 11](https://img.shields.io/badge/Windows-11-0078D4?style=for-the-badge&logo=windows11&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-5171A5?style=for-the-badge&logo=powershell&logoColor=white)
![Scripts](https://img.shields.io/badge/Scripts-23-orange?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

---

## 🎯 What Is This?

A comprehensive suite of **23 PowerShell optimization scripts** covering everything from power plans and GPU tuning to privacy hardening and bloatware removal. Every script self-elevates to Administrator, creates restore points where applicable, and provides clear output on every change.

**Full scripts** = interactive menus with choices per setting.  
**Lite scripts** = instant auto-apply of recommended settings, no prompts.

---

## 🚀 Quick Start — Run Any Script

### Prerequisites
- **Windows 11** (any edition)
- **Administrator access** (scripts self-elevate automatically)
- **PowerShell 5.1+** (included with Windows 11)

> **Open PowerShell as Admin**: Press `Win+X` → **Terminal (Admin)** or **PowerShell (Admin)**

> **🛡 Safety**: Scripts that modify system settings create a **System Restore Point** before making changes. You can always revert.

---

### ⚡ Performance

```powershell
# Elite Performance — Maximum power, all cores on, zero idle (desktops)
Set-ExecutionPolicy Bypass -Scope Process -Force; cd "$HOME\Downloads\Windows-Elite-Optimizer"; .\ElitePerformance.ps1
```

```powershell
# Pro Performance — Balanced power, safe for laptops
Set-ExecutionPolicy Bypass -Scope Process -Force; cd "$HOME\Downloads\Windows-Elite-Optimizer"; .\ProPerformance.ps1
```

```powershell
# Restore Defaults — Undo all Elite/Pro changes
Set-ExecutionPolicy Bypass -Scope Process -Force; cd "$HOME\Downloads\Windows-Elite-Optimizer"; .\RestoreDefaults.ps1
```

---

### 🎮 Gaming

```powershell
# Game Booster — Kill bloat, boost game priority, auto-restore on exit
Set-ExecutionPolicy Bypass -Scope Process -Force; cd "$HOME\Downloads\Windows-Elite-Optimizer"; .\GameBooster.ps1
```

```powershell
# Game Booster Lite — Quick pre-game boost, no monitoring
Set-ExecutionPolicy Bypass -Scope Process -Force; cd "$HOME\Downloads\Windows-Elite-Optimizer"; .\GameBoosterLite.ps1
```

```powershell
# GPU Optimizer — NVIDIA/AMD auto-detect, per-setting control
Set-ExecutionPolicy Bypass -Scope Process -Force; cd "$HOME\Downloads\Windows-Elite-Optimizer"; .\GPUOptimizer.ps1
```

```powershell
# GPU Optimizer Lite — Quick GPU fix, best settings applied instantly
Set-ExecutionPolicy Bypass -Scope Process -Force; cd "$HOME\Downloads\Windows-Elite-Optimizer"; .\GPUOptimizerLite.ps1
```

```powershell
# Mouse Optimizer — 6-step input latency reduction, eDPI calculator
Set-ExecutionPolicy Bypass -Scope Process -Force; cd "$HOME\Downloads\Windows-Elite-Optimizer"; .\MouseOptimizer.ps1
```

```powershell
# Mouse Optimizer Lite — Instant acceleration off + 1:1 speed
Set-ExecutionPolicy Bypass -Scope Process -Force; cd "$HOME\Downloads\Windows-Elite-Optimizer"; .\MouseOptimizerLite.ps1
```

```powershell
# Latency Monitor — Real-time DPC/ISR monitoring + driver analysis
Set-ExecutionPolicy Bypass -Scope Process -Force; cd "$HOME\Downloads\Windows-Elite-Optimizer"; .\LatencyMonitor.ps1
```

```powershell
# Latency Monitor Lite — Quick 15-second latency check
Set-ExecutionPolicy Bypass -Scope Process -Force; cd "$HOME\Downloads\Windows-Elite-Optimizer"; .\LatencyMonitorLite.ps1
```

---

### 🌐 Network

```powershell
# Network Optimizer — Interactive 8-step network tuning
Set-ExecutionPolicy Bypass -Scope Process -Force; cd "$HOME\Downloads\Windows-Elite-Optimizer"; .\NetworkOptimizer.ps1
```

```powershell
# Network Optimizer Recommended — Auto-apply best network settings
Set-ExecutionPolicy Bypass -Scope Process -Force; cd "$HOME\Downloads\Windows-Elite-Optimizer"; .\NetworkOptimizerRecommended.ps1
```

---

### 🛡 Privacy & Updates

```powershell
# Privacy Lockdown — Full 10-category privacy hardening
Set-ExecutionPolicy Bypass -Scope Process -Force; cd "$HOME\Downloads\Windows-Elite-Optimizer"; .\PrivacyLockdown.ps1
```

```powershell
# Privacy Lockdown Lite — Quick telemetry/ads/Cortana disable
Set-ExecutionPolicy Bypass -Scope Process -Force; cd "$HOME\Downloads\Windows-Elite-Optimizer"; .\PrivacyLockdownLite.ps1
```

```powershell
# Windows Update Control — 7-category update management
Set-ExecutionPolicy Bypass -Scope Process -Force; cd "$HOME\Downloads\Windows-Elite-Optimizer"; .\WindowsUpdateControl.ps1
```

```powershell
# Windows Update Control Lite — Quick update deferrals
Set-ExecutionPolicy Bypass -Scope Process -Force; cd "$HOME\Downloads\Windows-Elite-Optimizer"; .\WindowsUpdateControlLite.ps1
```

---

### 🧹 Cleanup & Maintenance

```powershell
# Bloat Remover — Remove 60+ pre-installed Windows apps
Set-ExecutionPolicy Bypass -Scope Process -Force; cd "$HOME\Downloads\Windows-Elite-Optimizer"; .\BloatRemover.ps1
```

```powershell
# Temp Cleaner — Deep temp/cache cleanup, shows space recovered
Set-ExecutionPolicy Bypass -Scope Process -Force; cd "$HOME\Downloads\Windows-Elite-Optimizer"; .\TempCleaner.ps1
```

```powershell
# Startup Manager — Interactive startup optimizer with safety ratings
Set-ExecutionPolicy Bypass -Scope Process -Force; cd "$HOME\Downloads\Windows-Elite-Optimizer"; .\StartupManager.ps1
```

```powershell
# Startup Manager Lite — Auto-disable known bloatware startups
Set-ExecutionPolicy Bypass -Scope Process -Force; cd "$HOME\Downloads\Windows-Elite-Optimizer"; .\StartupManagerLite.ps1
```

---

### ☁ App Removal

```powershell
# Remove OneDrive — Complete wipe (⚠ IRREVERSIBLE)
Set-ExecutionPolicy Bypass -Scope Process -Force; cd "$HOME\Downloads\Windows-Elite-Optimizer"; .\RemoveOneDrive.ps1
```

```powershell
# Remove Outlook — Complete wipe (⚠ IRREVERSIBLE)
Set-ExecutionPolicy Bypass -Scope Process -Force; cd "$HOME\Downloads\Windows-Elite-Optimizer"; .\RemoveOutlook.ps1
```

> **💡 Custom install location?** Replace `$HOME\Downloads\Windows-Elite-Optimizer` with the path where you cloned/downloaded the repo.

---

## 📁 Complete Script Summary

> Every script **self-elevates** to Administrator, logs all changes to `%USERPROFILE%\<ScriptName>_log.txt`, and — where applicable — creates a **System Restore Point** before modifying anything.

---

### ⚡ Performance Scripts

#### `ElitePerformance.ps1` — Maximum Performance Preset

| | |
|---|---|
| **Type** | Full (interactive) |
| **Best for** | Dedicated gaming desktops with good cooling |
| **Creates restore point** | ✅ Yes |
| **Restart required** | No (instant) |

Builds a custom **"Elite Performance"** power plan based on Windows' hidden Ultimate Performance scheme, then pushes every setting to the extreme:

- **CPU**: 100% minimum processor state, zero core parking, aggressive turbo boost, idle states disabled
- **Memory**: Disables Superfetch/SysMain, Prefetch, and memory compression
- **Network**: Disables Nagle's algorithm on all adapters for lower packet latency
- **Services**: Stops and disables 10 background services (SysMain, DiagTrack, WSearch, Connected User Experiences, WAP Push, dmwappushservice, Remote Registry, Fax, Print Spooler if no printers, Retail Demo)
- **Visual effects**: Turns off all Windows animations, shadows, transparency, and smooth-scrolling
- **Telemetry**: Disables diagnostics tracking, Cortana, Advertising ID
- **Foreground priority**: Sets `Win32PrioritySeparation` to `0x26` (3× foreground boost)
- **Storage**: Disables NTFS 8.3 short-name generation and last access timestamps

---

#### `ProPerformance.ps1` — Balanced Performance Preset

| | |
|---|---|
| **Type** | Full (interactive) |
| **Best for** | Laptops, daily-driver PCs, mixed-use machines |
| **Creates restore point** | ✅ Yes |
| **Restart required** | No (instant) |

Same optimizations as Elite but with **safety margins** for everyday use:

- **CPU**: 5% minimum state (allows idle), 50% minimum core parking, turbo boost enabled
- **Power management**: Sleep after 30 min, display off after 15 min (preserved, not disabled)
- **Memory**: Disables Superfetch/Prefetch but keeps memory compression ON
- **Services**: Disables 6 services instead of 10 (skips Print Spooler, Remote Registry, Fax, Retail Demo)
- **Visual effects**: Reduced but keeps ClearType and smooth scrolling for readability
- **Network & telemetry**: Same as Elite (Nagle disabled, telemetry off)

---

#### `RestoreDefaults.ps1` — Undo Everything

| | |
|---|---|
| **Type** | Restore tool |
| **Best for** | Reverting any Elite or Pro changes |
| **Creates restore point** | ✅ Yes |
| **Restart required** | Reboot recommended |

Completely reverses **all** changes made by ElitePerformance or ProPerformance:

- Removes custom power plans ("Elite Performance" / "Pro Performance") and reactivates the **Balanced** plan
- Re-enables and starts all 10 disabled services
- Restores default visual effects and Windows animation settings
- Re-enables Superfetch/SysMain, Prefetch, and memory compression
- Re-enables Nagle's algorithm on all network adapters
- Restores default NTFS settings, `Win32PrioritySeparation`, and foreground priority

---

### 🎮 Gaming Scripts

#### `GameBooster.ps1` — Per-Game Performance Mode

| | |
|---|---|
| **Type** | Full (interactive, with game monitor) |
| **Best for** | Running before any gaming session |
| **Creates restore point** | No (temporary changes only) |
| **Restart required** | No — auto-restores when game closes |

An 8-phase gaming optimizer that **automatically restores everything** when your game exits:

1. **Phase 1 – Clear Memory**: Trims all process working sets and flushes the file system cache using Win32 `EmptyWorkingSet`, freeing standby RAM for texture streaming
2. **Phase 2 – Kill Bloat**: Terminates 24 background processes (Edge, Teams, Spotify, Discord updater, OneDrive, Google Drive, Dropbox, Corsair iCUE, Nahimic Audio, Waves MaxxAudio, Windows Search, Phone Link, Widgets, Adobe services, Java updater, NVIDIA Share/Telemetry)
3. **Phase 3 – Pause Services**: Temporarily stops SysMain, Windows Search Indexer, Diagnostics Tracking, and Windows Update
4. **Phase 4 – Flush Network**: Flushes DNS/ARP caches, resets IP stack and Winsock, disables Nagle's algorithm on all adapters
5. **Phase 5 – Power Plan**: Switches to Ultimate Performance (or High Performance fallback)
6. **Phase 6 – GPU Priority**: Sets `GPU Priority=8`, `SFIO Priority=High` in the Windows multimedia scheduler for the "Games" task
7. **Phase 7 – Game Monitor**: Optionally waits for your game process (`cs2`, `valorant`, etc.), sets its priority to **High**, and pins it to P-cores on Intel hybrid CPUs (cores 0–7 via affinity mask `0xFF`)
8. **Phase 8 – Auto-Restore**: When the game exits, restarts killed apps (Spotify, Discord), resumes all paused services, and switches the power plan back to Balanced

---

#### `GameBoosterLite.ps1` — Quick Pre-Game Boost

| | |
|---|---|
| **Type** | Lite (no prompts, instant) |
| **Best for** | Quick boost before launching a game |
| **Creates restore point** | No |
| **Restart required** | No — services restore on reboot |

A stripped-down version of GameBooster with **no game monitoring or auto-restore**:

- Kills 21 background processes (same list minus NVIDIA Share and Telemetry entries from the full version)
- Pauses 3 services (SysMain, WSearch, DiagTrack — excludes Windows Update)
- Clears standby memory via working set trimming
- Flushes DNS cache
- Switches power plan to Ultimate Performance (High Performance fallback)
- **Does NOT** set CPU affinity, game priority, or auto-restore — reboot or run `RestoreDefaults.ps1` to undo

---

#### `GPUOptimizer.ps1` — Per-GPU Performance Tuning

| | |
|---|---|
| **Type** | Full (interactive, per-setting choices) |
| **Best for** | Fine-tuning GPU settings for competitive gaming |
| **Creates restore point** | ✅ Yes |
| **Restart required** | ⚠ Yes for HAGS and MPO changes |

Auto-detects your GPU vendor (NVIDIA, AMD, or Intel) and provides **vendor-specific** tuning options plus universal Windows settings:

- **NVIDIA settings** (via registry): Power Management mode (Max Performance), Threaded Optimization (Off for lower latency), Low Latency Mode (Ultra/Reflex), Texture Filtering quality, global VSync (On/Off), Shader Cache size (Unlimited/10 GB/Default)
- **AMD settings** (via registry): Radeon Anti-Lag (enabled), Enhanced Sync (disabled to reduce stutter), Tessellation mode (application-controlled), ULPS (Ultra Low Power State — disabled to prevent downclocking), Surface Format optimization, Shader Cache (enabled)
- **Universal settings**: Disables Multi-Plane Overlay (MPO — fixes stuttering in many games), enables/disables Hardware-Accelerated GPU Scheduling (HAGS), enables Game Mode, disables Fullscreen Optimizations (FSO) for true exclusive fullscreen, disables Game DVR/Game Bar recording

---

#### `GPUOptimizerLite.ps1` — Quick GPU Fix

| | |
|---|---|
| **Type** | Lite (no prompts, instant) |
| **Best for** | Applying all recommended GPU settings at once |
| **Creates restore point** | No |
| **Restart required** | ⚠ Yes for HAGS and MPO changes |

Auto-detects your GPU and instantly applies **all recommended settings** without prompts:

- **NVIDIA**: Max power, Ultra low latency, Threaded Optimization off
- **AMD**: Anti-Lag on, ULPS disabled, Shader Cache enabled
- **Universal**: MPO off, HAGS on, Game Mode on, Fullscreen Optimizations off, Game DVR off
- Applies all changes in one pass — no interactive menus

---

#### `MouseOptimizer.ps1` — Input Latency Reduction

| | |
|---|---|
| **Type** | Full (interactive, 6-step wizard) |
| **Best for** | Competitive FPS gamers who want pixel-perfect aim |
| **Creates restore point** | No |
| **Restart required** | ⚠ Log out/in required |

A 6-step interactive mouse tuning wizard:

1. **Acceleration**: Disables Enhance Pointer Precision (`MouseSpeed=0`, `Threshold1/2=0`) and writes flat 1:1 `SmoothMouseX/YCurve` byte arrays — eliminating the speed-dependent multiplier
2. **Pointer Speed**: Sets to `10/20` (6/11 in Control Panel slider) — the **only** value that gives true 1:1 sensor-to-pixel mapping without any Windows multiplier
3. **Visual Effects**: Removes pointer trails, snap-to-default button, cursor shadow, and show-pointer-while-typing
4. **Raw Input**: Sets mouse hover delay to 0ms, minimizes touch prediction latency, disables gesture/contact visualization, routes mouse wheel directly to foreground window
5. **USB Polling Rate**: Detects connected HID mouse devices, shows polling rate table (125 Hz–8000 Hz), disables USB Selective Suspend to prevent the mouse from sleeping, disables USB power saving in the active power plan, and sets MMCSS `SystemResponsiveness` to 0
6. **eDPI Calculator**: Enter your mouse DPI + in-game sensitivity → calculates effective DPI and compares to pro player ranges (Valorant 200–400, CS2 600–1000, Apex 800–1600)

---

#### `MouseOptimizerLite.ps1` — Quick Mouse Fix

| | |
|---|---|
| **Type** | Lite (no prompts, instant) |
| **Best for** | Instantly fixing mouse input without menus |
| **Creates restore point** | No |
| **Restart required** | ⚠ Log out/in required |

Instantly applies the most impactful mouse settings without any prompts:

- Disables acceleration with flat 1:1 `SmoothMouse` curves
- Sets pointer speed to 10/20 (true 1:1)
- Removes trails, snap-to-default, and cursor shadow
- Sets hover delay to 0ms, wheel routing to direct-to-foreground
- Disables USB Selective Suspend and USB power saving
- **Does NOT** include DPI calculator or polling rate guidance

---

#### `LatencyMonitor.ps1` — DPC/ISR Latency Checker

| | |
|---|---|
| **Type** | Full (interactive, configurable duration) |
| **Best for** | Diagnosing audio crackling, mouse stuttering, or frame drops |
| **Creates restore point** | No (read-only, no system changes) |
| **Restart required** | No |

A comprehensive **system latency analysis** tool (does NOT modify anything — diagnostic only):

1. **Timer Resolution**: Queries `NtQueryTimerResolution` to show current, minimum, and maximum timer resolution in milliseconds — flags if above 1ms
2. **DPC/ISR Monitoring**: Samples `%DPC Time` and `%Interrupt Time` performance counters every second for a configurable duration (15s/30s/60s/custom) with a **live visual bar** — reports average, peak, and minimum for both
3. **Driver Analysis**: Scans all running `Win32_SystemDriver` instances against a database of **30+ known problematic drivers** (GPU: `nvlddmkm.sys`, `amdkmdag.sys`; Network: `ndis.sys`, `Netwtw10.sys`; Audio: `HDAudBus.sys`, `portcls.sys`; USB: `USBXHCI.sys`; Power: `intelppm.sys`, `amdppm.sys`; etc.) with **specific fix recommendations** per driver
4. **Device Check**: Lists any PnP devices in error state, shows active audio endpoints and recommends disabling unused ones
5. **Network Latency**: Optional multi-target ping test (Cloudflare, Google, AWS, Quad9) with average, min/max, and **jitter** calculation
6. **Recommendations**: Context-aware tips based on results (suggests GPUOptimizer, driver updates, ISLC, Ethernet, GameBooster)

---

#### `LatencyMonitorLite.ps1` — Quick Latency Check

| | |
|---|---|
| **Type** | Lite (no prompts, fixed 15-second scan) |
| **Best for** | Quick health check before a gaming session |
| **Creates restore point** | No (read-only, no system changes) |
| **Restart required** | No |

A fast 15-second latency check with automatic driver scan:

- Monitors DPC/ISR for 15 seconds with a live visual bar (no configurable duration)
- Auto-scans running drivers against a database of **18 known problematic drivers** with quick fix descriptions
- Rates system as Excellent (<2% DPC, <1% ISR), Fair, or High latency
- **Does NOT** query timer resolution, test network latency, or check for devices in error state

---

### 🌐 Network Scripts

#### `NetworkOptimizer.ps1` — Interactive Network Tuning

| | |
|---|---|
| **Type** | Full (interactive, 8-step wizard) |
| **Best for** | Users who want per-setting control over their network |
| **Creates restore point** | ✅ Yes |
| **Restart required** | ⚠ May need restart for some changes |

An 8-step interactive wizard covering every aspect of Windows network configuration:

1. **DNS Provider**: Choose from Cloudflare (1.1.1.1), Google (8.8.8.8), Quad9 (9.9.9.9), OpenDNS (208.67.222.222), or enter custom DNS — sets via `Set-DnsClientServerAddress`
2. **TCP Optimization**: Disable Nagle's algorithm (`TcpAckFrequency=1, TCPNoDelay=1` on all interfaces), configure TCP Window Auto-Tuning (Normal/Disabled/Restricted), enable RSS (Receive-Side Scaling), enable Direct Cache Access, disable TCP Timestamps, configure ECN
3. **MTU Detection**: Automated MTU size testing via `ping -f` fragmentation tests from 1500 down, finding the optimal payload size and setting it on the active adapter via `netsh`
4. **Bandwidth & QoS**: Removes Windows' default 20% QoS bandwidth reservation (`NonBestEffortLimit=0`), disables `NetworkThrottlingIndex` for unlimited throughput, sets `SystemResponsiveness=0` for gaming priority
5. **Wi-Fi Sense**: Disables auto-connect to suggested networks, disables Hotspot 2.0, disables Wi-Fi auto-switching
6. **Adapter Settings**: Per-adapter optimizations — disable power management (prevents disconnects), disable Energy Efficient Ethernet (EEE), optionally disable Interrupt Moderation (lower latency, slightly higher CPU), disable Flow Control
7. **Cache Flush**: Flushes DNS, ARP, NetBIOS, and resets Winsock catalog
8. **Latency Test**: Optional ping test to Cloudflare, Google, and Quad9 with average, min/max, and color-coded results

---

#### `NetworkOptimizerRecommended.ps1` — Auto Network Fix

| | |
|---|---|
| **Type** | Lite (no prompts, instant) |
| **Best for** | Applying all recommended network settings at once |
| **Creates restore point** | No |
| **Restart required** | ⚠ May need restart for some changes |

Instantly applies our recommended settings — no menus, no choices:

- DNS → Cloudflare (1.1.1.1 / 1.0.0.1) on the active adapter
- Nagle's Algorithm → disabled on all interfaces
- TCP Auto-Tuning → Normal, RSS → Enabled, Timestamps → Off, DCA → Enabled
- QoS Bandwidth Reserve → removed (100% available), Network Throttling → disabled
- SystemResponsiveness → 0 (gaming priority)
- Wi-Fi Sense → disabled
- Flushes DNS, ARP, NetBIOS caches and resets Winsock
- Applies ~13 settings total in one pass

---

### 🛡 Privacy & Update Scripts

#### `PrivacyLockdown.ps1` — Full Privacy Hardening

| | |
|---|---|
| **Type** | Full (interactive, 10-category wizard) |
| **Best for** | Users who want comprehensive privacy control |
| **Creates restore point** | ✅ Yes |
| **Restart required** | No |

Disables telemetry and tracking across **10 categories**:

1. **Telemetry**: Sets `AllowTelemetry=0`, stops DiagTrack service, disables Connected User Experiences
2. **Activity History**: Disables local and cloud activity history, blocks timeline upload
3. **Clipboard**: Disables cloud clipboard sync across devices
4. **Location**: Blocks background location access for all apps
5. **Camera/Microphone**: Blocks background camera and mic access
6. **Find My Device**: Disables device tracking/locating
7. **Advertising ID**: Resets and disables the Windows Advertising ID
8. **Cortana/Copilot**: Fully disables both Cortana and Windows Copilot
9. **Typing/Inking**: Disables keystroke data collection and personalization
10. **Hosts File**: Blocks 40+ Microsoft tracking domains by adding them to `C:\Windows\System32\drivers\etc\hosts`

---

#### `PrivacyLockdownLite.ps1` — Quick Privacy Fix

| | |
|---|---|
| **Type** | Lite (no prompts, instant) |
| **Best for** | Quickly disabling the most invasive tracking |
| **Creates restore point** | No |
| **Restart required** | No |

Applies the **5 most impactful** privacy settings instantly:

- Telemetry → disabled (`AllowTelemetry=0`, DiagTrack stopped)
- Advertising ID → disabled
- Cortana/Copilot → fully disabled
- Activity History → disabled
- Feedback Notifications → off
- **Does NOT** modify the hosts file, block camera/location, or touch clipboard sync

---

#### `WindowsUpdateControl.ps1` — Full Update Control

| | |
|---|---|
| **Type** | Full (interactive, 7-category wizard) |
| **Best for** | Users who want fine-grained update management |
| **Creates restore point** | ✅ Yes |
| **Restart required** | No |

Configures Windows Update behavior across **7 categories** via Group Policy registry keys:

1. **Active Hours**: Sets to 10:00 AM – 2:00 AM (prevents restarts during gaming hours)
2. **Feature Updates**: Deferred by 30 days
3. **Quality Updates**: Deferred by 7 days
4. **Auto-Restart**: Blocked during active hours, no forced restarts
5. **P2P Delivery Optimization**: Disabled (stops Windows from uploading updates to other PCs)
6. **Driver Updates**: Excluded from Windows Update (prevents GPU driver auto-downgrades)
7. **Update Notifications**: Suppressed

---

#### `WindowsUpdateControlLite.ps1` — Quick Update Control

| | |
|---|---|
| **Type** | Lite (no prompts, instant) |
| **Best for** | Quick protection from unwanted updates and restarts |
| **Creates restore point** | No |
| **Restart required** | No |

Applies the 4 most important update settings instantly:

- Feature updates deferred 30 days
- Quality updates deferred 7 days
- Auto-restart blocked
- P2P Delivery Optimization disabled
- **Does NOT** change active hours or exclude driver updates

---

### 🧹 Cleanup & Maintenance Scripts

#### `BloatRemover.ps1` — Windows 11 Bloatware Removal

| | |
|---|---|
| **Type** | Full (interactive, per-category choices) |
| **Best for** | Fresh Windows installs or cleaning up a cluttered system |
| **Creates restore point** | No (app removal only) |
| **Restart required** | No |

Scans for **60+ pre-installed Windows 11 apps** across 8 categories and lets you remove them:

- **Communication & Social**: People, Mail & Calendar, Skype, Teams (Personal), Phone Link, Microsoft To Do
- **Entertainment & Media**: Groove Music, Movies & TV, Solitaire, Clipchamp, Facebook, TikTok, Instagram, and more
- **News & Information**: Bing News, Weather, Finance, Sports, Maps, Tips, Cortana, and more
- **Productivity / Office Stubs**: Office Hub, OneNote, Sticky Notes, Power Automate
- **Maps & Navigation**: Windows Maps, Alarms & Clock, Feedback Hub, Get Help
- **3D & Mixed Reality**: 3D Viewer, Paint 3D, Mixed Reality Portal
- **Gaming** ⚠: Xbox Game Bar, Xbox Overlay, Xbox Speech-to-Text (warns about breaking Win+G)
- **Widgets & AI**: Windows Widgets, Copilot, Copilot Provider, Copilot Runtime

Removal modes: **[A]** remove all except gaming, **[G]** remove all including gaming, **[C]** choose by category. Also blocks silent reinstallation and disables global background app access.

---

#### `TempCleaner.ps1` — Deep Temp & Cache Cleanup

| | |
|---|---|
| **Type** | Full (interactive) |
| **Best for** | Recovering disk space and clearing stale caches |
| **Creates restore point** | No |
| **Restart required** | No |

Scans and cleans temporary files from **20+ locations**:

- Windows Temp (`C:\Windows\Temp`), User Temp (`%TEMP%`)
- Browser caches: Chrome, Firefox, Edge (LocalState, Cache, Code Cache)
- GPU shader caches: NVIDIA (`GLCache`), AMD (`VkCache`), DirectX (`D3DSCache`)
- Windows Update cache (`SoftwareDistribution\Download`)
- Thumbnail cache (`explorer` thumbnails database)
- Prefetch files (`C:\Windows\Prefetch`)
- Recycle Bin (all drives)
- Shows **pre-scan sizes** for each category and a final **"Recovered X.XX GB"** summary

---

#### `StartupManager.ps1` — Interactive Startup Optimizer

| | |
|---|---|
| **Type** | Full (interactive menu) |
| **Best for** | Auditing and controlling what runs at boot |
| **Creates restore point** | No |
| **Restart required** | No |

Scans all startup programs from registry (`HKCU/HKLM\...\Run`) and `shell:startup` folders, then provides:

- **Safety ratings**: 🟢 Safe to disable (Teams, Spotify, Discord updater), 🟡 Caution (Realtek Audio, Steam), 🔴 Do NOT disable (GPU drivers, antivirus)
- **Interactive toggle**: Enable or disable specific items by number
- **Auto-disable mode**: One-click disable of 20+ known bloatware startup entries
- **Review disabled items**: See what's already been disabled

---

#### `StartupManagerLite.ps1` — Quick Startup Fix

| | |
|---|---|
| **Type** | Lite (no prompts, instant) |
| **Best for** | Instantly cleaning up startup without reviewing each item |
| **Creates restore point** | No |
| **Restart required** | No |

Instantly disables **20+ known bloatware startup entries** without showing a menu:

- Microsoft Teams, Spotify, Discord (updater), Adobe Creative Cloud, OneDrive, Skype, Cortana, Microsoft Edge (updater), Java Updater, and more
- Scans both HKCU and HKLM Run keys plus the Startup folder
- Reports count of items disabled

---

### ☁ App Removal Scripts

#### `RemoveOneDrive.ps1` — Complete OneDrive Wipe

| | |
|---|---|
| **Type** | Removal (interactive confirmation) |
| **Best for** | Users who don't use OneDrive and want it completely gone |
| **Creates restore point** | No |
| **Restart required** | No |

> ⚠ **IRREVERSIBLE** — Back up your OneDrive folder first. Cloud sync cannot be restored.

Fully removes Microsoft OneDrive from every trace on the system:

- Kills OneDrive processes and uninstalls via both `winget` and `OneDriveSetup.exe /uninstall`
- Removes **9 hidden data folders** (AppData Local, Roaming, ProgramData, etc.)
- Removes Explorer sidebar integration (CLSID namespace entry)
- Removes context menu entries ("Share with OneDrive", "Move to OneDrive")
- Removes sync icon overlays from Explorer
- Removes scheduled tasks and startup entries
- Blocks reinstallation via Group Policy (`DisableFileSyncNGSC=1`)

---

#### `RemoveOutlook.ps1` — Complete Outlook Wipe

| | |
|---|---|
| **Type** | Removal (interactive confirmation) |
| **Best for** | Users who use a different email client |
| **Creates restore point** | No |
| **Restart required** | No |

> ⚠ **IRREVERSIBLE** — Export your emails, contacts, and calendar data BEFORE running.

Removes both the new UWP Outlook and classic Office Outlook:

- Kills Outlook processes and removes UWP app packages
- Clears classic Outlook email profiles from `HKCU\Software\Microsoft\Office\...\Outlook\Profiles`
- Wipes **12+ data locations** (PST/OST files, offline cache, RoamCache, Outlook Data)
- Removes protocol handlers (`mailto:`, `outlook:`, `outlookaccounts:`)
- Removes Outlook-related scheduled tasks and telemetry
- Blocks silent reinstallation

---

## 📖 Detailed Script Documentation

### ⚡ ElitePerformance.ps1 — Maximum Performance Preset

**What it does**: Creates a custom power plan based on Ultimate Performance, disables CPU idle states, parks zero cores, forces 100% min processor state, disables Superfetch/Prefetch, turns off memory compression, disables Nagle's algorithm, kills background telemetry, disables all visual effects, and optimizes NTFS settings.

**Best for**: Dedicated gaming desktops with good cooling.

```powershell
# Run the script
Set-ExecutionPolicy Bypass -Scope Process -Force
.\ElitePerformance.ps1

# What you'll see:
#   ✓ System Restore point created
#   ✓ "Elite Performance" power plan created and activated
#   ✓ CPU set to 100% min state, all cores unparked
#   ✓ CPU idle states disabled
#   ✓ Memory compression OFF, Superfetch OFF, Prefetch OFF
#   ✓ Nagle's algorithm disabled on all adapters
#   ✓ Win32PrioritySeparation set to 0x26 (3x foreground boost)
#   ✓ 10 background services disabled
#   ✓ All visual effects disabled
#   ✓ Telemetry + Cortana + Advertising ID disabled
#   ✓ NTFS 8.3 names disabled, last access time off
```

**Verify it worked:**
```powershell
# Check power plan is active
powercfg /list
# You should see "Elite Performance *" (asterisk = active)

# Check services
Get-Service SysMain, DiagTrack | Format-Table Name, Status
# Both should show "Stopped"
```

---

### ⚡ ProPerformance.ps1 — Balanced Performance Preset

**What it does**: Same optimizations as Elite but with safety margins — CPU can idle to save power, keeps some visual effects for readability, preserves sleep/display timeout, and disables 6 services instead of 10.

**Best for**: Laptops, daily-driver PCs, and mixed-use machines.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\ProPerformance.ps1

# What you'll see:
#   ✓ "Pro Performance" power plan created (based on High Performance)
#   ✓ CPU min state 5% (can idle), core parking 50% min
#   ✓ Sleep: 30 min, Display: 15 min
#   ✓ Superfetch OFF, Prefetch OFF
#   ✓ Nagle's algorithm disabled
#   ✓ 6 background services disabled
#   ✓ Reduced visual effects (keeps ClearType + smooth scrolling)
#   ✓ Telemetry disabled
```

| | ⚡ Elite | 🏆 Pro | 📦 Default Windows |
|---|---|---|---|
| **CPU Min State** | 100% (always max) | 5% (can idle) | 5% |
| **Core Parking** | All cores ON | 50% min | 10-50% |
| **Memory Compression** | OFF | ON | ON |
| **Sleep** | Never | 30 min | 30 min |
| **Visual Effects** | All OFF | Reduced | All ON |
| **Services Disabled** | 10 | 6 | 0 |

---

### 🔄 RestoreDefaults.ps1 — Undo Everything

**What it does**: Completely reverses all changes made by ElitePerformance or ProPerformance — removes custom power plans, re-enables services, restores visual effects, re-enables Superfetch/Prefetch, and restores default registry values.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\RestoreDefaults.ps1

# What you'll see:
#   ✓ Custom power plans removed
#   ✓ "Balanced" plan re-activated
#   ✓ All 10 services re-enabled and started
#   ✓ Visual effects restored to default
#   ✓ Memory compression ON
#   ✓ Superfetch/Prefetch ON
#   ✓ Nagle's algorithm re-enabled
#   ✓ NTFS settings restored
```

---

### ☁ RemoveOneDrive.ps1 — Complete OneDrive Wipe

**What it does**: Fully removes Microsoft OneDrive — the application, all hidden data folders (9 locations), Explorer sidebar integration, context menus, icon overlays, startup entries, and blocks reinstallation via Group Policy.

> **⚠ IRREVERSIBLE** — Back up your OneDrive folder first. Cloud sync cannot be restored after this.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\RemoveOneDrive.ps1

# What you'll see:
#   ✓ OneDrive process killed
#   ✓ Application uninstalled (winget + OneDriveSetup.exe /uninstall)
#   ✓ 9 hidden data folders removed
#   ✓ Explorer sidebar entry removed
#   ✓ Context menu entries removed ("Share with OneDrive")
#   ✓ Sync icon overlays removed
#   ✓ Scheduled tasks removed
#   ✓ Reinstallation blocked via Group Policy
```

---

### 📧 RemoveOutlook.ps1 — Complete Outlook Wipe

**What it does**: Removes both the new UWP Outlook and classic Office Outlook — application packages, email profiles, PST/OST files, offline cache, telemetry logs, protocol handlers (`mailto:`, `outlook:`), and blocks reinstallation.

> **⚠ IRREVERSIBLE** — Export your emails, contacts, and calendar data BEFORE running this.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\RemoveOutlook.ps1

# What you'll see:
#   ✓ Outlook processes killed
#   ✓ New Outlook UWP package removed
#   ✓ Classic Outlook profiles cleared
#   ✓ 12+ data locations wiped
#   ✓ Protocol handlers removed
#   ✓ Telemetry tasks removed
#   ✓ Silent reinstall blocked
```

---

### 🧹 TempCleaner.ps1 — Deep Temp & Cache Cleanup

**What it does**: Scans and cleans temporary files from 20+ locations — Windows Temp, User Temp, browser caches (Chrome/Firefox/Edge), shader caches (NVIDIA/AMD/DirectX), Windows Update cache, thumbnail cache, prefetch data, and Recycle Bin. Shows total space recovered.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\TempCleaner.ps1

# What you'll see:
#   📊 Pre-scan showing current sizes of each cache
#   ✓ Windows temp files cleaned
#   ✓ User temp files cleaned
#   ✓ Browser caches cleaned (Chrome, Firefox, Edge)
#   ✓ GPU shader caches cleaned (NVIDIA, AMD, DirectX)
#   ✓ Windows Update cache cleaned
#   ✓ Thumbnail cache purged
#   ✓ Prefetch files cleaned
#   ✓ Recycle Bin emptied
#   📊 Summary: "Recovered X.XX GB of disk space"
```

---

### 🚀 StartupManager.ps1 — Interactive Startup Optimizer

**What it does**: Scans all startup programs (registry + startup folders), displays them with safety ratings (🟢 Safe to disable, 🟡 Caution, 🔴 Do not disable), and lets you toggle individual items on/off. Also has an auto-disable mode for known bloatware.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\StartupManager.ps1

# Interactive menu:
#   [1] View all startup items with safety ratings
#   [2] Toggle specific items on/off
#   [3] Auto-disable known bloatware
#   [4] Show currently disabled items
#   [Q] Quit

# Example output:
#   [1] 🟢 Microsoft Teams          ENABLED   → Safe to disable
#   [2] 🟢 Spotify                  ENABLED   → Safe to disable
#   [3] 🟢 Discord Update           ENABLED   → Safe to disable
#   [4] 🔴 NVIDIA Display Driver    ENABLED   → Do NOT disable
#   [5] 🟡 Realtek Audio            ENABLED   → Caution
```

### 🚀 StartupManagerLite.ps1 — Quick Startup Fix

**What it does**: Instantly disables 20+ known bloatware startup entries (Teams, Spotify, Discord updater, Adobe Creative Cloud, OneDrive, Skype, etc.) without showing a menu.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\StartupManagerLite.ps1

# What you'll see:
#   ✓ Microsoft Teams — disabled
#   ✓ Spotify — disabled
#   ✓ Discord Update — disabled
#   ✓ Adobe Creative Cloud — disabled
#   ... (20+ items)
#   ✅ Disabled X startup items
```

---

### 🛡 PrivacyLockdown.ps1 — Full Privacy Hardening

**What it does**: Disables telemetry (10 categories), blocks 40+ tracking domains via hosts file, disables activity history, clipboard sync, location tracking, camera/mic background access, Find My Device, Advertising ID, Cortana/Copilot, typing/inking data, and feedback notifications. Creates a restore point.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\PrivacyLockdown.ps1

# What you'll see (10 categories):
#   ✓ [1/10] Telemetry — AllowTelemetry=0, DiagTrack stopped
#   ✓ [2/10] Activity History — disabled, upload blocked
#   ✓ [3/10] Clipboard — cloud sync disabled
#   ✓ [4/10] Location — background access blocked
#   ✓ [5/10] Camera/Mic — background access blocked
#   ✓ [6/10] Find My Device — disabled
#   ✓ [7/10] Advertising ID — reset and disabled
#   ✓ [8/10] Cortana/Copilot — fully disabled
#   ✓ [9/10] Typing/Inking — data collection off
#   ✓ [10/10] Hosts File — 40+ tracking domains blocked
#   ✅ Privacy hardening complete — 10 categories applied
```

### 🛡 PrivacyLockdownLite.ps1 — Quick Privacy Fix

**What it does**: Applies the 5 most impactful privacy settings — telemetry off, advertising ID disabled, Cortana/Copilot off, activity history off, feedback notifications off. Does NOT modify hosts file or block camera/location.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\PrivacyLockdownLite.ps1

# What you'll see:
#   ✓ Telemetry disabled
#   ✓ Advertising ID disabled
#   ✓ Cortana/Copilot disabled
#   ✓ Activity history disabled
#   ✓ Feedback notifications off
#   ✅ Quick privacy applied — 5 categories
```

---

### 🔄 WindowsUpdateControl.ps1 — Full Update Control

**What it does**: Configures Windows Update behavior across 7 categories — sets active hours (10 AM–2 AM), defers feature updates 30 days, defers quality updates 7 days, disables auto-restart, blocks P2P delivery optimization, excludes driver updates from WU, and suppresses notifications. Creates a restore point.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\WindowsUpdateControl.ps1

# What you'll see:
#   ✓ System restore point created
#   ✓ Active hours set (10:00 AM → 2:00 AM)
#   ✓ Feature updates deferred 30 days
#   ✓ Quality updates deferred 7 days
#   ✓ Auto-restart blocked during active hours
#   ✓ P2P delivery optimization disabled
#   ✓ Driver updates excluded from WU
#   ✓ Update notifications suppressed
#   ✅ 7 update policies configured
```

### 🔄 WindowsUpdateControlLite.ps1 — Quick Update Control

**What it does**: Defers feature updates 30 days, quality updates 7 days, blocks auto-restart, and disables P2P delivery optimization. Does not change active hours or driver settings.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\WindowsUpdateControlLite.ps1

# What you'll see:
#   ✓ Feature updates deferred 30 days
#   ✓ Quality updates deferred 7 days
#   ✓ Auto-restart blocked
#   ✓ P2P delivery optimization off
#   ✅ 4 update settings applied
```

---

### 🎮 GameBooster.ps1 — Per-Game Performance Mode

**What it does**: Clears standby memory, kills 24 bloatware processes, pauses 4 heavy services (SysMain, WSearch, DiagTrack, WU), flushes DNS/ARP/Winsock, disables Nagle, switches to Ultimate Performance power plan, sets GPU scheduling priority, and optionally monitors a game process to boost its priority and CPU affinity. **Automatically restores everything when the game exits.**

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\GameBooster.ps1

# Phase 1 — System Prep (automatic):
#   ✓ Standby memory cleared (freed X MB)
#   ✓ Killed: Edge, Teams, Spotify, Discord updaters, OneDrive...
#   ✓ Paused: SysMain, WSearch, DiagTrack, Windows Update
#   ✓ DNS/ARP flushed, Winsock reset, Nagle disabled
#   ✓ Power plan → Ultimate Performance
#   ✓ GPU scheduling priority → High

# Phase 2 — Game Monitor (interactive):
#   "Enter game process name (e.g., valorant): "
#   → cs2
#   "Waiting for cs2 to start..."
#   ✓ cs2 detected — Priority: High, Affinity: P-cores (0-7)
#   "Monitoring cs2... press Ctrl+C to stop"

# Phase 3 — Auto-Restore (when game exits):
#   ✓ Power plan → Balanced
#   ✓ Services resumed: SysMain, WSearch, DiagTrack, Windows Update
#   ✓ Nagle re-enabled
#   ✅ System fully restored
```

### 🎮 GameBoosterLite.ps1 — Quick Pre-Game Boost

**What it does**: Kills 21 bloatware processes, pauses 3 services, clears standby memory, flushes DNS, switches power plan to Ultimate Performance. No game monitoring or auto-restore.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\GameBoosterLite.ps1

# What you'll see:
#   ✓ Killed 15 background processes
#   ✓ Paused SysMain, WSearch, DiagTrack
#   ✓ Standby memory cleared
#   ✓ DNS flushed
#   ✓ Power plan → Ultimate Performance
#   ✅ System boosted — launch your game!
```

---

### 🌐 NetworkOptimizer.ps1 — Interactive Network Tuning

**What it does**: 8-step interactive network optimization wizard — choose DNS providers, configure TCP settings (Nagle, auto-tuning, RSS, ECN), auto-detect optimal MTU via ping tests, disable bandwidth throttling, turn off Wi-Fi Sense, optimize adapter settings (power management, EEE, interrupt moderation, flow control), flush all caches, and run a latency benchmark.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\NetworkOptimizer.ps1

# Step 1: DNS Provider
#   [1] Cloudflare (1.1.1.1)     — fastest
#   [2] Google (8.8.8.8)         — reliable
#   [3] Quad9 (9.9.9.9)          — security-focused
#   [4] OpenDNS (208.67.222.222) — family-safe options
#   [5] Custom
#   [6] Skip
#   Choice: 1

# Step 2: TCP Settings
#   [1] Disable Nagle's Algorithm (recommended)
#   Auto-Tuning Level → Normal
#   RSS → Enabled
#   ECN → Disabled

# Step 3: MTU Detection
#   Testing MTU 1500... fragmented
#   Testing MTU 1472... OK!
#   → Optimal MTU: 1472, setting on adapter

# Step 4: Bandwidth Throttling → Removed
# Step 5: Wi-Fi Sense → Disabled
# Step 6: Adapter Optimization → EEE off, Interrupt Mod off
# Step 7: Cache Flush → DNS, ARP, NetBIOS, Winsock
# Step 8: Latency Test
#   Cloudflare: avg 12ms, jitter 3ms
#   Google:     avg 15ms, jitter 5ms
```

### 🌐 NetworkOptimizerRecommended.ps1 — Auto Network Fix

**What it does**: Instantly applies recommended settings — Cloudflare DNS (1.1.1.1), Nagle disabled, TCP auto-tuning normal, RSS enabled, timestamps off, bandwidth throttle removed, Wi-Fi Sense off, all caches flushed.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\NetworkOptimizerRecommended.ps1

# What you'll see:
#   ✓ DNS → Cloudflare (1.1.1.1 / 1.0.0.1)
#   ✓ Nagle's Algorithm → Disabled
#   ✓ Auto-Tuning → Normal
#   ✓ RSS → Enabled, Timestamps → Off
#   ✓ QoS bandwidth reserve → Removed (100% available)
#   ✓ Network throttling → Disabled
#   ✓ Wi-Fi Sense → Off
#   ✓ DNS/ARP/NetBIOS/Winsock caches flushed
#   ✅ Network optimized — 13 settings applied
```

---

### 🧹 BloatRemover.ps1 — Windows 11 Bloatware Removal

**What it does**: Scans for 60+ pre-installed Windows 11 apps across 8 categories and lets you remove them interactively — all at once, all including Xbox, or per-category. Also blocks silent reinstallation and disables background app access.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\BloatRemover.ps1

# Scanning... Found 32 removable bloatware apps

# Choose:
#   [A] Remove ALL bloatware (except Gaming)
#   [G] Remove ALL including Gaming/Xbox apps
#   [C] Choose by category
#   [Q] Quit

# Categories (if choosing [C]):
#   [1] Communication & Social (People, Mail, Skype, Teams...)
#   [2] Entertainment & Media (Groove, Movies, Solitaire, Clipchamp...)
#   [3] News & Information (Bing News, Weather, Finance...)
#   [4] Productivity / Office Stubs (Office Hub, OneNote, Cortana...)
#   [5] Maps & Navigation (Maps, Alarms, Feedback Hub)
#   [6] 3D & Mixed Reality (3D Viewer, Paint 3D, Mixed Reality...)
#   [7] Gaming ⚠ (Xbox Game Bar, Overlay — WARNING shown)
#   [8] Widgets & AI (Widgets, Copilot, Copilot Runtime)
#
#   Enter: 1,2,3,4,8

# What you'll see:
#   ✕ People — Removed
#   ✕ Mail & Calendar — Removed
#   ✕ Groove Music — Removed
#   ✕ Windows Widgets — Removed
#   ...
#   🔇 Background app access disabled globally
#   🔇 Silent app reinstallation blocked
#   ✅ Removed: 28 apps
```

---

### 🖱 MouseOptimizer.ps1 — Input Latency Reduction

**What it does**: 6-step interactive mouse optimization — disable mouse acceleration with flat 1:1 SmoothMouse curves, set pointer speed to true 1:1 (6/11), remove all visual effects (trails, snap-to, shadow, hide-while-typing), configure raw input registry keys, USB polling rate guidance with device detection, and an eDPI calculator with pro player comparisons.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\MouseOptimizer.ps1

# Shows current settings:
#   Pointer Speed:     12 / 20
#   Acceleration:      ON ⚠
#   Pointer Trails:    OFF ✓
#   Snap-to-Default:   ON ⚠

# Step 1: Mouse Acceleration
#   [1] Disable acceleration (recommended)
#   → Sets MouseSpeed=0, Thresholds=0, flat 1:1 curves

# Step 2: Pointer Speed
#   [1] Set to 10 (6/11 — true 1:1 mapping)
#   [2] Custom value (1-20)
#   → Only 10/20 gives true 1:1 pixel mapping

# Step 3: Visual Effects
#   [1] Remove all effects (trails, snap, shadow)

# Step 4: Raw Input
#   [1] Enable raw input optimizations
#   → Hover delay 0ms, touch prediction minimized, wheel routing direct

# Step 5: USB Polling Rate
#   125 Hz = 8.0ms    (office)
#   500 Hz = 2.0ms    (competitive)
#   1000 Hz = 1.0ms   (pro) ✓
#   8000 Hz = 0.125ms (Razer Viper V3)
#   → Detects mouse devices, disables USB selective suspend

# Step 6: eDPI Calculator
#   Mouse DPI: 800
#   In-game sens: 1.5
#   → Your eDPI: 1200 — Medium, versatile for most games
#   Pro ranges: Valorant 200-400, CS2 600-1000, Apex 800-1600
```

### 🖱 MouseOptimizerLite.ps1 — Quick Mouse Fix

**What it does**: Instantly disables acceleration (flat 1:1 curves), sets pointer speed to 10/20 (6/11), removes trails/snap/shadow, applies raw input tweaks, and disables USB selective suspend.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\MouseOptimizerLite.ps1

# What you'll see:
#   ✓ Acceleration OFF — flat 1:1 curve
#   ✓ Pointer speed 10/20 (6/11 — true 1:1)
#   ✓ Pointer trails OFF
#   ✓ Snap-to-default OFF
#   ✓ Cursor shadow OFF
#   ✓ Hover delay 0ms
#   ✓ USB selective suspend OFF
#   ✓ USB power saving OFF
#   ✅ Mouse optimized — 10 changes
#   ⚠ Log out and back in for all changes to take effect
```

---

### 🖥 GPUOptimizer.ps1 — Per-GPU Performance Tuning

**What it does**: Auto-detects your GPU vendor (NVIDIA or AMD) and shows vendor-specific tuning options, plus universal settings. NVIDIA: power management, threaded optimization, low latency mode, texture filtering, VSync, shader cache. AMD: Anti-Lag, Enhanced Sync, ULPS, tessellation, shader cache. Universal: disable MPO, HAGS, Game Mode, fullscreen optimizations, Game DVR.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\GPUOptimizer.ps1

# Detection:
#   Found: NVIDIA GeForce RTX 4070 Ti
#   Driver: 32.0.15.6590
#   VRAM: 12.0 GB

# NVIDIA Options:
#   Power Management → [1] Prefer Maximum Performance
#   Threaded Opt     → [1] Off (lower latency)
#   Low Latency Mode → [1] Ultra (NVIDIA Reflex)
#   Texture Filtering → [1] Performance
#   Global VSync     → [1] Off
#   Shader Cache     → [1] Unlimited

# Universal Options:
#   MPO              → [1] Disable (fixes stuttering in many games)
#   HAGS             → [1] Enable
#   Game Mode        → [1] Enable
#   FSO              → [1] Disable (true exclusive fullscreen)
#   Game DVR         → [1] Disable (free GPU resources)

# ✅ GPU Optimized — 11 changes applied
# ⚠ Restart required for HAGS and MPO changes
```

**AMD example:**
```powershell
# Detection:
#   Found: AMD Radeon RX 7900 XTX

# AMD Options:
#   Anti-Lag     → [1] Enable (reduces input latency)
#   Enhanced Sync → [1] Disable (reduces stutter)
#   Tessellation → [1] Application-controlled
#   + Surface Format Opt enabled, Shader Cache on, ULPS disabled
```

### 🖥 GPUOptimizerLite.ps1 — Quick GPU Fix

**What it does**: Auto-detects GPU and applies all recommended settings instantly — NVIDIA (max power, Ultra latency, threaded off), AMD (Anti-Lag on, ULPS off, shader cache), plus universal MPO off, HAGS on, Game Mode on, FSO off, Game DVR off.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\GPUOptimizerLite.ps1

# What you'll see:
#   🖥 NVIDIA GeForce RTX 4070 Ti
#   ✓ Power: Max Performance
#   ✓ Low Latency: Ultra
#   ✓ Threaded Opt: Off
#   ✓ MPO: Disabled (fixes stuttering)
#   ✓ HAGS: Enabled
#   ✓ Game Mode: Enabled
#   ✓ Fullscreen Optimizations: Disabled
#   ✓ Game DVR: Disabled
#   ✅ GPU Optimized — 8 changes
#   ⚠ Restart required for HAGS and MPO changes
```

---

### ⏱ LatencyMonitor.ps1 — DPC/ISR Latency Checker

**What it does**: Comprehensive system latency analysis — queries system timer resolution via `NtQueryTimerResolution`, monitors DPC (Deferred Procedure Call) and ISR (Interrupt Service Routine) latency in real-time with a live visual bar, scans all running drivers against a 30+ known problematic driver database with specific fix recommendations, checks for devices in error state, runs optional network latency tests with jitter analysis, and provides context-aware recommendations.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\LatencyMonitor.ps1

# Configure duration:
#   [1] 15 seconds    [2] 30 seconds (recommended)
#   [3] 60 seconds    [4] Custom

# Timer Resolution:
#   Current: 1.00ms ✓
#   Minimum: 0.50ms
#   Maximum: 15.63ms

# Live DPC/ISR Monitor (30 seconds):
#   DPC [████████░░░░░░░░] 1.2%  ISR [██░░░░░░░░░░░░░░] 0.3%  [25s]
#   DPC [██████████░░░░░░] 2.1%  ISR [███░░░░░░░░░░░░░] 0.5%  [24s]
#   ...

# Results:
#   DPC — avg: 1.5%  peak: 3.2%  ✓ EXCELLENT
#   ISR — avg: 0.4%  peak: 1.1%  ✓ EXCELLENT

# Driver Analysis:
#   Found 4 drivers with known latency issues:
#   [1] nvlddmkm.sys — NVIDIA GPU driver
#       Fix: Update to latest Game Ready driver, clean install
#   [2] Netwtw10.sys — Intel Wi-Fi 7
#       Fix: Update Intel Wi-Fi driver or switch to Ethernet
#   [3] HDAudBus.sys — HD Audio bus
#       Fix: Update Realtek/audio driver or disable unused audio devices
#   [4] intelppm.sys — Intel Processor Power Management
#       Fix: Disable C-States in BIOS or set power plan to High Performance

# Network Latency (optional):
#   Cloudflare DNS       avg: 8ms   jitter: 2ms   (5-10ms)
#   Google DNS           avg: 12ms  jitter: 4ms   (8-16ms)
#   Quad9 DNS            avg: 15ms  jitter: 3ms   (12-18ms)

# Recommendations:
#   💡 Use Ethernet instead of Wi-Fi for lowest network latency
#   💡 Run GameBooster.ps1 before gaming to kill background processes
```

### ⏱ LatencyMonitorLite.ps1 — Quick Latency Check

**What it does**: Runs a 15-second DPC/ISR scan with live bar visualization, then auto-scans all running drivers against 18 known problematic drivers with quick fix descriptions.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\LatencyMonitorLite.ps1

# Live monitor (15 seconds):
#   DPC [██████░░░░░░░░░░] 1.0%  ISR: 0.2%  [12s]

# Results:
#   DPC — avg: 0.8%  peak: 2.1%
#   ISR — avg: 0.3%  peak: 0.9%
#   ✓ EXCELLENT — Low latency system!

# Driver scan:
#   ⚠ nvlddmkm.sys — Update NVIDIA driver (clean install)
#   ⚠ Netwtw10.sys — Update Intel Wi-Fi 7 driver
#   Found 2 potential latency sources
```

---

## 🧠 Recommended Script Order for New Setups

For maximum effect, run these scripts in this order on a fresh Windows 11 install:

```
1. .\BloatRemover.ps1              — Remove junk apps first
2. .\PrivacyLockdown.ps1           — Lock down telemetry & tracking
3. .\ElitePerformance.ps1          — Apply power plan + system optimizations
   (or .\ProPerformance.ps1 for laptops)
4. .\GPUOptimizer.ps1              — Tune your GPU
5. .\MouseOptimizer.ps1            — Fix mouse input
6. .\NetworkOptimizer.ps1          — Tune your network
7. .\WindowsUpdateControl.ps1      — Control update behavior
8. .\StartupManager.ps1            — Clean up startup items
9. .\TempCleaner.ps1               — Clean temp files

Before each gaming session:
   .\GameBooster.ps1               — Kill bloat, boost game, auto-restore

Diagnose issues:
   .\LatencyMonitor.ps1            — Find latency-causing drivers
```

---

## ❓ FAQ

**Q: Will this damage my PC?**
A: No. All changes are software-level (registry, services, power plans). `RestoreDefaults.ps1` reverses Elite/Pro changes. System restore points are created automatically.

**Q: Which tier should I choose — Elite or Pro?**
A: **Elite** for dedicated gaming desktops with good cooling. **Pro** for laptops, daily-driver PCs, or if you want sleep/display-off to still work.

**Q: Will this affect game anti-cheat?**
A: No. These are standard Windows configuration changes. No drivers or system files are modified.

**Q: My FPS didn't change. Is it working?**
A: The primary benefit is **lower input latency and more consistent frame times**, not necessarily higher peak FPS. You'll notice smoother gameplay, less stuttering, and more responsive controls.

**Q: Can I use Lite scripts instead of Full?**
A: Yes! Lite scripts apply the most impactful settings automatically. Full scripts give you per-setting control. Both achieve the same core optimizations.

**Q: Do I need to restart after running scripts?**
A: Most changes are instant. **GPU Optimizer** changes (HAGS, MPO) and **Mouse Optimizer** changes require a log-out or restart. Scripts will tell you when a restart is needed.

---

## 🔧 Troubleshooting

| Problem | Solution |
|---|---|
| "Execution Policy" error | Run `Set-ExecutionPolicy Bypass -Scope Process -Force` first |
| Script won't elevate | Right-click PowerShell → Run as Administrator, then run the script |
| "not recognized" error | Make sure you're in the correct directory: `cd "C:\path\to\scripts"` |
| Restore point fails | Windows limits one restore point per 24 hours. Scripts continue anyway |
| USB device issues | Run `RestoreDefaults.ps1` — USB Selective Suspend will be re-enabled |
| Mouse changes not working | Log out and back in, or restart your PC |
| GPU changes not working | Restart required for HAGS and MPO changes |
| Game DVR still recording | Restart required, then check in Settings → Gaming |
| Network changes lost | Some changes reset after Windows Update — re-run the network script |
| System feels sluggish after Elite | Switch to Pro: `.\RestoreDefaults.ps1` then `.\ProPerformance.ps1` |

---

## 📜 License

MIT License — use, modify, and distribute freely.

---

<div align="center">

**Built for gamers who want every last frame. ⚡**

⭐ Star this repo if it helped your gaming performance!

</div>
