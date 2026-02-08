# ⚡ Windows 11 Gamer Optimization Suite

> **Two tiers of power plan optimization scripts that unlock maximum performance from your Windows 11 machine.**

![Windows 11](https://img.shields.io/badge/Windows-11-0078D4?style=for-the-badge&logo=windows11&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-5171A5?style=for-the-badge&logo=powershell&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

---

## 🎯 What Is This?

This project provides **two custom PowerShell scripts** that create optimized power plans and apply deep OS-level tweaks to maximize your Windows 11 gaming performance. Every tweak is explained so you can **learn what's happening** and why it helps.

| | ⚡ Elite | 🏆 Pro | 📦 Default Windows |
|---|---|---|---|
| **CPU Min State** | 100% (always max) | 5% (can idle) | 5% |
| **Core Parking** | All cores ON | 50% min | 10-50% |
| **CPU Idle States** | Disabled | Enabled | Enabled |
| **Memory Compression** | OFF | ON | ON |
| **Sleep** | Never | 30 min | 30 min |
| **Display Timeout** | Never | 15 min | 5 min |
| **Superfetch** | OFF | OFF | ON |
| **Prefetch** | OFF | OFF | ON |
| **Visual Effects** | All OFF | Reduced | All ON |
| **Nagle's Algorithm** | OFF | OFF | ON |
| **System Responsiveness** | 0% (100% to game) | 10% (90% to game) | 20% |
| **Game DVR** | OFF | OFF | ON |
| **Background Apps** | All OFF | User choice | All ON |
| **Telemetry** | Disabled | Disabled | Full |
| **Services Disabled** | 10 | 6 | 0 |
| **System Timer** | Platform tick | Default | Default |
| **NTFS Optimized** | Yes | Yes | No |
| **Best For** | Desktop gaming rigs | Laptops & daily drivers | — |

---

## 🚀 Quick Start

### Prerequisites
- **Windows 11** (any edition)
- **Administrator access** (scripts self-elevate)
- **PowerShell 5.1+** (included with Windows 11)

### Run a Script

```powershell
# Option 1: Right-click → Run with PowerShell
# Option 2: From an elevated PowerShell terminal:

Set-ExecutionPolicy Bypass -Scope Process -Force
.\ElitePerformance.ps1    # For maximum performance
# OR
.\ProPerformance.ps1      # For balanced performance
```

### Undo Everything

```powershell
.\RestoreDefaults.ps1
```

> **🛡 Safety**: Every script creates a **System Restore Point** before making changes. You can always revert from Windows System Restore.

---

## 📁 Files

| File | Description |
|---|---|
| `ElitePerformance.ps1` | Aggressive maximum-performance preset. Best for dedicated gaming desktops. |
| `ProPerformance.ps1` | Balanced high-performance preset. Safe for laptops and all-purpose machines. |
| `RestoreDefaults.ps1` | Completely reverses all changes from either script. |
| `RemoveOneDrive.ps1` | ☁ Fully wipes Microsoft OneDrive — app, folders, registry, sidebar, context menus. |
| `RemoveOutlook.ps1` | 📧 Fully wipes Microsoft Outlook — UWP, classic, cache, telemetry, protocol handlers. |
| `TempCleaner.ps1` | 🧹 Deep temp/cache cleanup — browsers, shaders, Windows Update, thumbnails. Shows space recovered. |
| `StartupManager.ps1` | 🚀 Full interactive startup optimizer — safety ratings, toggle on/off, auto-disable bloat. |
| `StartupManagerLite.ps1` | 🚀 Quick auto-optimizer — instantly disables known bloatware, no menu needed. |
| `PrivacyLockdown.ps1` | 🛡 Full privacy hardening — telemetry, tracking, hosts file, camera/mic, Cortana/Copilot. |
| `PrivacyLockdownLite.ps1` | 🛡 Quick privacy — telemetry, ads, Cortana off. Keeps location/clipboard/camera. |
| `WindowsUpdateControl.ps1` | 🔄 Full update control — active hours, deferrals, no auto-restart, no P2P, no driver WU. |
| `WindowsUpdateControlLite.ps1` | 🔄 Quick update control — defer features 30d, quality 7d, no auto-restart, no P2P. |
| `GameBooster.ps1` | 🎮 Per-game performance mode — kill bloat, boost priority, flush RAM, auto-restore on exit. |
| `GameBoosterLite.ps1` | 🎮 Quick pre-game boost — kill bloat, flush RAM/DNS, power plan switch. Run & go. |
| `NetworkOptimizer.ps1` | 🌐 Interactive network tuning — DNS, TCP, MTU testing, adapter optimizations, latency test. |
| `NetworkOptimizerRecommended.ps1` | 🌐 Auto-apply recommended network settings — Cloudflare DNS, Nagle off, throttle removed. |
| `BloatRemover.ps1` | 🧹 Windows 11 app cleanup — 60+ bloatware, 8 categories, interactive or bulk remove. |
| `MouseOptimizer.ps1` | 🖱 Interactive mouse tuning — acceleration, pointer speed, raw input, USB polling, eDPI calculator. |
| `MouseOptimizerLite.ps1` | 🖱 Quick mouse fix — acceleration off, 6/11 speed, trails off, USB optimized. |
| `GPUOptimizer.ps1` | 🖥 Per-GPU tuning — NVIDIA/AMD auto-detect, vendor tweaks, MPO, HAGS, FSO, Game DVR. |
| `GPUOptimizerLite.ps1` | 🖥 Quick GPU fix — auto-detect vendor, apply best settings, disable MPO/DVR. |
| `LatencyMonitor.ps1` | ⏱ DPC/ISR latency checker — real-time monitoring, 30+ driver database, network test. |
| `LatencyMonitorLite.ps1` | ⏱ Quick 15s latency check — DPC/ISR monitoring, auto driver scan. |

---

## 📖 Understanding Every Optimization

### ⚡ Power Plan (Steps 1-2)

**What**: Creates a custom power plan based on the hidden "Ultimate Performance" plan (Elite) or "High Performance" plan (Pro).

**Why it helps**: Windows' default "Balanced" plan aggressively downclocks your CPU and parks cores to save power. This adds **5-15ms of latency** every time your CPU needs to ramp up from idle — which happens constantly during gaming.

| Setting | What it does | Impact |
|---|---|---|
| **Min Processor State 100%** | CPU never downclocks below max frequency | Eliminates ramp-up latency |
| **Core Parking 100%** | All CPU cores stay active | No delay unparking cores |
| **Boost Mode Aggressive** | CPU turbo boosts harder and sustains longer | Higher sustained clock speeds |
| **Idle Disabled** (Elite) | CPU never enters C-states | Zero transition latency |
| **USB Suspend Off** | USB devices never sleep | No mouse/keyboard reconnection delays |
| **PCIe Link State Off** | PCIe bus always at full bandwidth | GPU/NVMe never throttled |

---

### 🎮 GPU & Display (Step 3)

**What**: Forces the GPU to maximum performance mode and disables fullscreen optimizations.

**Why it helps**: Windows' "Fullscreen Optimizations" (FSO) adds a composition layer between your game and the display. Disabling FSO gives you **true exclusive fullscreen** with lower input latency.

| Setting | What it does |
|---|---|
| **GPU Preference → High** | Always use discrete GPU at max performance |
| **HAGS Off** (Elite only) | CPU controls GPU queue directly — lower input latency |
| **FSO Disabled** | True exclusive fullscreen — bypasses DWM compositor |

---

### 🧠 Memory & Cache (Step 4)

**What**: Disables background memory management features that waste CPU cycles.

**Why it helps**: Superfetch pre-loads applications into RAM based on usage patterns. This causes random I/O spikes during gaming. On an SSD, the startup time difference is negligible, so pre-loading is pointless.

| Setting | What it does | Impact |
|---|---|---|
| **Memory Compression Off** (Elite) | Stops CPU from compressing memory pages | Frees 1-3% CPU |
| **Superfetch Off** | No background app pre-loading | Less random I/O |
| **Prefetch Off** | No anticipatory disk reads | Smoother frame times |
| **Large System Cache → Programs** | More RAM for apps, less for file cache | Better for gaming |

---

### 🌐 Network (Step 5)

**What**: Disables TCP optimizations that add latency for the sake of throughput.

**Why it helps**: **Nagle's Algorithm** batches small TCP packets together, adding **5-40ms of latency** to every network call. It was designed for 1990s networks. Disabling it sends each packet immediately — critical for online gaming.

| Setting | What it does | Impact |
|---|---|---|
| **Nagle Off** (`TCPNoDelay=1`) | Packets sent immediately | 5-40ms less network latency |
| **TCP Ack Frequency = 1** | Acknowledge every packet immediately | Better hit registration |
| **Network Throttling Off** | Remove bandwidth reservation | Full bandwidth for games |

---

### ⏱ Scheduler & Timer (Step 6)

**What**: Reconfigures how Windows distributes CPU time between applications.

**Why it helps**: `Win32PrioritySeparation` is the most impactful single registry tweak for gaming. Setting it to `0x26` (38 decimal) gives the foreground window **3x more CPU time slices** than any background process.

| Setting | Value | Effect |
|---|---|---|
| `Win32PrioritySeparation` | 38 (0x26) | Short, variable quantum, 3x foreground boost |
| `SystemResponsiveness` | 0 (Elite) / 10 (Pro) | How much CPU is reserved for background |
| `GPU Priority` | 8 | Maximum GPU time for games |
| Platform Tick (Elite) | Enabled | Consistent timer resolution — less jitter |

---

### 🔇 Services (Step 7)

**What**: Disables Windows services that run in the background and consume resources.

**Why it helps**: Each service uses CPU, RAM, and sometimes disk I/O. The services we disable are genuinely unnecessary for gaming (Fax, Maps, AllJoyn IoT). Telemetry services in particular can cause frame drops during their upload cycles.

<details>
<summary>📋 Full Service List (click to expand)</summary>

| Service | Description | Elite | Pro |
|---|---|---|---|
| SysMain | Superfetch — pre-loads apps | ❌ | ❌ |
| DiagTrack | Telemetry — sends data to MS | ❌ | ❌ |
| WSearch | Windows Search Indexer | ❌ | ✅ |
| MapsBroker | Offline Maps Manager | ❌ | ❌ |
| Fax | Windows Fax | ❌ | ❌ |
| TabletInputService | Touch Keyboard | ❌ | ✅ |
| RetailDemo | Store demo mode | ❌ | ❌ |
| WMPNetworkSvc | WMP network sharing | ❌ | ✅ |
| AJRouter | AllJoyn IoT router | ❌ | ✅ |
| dmwappushservice | WAP Push Messages | ❌ | ❌ |

</details>

---

### 👁 Visual Effects (Step 8)

**What**: Disables Windows animations, transparency, and desktop effects.

**Why it helps**: Every animation (window fade, taskbar slide, menu glow) consumes GPU cycles. The transparency/blur ("Acrylic") effect in particular uses significant GPU compute. Disabling these frees GPU resources for your games.

- **Elite**: Disables ALL visual effects for maximum performance
- **Pro**: Keeps ClearType font smoothing and smooth scrolling for readability

---

### 🚫 Telemetry (Step 9)

**What**: Disables Windows diagnostic data collection, Cortana, activity tracking, and advertising features.

**Why it helps**: Telemetry services periodically collect and upload system data. These uploads can coincide with gaming sessions, causing network latency spikes and CPU usage. Disabling them also improves privacy.

---

## 🔬 The Telemetry Problem — Why It Kills Performance

Windows 11 ships with **extensive telemetry** — background services that continuously collect, process, and upload data about your system, your usage patterns, your hardware, your installed apps, and more. Microsoft calls it "diagnostic data," but for gamers, it's a silent performance killer.

### How Telemetry Hurts Your FPS

| Resource | What Telemetry Does | Gaming Impact |
|---|---|---|
| **CPU** | `DiagTrack` and `dmwappushservice` periodically wake up to collect system events, crash dumps, and usage data. These collection cycles spike CPU usage by 2-8% unpredictably. | **Micro-stutters and frame drops** during collection cycles. You'll see random 1% low FPS dips that coincide with telemetry bursts. |
| **Disk I/O** | Telemetry writes event logs to `C:\ProgramData\Microsoft\Diagnosis`, creates ETW trace files, and journals everything to disk. On HDDs this is catastrophic; on SSDs it still competes for I/O bandwidth. | **Longer load times and texture streaming hitches.** Games that stream assets from disk (open world games) stutter when telemetry is writing. |
| **Network** | Collected data is uploaded to Microsoft servers (`settings-win.data.microsoft.com`, `vortex.data.microsoft.com`, etc.) in periodic bursts. These uploads can saturate your connection for 2-5 seconds. | **Ping spikes of 50-200ms** during uploads. Devastating for competitive multiplayer. |
| **RAM** | Telemetry services keep ~50-150MB of resident memory at all times for caching collected data. | **Less RAM for game textures**, especially on 8-16GB systems. |
| **Timers** | ETW (Event Tracing for Windows) sessions used by telemetry create high-frequency timer interrupts that interfere with your game's frame pacing. | **Inconsistent frame times** — even if average FPS looks fine, the frame-to-frame consistency suffers. |

### What Our Scripts Disable

Both the **Elite** and **Pro** scripts disable:
- `DiagTrack` service (Connected User Experiences and Telemetry)
- `dmwappushservice` (WAP Push Message Routing)
- Windows Telemetry data collection (registry)
- Customer Experience Improvement Program (CEIP)
- Activity History tracking and uploading
- Advertising ID tracking
- Cortana data collection

### Going Further: The Raphire Windows Debloat Tool

For users who want an **even deeper debloat** beyond what our scripts handle, there's a well-known community tool:

```powershell
& ([scriptblock]::Create((irm "https://debloat.raphi.re/")))
```

> [!CAUTION]
> **This downloads and executes a remote script directly from the internet.** While this tool is well-known in the Windows optimization community and is open-source, you are running code that you did not write and cannot verify at execution time. **Always review the source code first** at the project's repository before running it.

> [!WARNING]
> **The debloat tool is MUCH more aggressive than our scripts.** It can remove Windows Store apps, disable Windows Update components, strip Microsoft Edge, and make changes that are **very difficult to reverse**. Some changes may break Windows features you depend on. **Only use this if you know exactly what you're doing.**

> [!IMPORTANT]
> **Create a full system image backup (not just a restore point) before running any third-party debloat tool.** Tools like Macrium Reflect Free or Windows' built-in system image backup can save your entire disk state. A restore point alone may not be sufficient to undo all changes made by aggressive debloat scripts.

What the debloat tool can do beyond our scripts:
- Remove pre-installed Windows Store apps (Clipchamp, Teams, News, etc.)
- Disable Windows Update entirely (not recommended for security)
- Remove Microsoft Edge completely
- Strip Widgets, Copilot, and AI features
- Disable additional background services

---

## 🧹 Bloatware Removal Scripts

In addition to the power plan optimization scripts, we provide dedicated removal scripts for two of the biggest background offenders on Windows 11.

### ☁ RemoveOneDrive.ps1 — Complete OneDrive Wipe

OneDrive runs constantly in the background, syncing files, updating icons, and consuming CPU/disk/network resources — even when you're not actively using it.

> [!CAUTION]
> **This is IRREVERSIBLE.** OneDrive cannot be easily reinstalled after a full wipe. Your locally synced files will remain on disk, but cloud sync is permanently removed. **Back up your OneDrive folder before running this.**

What it removes:
| Component | Details |
|---|---|
| **Application** | Uninstalls via winget and OneDriveSetup.exe |
| **Hidden Folders** | `%LOCALAPPDATA%\Microsoft\OneDrive`, `%APPDATA%\Microsoft\OneDrive`, `%PROGRAMDATA%\Microsoft OneDrive`, UWP package data, temp files — **9 locations total** |
| **Explorer Integration** | Sidebar entry, navigation pane, context menus ("Share with OneDrive"), icon overlay handlers (sync status badges) |
| **Registry** | Startup entries, namespace keys, CLSID entries, environment variables |
| **Scheduled Tasks** | All OneDrive scheduled tasks |
| **Reinstallation** | Blocked via Group Policy (`DisableFileSyncNGSC`) |

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\RemoveOneDrive.ps1
```

### 📧 RemoveOutlook.ps1 — Complete Outlook Wipe

The new Windows 11 Outlook app runs background sync processes, sends telemetry, and keeps network connections open at all times — even when minimized.

> [!CAUTION]
> **Export your emails, contacts, and calendar data BEFORE running this.** All Outlook data including PST/OST files, offline cache, and email profiles will be permanently deleted.

What it removes:
| Component | Details |
|---|---|
| **New Outlook** | UWP/MSIX packages, provisioned packages (blocks new-user install) |
| **Classic Outlook** | Office 16.0 profiles, registry entries, protocol handlers (`mailto:`, `outlook:`) |
| **Hidden Data** | `%LOCALAPPDATA%\Microsoft\Olk`, `%LOCALAPPDATA%\Microsoft\Outlook`, Windows Communications Apps package, offline cache, telemetry logs — **12+ locations** |
| **Scheduled Tasks** | OfficeTelemetry and Outlook-specific tasks |
| **Reinstallation** | Blocked via policy, silent app install disabled |

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\RemoveOutlook.ps1
```

---

## 🛡 Advanced: Network-Level Telemetry Blocking with Safing Portmaster

Even after disabling telemetry via registry and services, **Windows can still phone home** through other system components, Edge WebView processes, and Windows Update connections. For users who want to block telemetry **at the network level**, we recommend:

### [Safing Portmaster](https://safing.io/) — Free, Open Source

Portmaster is a free, open-source application firewall that monitors and controls all network traffic on your PC. It can:

- **Block all telemetry domains** — Prevents `vortex.data.microsoft.com`, `settings-win.data.microsoft.com`, `watson.telemetry.microsoft.com`, and hundreds more from ever being contacted
- **Show you exactly what's phoning home** — See every connection every app makes in real-time
- **Block per-application** — Allow your game's network traffic while blocking Edge's telemetry, for example
- **Use community filter lists** — Similar to ad blockers, but for your entire system
- **DNS-level privacy** — Built-in DNS-over-TLS/HTTPS with configurable upstream resolvers

> [!WARNING]
> **Portmaster acts as a system firewall.** Misconfiguring it can block legitimate connections including game servers, Discord, Steam, Windows Update, and more. If you experience connectivity issues after installing it, check Portmaster's connection log first.

> [!WARNING]
> **Some games with aggressive anti-cheat** (Vanguard, EasyAntiCheat, BattlEye) may conflict with Portmaster's network filtering driver. If you experience issues launching games with kernel-level anti-cheat, you may need to add exceptions or temporarily disable Portmaster.

> [!IMPORTANT]
> **Do not blindly block all Microsoft domains.** Some are required for Windows activation, Store purchases, and game license verification (Xbox/Game Pass). Portmaster's default filter lists are generally safe, but custom rules should be tested carefully.

**Install**: Download from [https://safing.io/](https://safing.io/) — No account required.

| Feature | Portmaster | Windows Firewall |
|---|---|---|
| Block telemetry domains | ✅ Hundreds of domains | ❌ Manual IP rules only |
| See all connections | ✅ Real-time dashboard | ❌ Basic log only |
| Per-app rules | ✅ Easy GUI | ⚠️ Complex rules |
| DNS privacy | ✅ Built-in DoT/DoH | ❌ Not available |
| Open source | ✅ Fully open | ⚠️ Closed source |
| Price | Free | Free |

---

### 💾 NTFS Filesystem (Step 10)

**What**: Optimizes NTFS volume settings.

| Setting | What it does | Impact |
|---|---|---|
| **Disable 8.3 Names** | Stops generating DOS-compatible filenames | ~20% faster file creation |
| **Disable Last Access Time** | Stops updating access timestamps on reads | Less disk writes |
| **High Memory Usage** | Caches more filesystem metadata in RAM | Faster directory traversal |

---

## ❓ FAQ

**Q: Will this damage my PC?**
A: No. All changes are software-level (registry, services, power plans). The `RestoreDefaults.ps1` script reverses everything. A System Restore point is also created automatically.

**Q: Which tier should I choose?**
A: **Elite** if you have a desktop gaming rig with good cooling and don't care about power consumption. **Pro** if you have a laptop, a mixed-use machine, or want sleep/display timeout to still work.

**Q: Will this affect game anti-cheat?**
A: No. These are standard Windows configuration changes. No drivers or system files are modified.

**Q: My FPS didn't change. Is it working?**
A: The primary benefit is **lower input latency and more consistent frame times**, not necessarily higher FPS. You'll notice smoother gameplay, less stuttering, and more responsive controls. Run `powercfg /list` to verify your custom plan is active.

**Q: Does Elite increase power consumption?**
A: Yes. The CPU never idles, which increases power draw at idle by ~20-50W. Use Pro if power consumption matters.

**Q: I want to keep some tweaks but not others.**
A: The scripts are heavily commented. You can read through them and comment out (`#`) any sections you want to skip.

---

## 🔧 Troubleshooting

| Problem | Solution |
|---|---|
| "Execution Policy" error | Run `Set-ExecutionPolicy Bypass -Scope Process -Force` first |
| Script won't elevate | Right-click PowerShell → Run as Administrator, then run the script |
| Restore point fails | Windows limits one restore point per 24 hours. The script continues anyway. |
| USB device issues | Run `RestoreDefaults.ps1` — USB Selective Suspend will be re-enabled |
| System feels sluggish after Elite | Switch to Pro tier — Elite disables all idle states which increases heat |

---

## 📜 License

MIT License — use, modify, and distribute freely.

---

<div align="center">

**Built for gamers who want every last frame. ⚡**

</div>
