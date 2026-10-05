**HK IPSW Manager** is a high-performance Windows desktop application built with Flutter, designed to catalog, download, and manage Apple firmware restore files (`.ipsw`). Engineered for technicians, developers, and power users, it combines a cyber-futuristic HUD interface with an accelerated multi-threaded download engine, automated deduplication, and local storage diff analysis.

---

## ✨ Features

### 🌐 Comprehensive Catalog & Real-Time Signing Status
* **Multi-Platform Support:** Full coverage across iOS, iPadOS, macOS (Apple Silicon Universal restore images), tvOS, audioOS, and visionOS via the [ipsw.me API](https://ipsw.me/api/).
* **Commercial & Identifier Search:** Search instantly by commercial name (e.g., *"iPhone 15 Pro"*, *"MacBook Air M2"*), internal board identifier (e.g., `iPhone16,1`, `Mac14,2`), build ID, or OS version.
* **Apple Silicon & Unified Architecture:** Native grouping and badges for M-series (M1–M4) Mac restore payloads.
* **Batch Version Selection:** Multi-check and queue all devices sharing a specific firmware release (e.g., *"Download all signed 18.0.1 files"*).

### 🚀 High-Performance Multi-Threaded Downloader
* **HTTP Byte-Range Chunking:** Inspired by advanced managers like AB Download Manager, files (5 GB–18 GB+) are split into 2 to 16 concurrent chunk streams to maximize Apple CDN throughput.
* **Pause, Resume & Assembly:** Seamless resume capability with background stream assembly and temp file cleanup.
* **Dynamic Link Refresh:** Automatically queries fresh CDN download tokens if links expire or throw HTTP 403 Forbidden after extended pauses.
* **SHA1 / MD5 Integrity Sentinel:** Automatic post-download verification against official Apple release checksums to prevent corrupted restores.

### 💾 Smart Deduplication & Local Repository Scanner
* **Payload Deduplication:** Identifies hardware models sharing identical physical binaries (e.g., iPhone 12 & iPhone 12 Pro, or universal Apple Silicon IPSWs).
* **NTFS Hardlink Engine:** Saves gigabytes of disk space by downloading the payload once and generating Windows NTFS hard links (`mklink /H`) for model-specific naming conventions.
* **Folder Diff & Missing Firmware Scanner:** Point the manager to your local storage drive to scan existing `.ipsw` archives, calculate inventory health, and highlight missing signed versions with one-click bulk queueing.

---

## 🛠️ Architecture & Tech Stack

* **Framework:** Flutter Desktop (Windows 10/11 x64)
* **Design Language:** Cyber-futuristic HUD (OLED dark palette `#0B0F19`, glassmorphic panels, neon cyan/purple accents, monospace telemetry readouts)
* **State Management:** Riverpod / Clean Architecture (Presentation, Domain, Data)
* **Networking & I/O:** Dart HTTP byte-range workers, multi-isolate concurrency, and native Win32 process execution for file system hardlinks.

---

## 🚀 Getting Started

### Prerequisites
* Windows 10/11 (64-bit)
* [Flutter SDK](https://flutter.dev/docs/get-started/install/windows) (v3.19+ recommended)
* Visual Studio with Desktop development with C++ workload installed

### Installation & Run

1. Clone the repository:
   ```bash
   git clone [https://github.com/shamoos63/hk-ipsw-manager.git](https://github.com/your-username/hk-ipsw-manager.git)
   cd hk-ipsw-manager

build the app for windows:

flutter build windows


build app for MacOs:

flutter build macos

