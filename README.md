# DustBuster

[![CI](https://github.com/murtaza1905/DustBuster/actions/workflows/ci.yml/badge.svg)](https://github.com/murtaza1905/DustBuster/actions/workflows/ci.yml)

A safe, privacy-first system cleaner for macOS. Built with SwiftUI.

## Features

- **Browser Cache Cleaning** – Safari, Firefox-family (Firefox, LibreWolf, Waterfox, Pale Moon) and every Chromium-based browser found on the system (Chrome, Brave, Edge, Opera, Vivaldi, Arc, …). History, cookies, passwords and bookmarks are never touched.
- **System & App Caches / Logs** – `~/Library/Caches`, `~/Library/Logs`, `/private/var/log`
- **Large File Finder** – files over 250 MB in Desktop, Documents, Downloads, Movies, Music, Pictures
- **App Uninstaller** – drop a `.app`, review the bundle plus its leftovers (bundle ID, embedded Homebrew Cask database, name matching), move them to Trash
- **Running Apps** – quit or force-quit third-party apps
- **System Monitor** – RAM, disk and CPU usage
- **Undo** – everything goes to the Trash; the last cleanup and the last 50 trashed items can be restored from inside the app

## Requirements

- macOS 14 (Sonoma) or later — Liquid Glass UI on macOS 26 (Tahoe), material fallback on older versions
- Full Disk Access (System Settings › Privacy & Security › Full Disk Access)
- Universal binary: Apple Silicon and Intel

## Install

### Option A — Download

1. Download the latest `.dmg` from [Releases](https://github.com/murtaza1905/DustBuster/releases)
2. Drag **DustBuster.app** to **Applications**
3. Grant Full Disk Access, then switch back to the app

### Option B — Build from source (one command)

Requires Xcode. No Homebrew needed — the script downloads XcodeGen on its own if it is missing.

```bash
cd ~/Desktop
git clone https://github.com/murtaza1905/DustBuster.git
cd ~/Desktop/DustBuster
./scripts/install.sh
```

The script pulls the latest code, generates the Xcode project, builds a universal Release binary, ad-hoc signs it, archives it to `releases/`, replaces the copy in `/Applications` and launches it. The cloned folder is meant to stay as a permanent "hub": run the same command again to update.

```bash
cd ~/Desktop/DustBuster
./scripts/install.sh                        # update + clean reinstall
./scripts/install.sh --list                 # archived builds in releases/
./scripts/install.sh releases/<file>.zip    # reinstall an archived build
```

Other scripts:

| Script | Purpose |
|---|---|
| `./scripts/install.sh` | Pull, build, archive, clean-install to `/Applications`, launch |
| `./scripts/uninstall.sh` | Remove the app and its preferences |
| `./scripts/make-dmg.sh` | Build a universal `.dmg` into `dist/` |

To open the project in Xcode instead: run `./scripts/install.sh` once (or `xcodegen generate`), then open `DustBuster.xcodeproj`.

## How the uninstaller finds leftovers

Matching lives in a UI-independent Swift package (`Core/`) and runs in four layers:

1. **Exact paths** — well-known locations derived from the bundle ID (`~/Library/Preferences/<id>.plist`, `Containers/<id>`, …). Always selected.
2. **Homebrew Cask database** — a snapshot of the community-maintained `zap` stanzas from [Homebrew/homebrew-cask](https://github.com/Homebrew/homebrew-cask) (BSD-2-Clause), embedded in the app. No network access; refresh with `python3 tools/build-cask-db.py <homebrew-cask checkout>`. Always selected.
3. **Directory scan** — bundle-ID and whole-word name matching inside `~/Library`, including vendor folders (`Google/Chrome`). Name-only hits are listed **unselected** and labelled.
4. **Safety rules** — other apps from the same vendor, channel variants (Canary/Beta), `com.apple.*` paths for non-Apple apps, protected user data (Keychains, Mail, Documents…) and empty folders are never listed.

Every real-world scan can be exported from the app as a JSON test case (**Test vakası**) and dropped into `Core/Tests/Fixtures/`; the test suite replays it against a virtual `~/Library`. CI runs the suite and builds the app on every push.

```bash
cd ~/Desktop/DustBuster/Core
swift test
```

## Project layout

```
DustBuster/
├── Info.plist
├── Resources/Assets.xcassets      # App icon, accent color
└── Sources/
    ├── App/                       # App entry, navigation
    ├── Managers/                  # Cleaning, uninstall glue, permissions, logging, monitoring
    ├── Models/
    ├── ViewModels/
    └── Views/
Core/                              # DustBusterCore Swift package (no UI)
├── Sources/DustBusterCore/        # Scanner, matching rules, cask database, fixtures
│   └── Resources/cask-zap.json    # Embedded Homebrew snapshot
└── Tests/                         # XCTest suite + Fixtures/*.json
tools/                             # build-cask-db.py, make-fixtures.py
project.yml                        # XcodeGen project definition
scripts/                           # install / uninstall / make-dmg
```

## Privacy

- All operations run locally; nothing is sent anywhere (the Homebrew database is embedded, never downloaded at runtime)
- Logs stay on the device (os.log) and are sanitized of usernames, hostnames and home paths; export is manual only
- Files are moved to the Trash, never deleted directly

## License

[GPL-3.0](LICENSE)

## Developer

Murat Onurcu – muratonurcu@outlook.com
