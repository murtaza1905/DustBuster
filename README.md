# DustBuster

[![CI](https://github.com/murtaza1905/DustBuster/actions/workflows/ci.yml/badge.svg)](https://github.com/murtaza1905/DustBuster/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/murtaza1905/DustBuster?display_name=tag)](https://github.com/murtaza1905/DustBuster/releases/latest)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A privacy-first cleaner and app uninstaller for macOS. Everything runs on your Mac, nothing is sent anywhere, and nothing is ever deleted — items go to the Trash and can be restored from inside the app.

## What it does

- **System Cleanup** — browser caches (Safari, the Firefox family and every Chromium-based browser it finds, including the per-profile `Cache` / `Code Cache` folders), application caches and user logs in `~/Library`. Apple system-service caches are listed in a separate, collapsed section and left unselected, because macOS simply regenerates them. History, cookies, passwords and bookmarks are never touched.
- **App Uninstaller** — drop a `.app`, review the bundle together with its leftovers, and move the selection to the Trash. Items found by a deterministic signal are preselected; anything that might be shared with another app (vendor folders, shared app groups, name-only matches) is listed under *Check* and left unselected.
- **Large Files** — files of 250 MB or more in Desktop, Documents, Downloads, Movies, Music and Pictures.
- **Running Apps** — quit or force-quit third-party apps.
- **Dashboard** — memory, disk and CPU at a glance.
- **Undo** — the last cleanup and the last 50 trashed items can be restored from the app; uninstalls can be undone per app.
- **Reports and test cases** — every scan can be exported as a plain-text report and as a JSON test case that becomes a permanent regression test (see below).

## Requirements

- macOS 14 Sonoma or later. Universal binary (Apple Silicon and Intel). The UI uses Liquid Glass on macOS 26 and the standard material look on macOS 14 and 15.
- Full Disk Access (System Settings › Privacy & Security › Full Disk Access) — needed to read `~/Library/Caches`, `~/Library/Logs` and app containers.
- To build from source: Xcode 16 or later.

## Install

### Download

1. Get the latest `DustBuster-<version>.dmg` from [Releases](https://github.com/murtaza1905/DustBuster/releases/latest) and drag **DustBuster.app** to **Applications**.
2. The app is ad-hoc signed, not notarized. On first launch macOS will refuse to open it; either right-click the app › **Open**, or run:

   ```bash
   xattr -dr com.apple.quarantine /Applications/DustBuster.app
   ```

3. Grant Full Disk Access when asked and switch back to the app.

### Build from source

Requires Xcode. No Homebrew needed — the script downloads XcodeGen on its own if it is missing.

```bash
cd ~/Desktop
git clone https://github.com/murtaza1905/DustBuster.git
cd ~/Desktop/DustBuster
./scripts/install.sh
```

The script pulls the latest code, generates the Xcode project, builds a universal Release binary, ad-hoc signs it, archives the build to `releases/`, replaces the copy in `/Applications` and launches it. Keep the cloned folder as a permanent hub and run the same command again to update. A failed build never touches the installed app.

```bash
cd ~/Desktop/DustBuster
./scripts/install.sh                        # update + clean reinstall
./scripts/install.sh --list                 # archived builds in releases/
./scripts/install.sh releases/<file>.zip    # reinstall an archived build
./scripts/uninstall.sh                      # remove the app and its preferences
./scripts/make-dmg.sh                       # build a universal .dmg into dist/
```

To work in Xcode: run `./scripts/install.sh` once (or `xcodegen generate`), then open `DustBuster.xcodeproj`.

## How the uninstaller finds leftovers

Matching lives in a UI-independent Swift package (`Core/`) and runs in five layers:

1. **Deterministic signals read from the bundle itself** — well-known paths derived from the bundle ID; app groups declared in the code-signature entitlements (`Group Containers`, `Application Scripts`); container ownership from containermanagerd metadata (works for UUID-named containers); launchd plists whose program lives inside the bundle; embedded helpers' containers; `pkgutil` receipts (with the system scan on). Preselected.
2. **Homebrew Cask database** — a snapshot of the community-maintained `zap` stanzas from [Homebrew/homebrew-cask](https://github.com/Homebrew/homebrew-cask), embedded in the app and never downloaded at runtime. Suite casks (Office) are resolved to the single-app cask; paths that other casks also own are treated as shared. Refresh with `python3 tools/build-cask-db.py <homebrew-cask checkout>`.
3. **Directory scan** — bundle-ID and whole-word name matching inside `~/Library`, including vendor folders (`Google/Chrome`). Name-only hits are listed under *Check*, unselected.
4. **Per-app conditions** (`Core/Sources/DustBusterCore/Resources/conditions.json`) — explicit `include` / `exclude` globs for apps whose leftovers follow no convention (Xcode's `~/Library/Developer`, Notion's updater cache). Matched by bundle ID or Homebrew token; adding an app is a data change, not a code change.
5. **Safety rules** — other apps from the same vendor, channel variants (Canary/Beta), `com.apple.*` paths for non-Apple apps, vendor-named folders (`Application Support/Microsoft`) and protected user data (Keychains, Mail, Documents…) are never preselected or never listed, whatever layer proposed them. Empty sandbox shells found by a deterministic signal are listed and labelled; empty folders found only by name similarity are dropped.

System Cleanup is driven by data as well (`Core/Sources/DustBusterCore/Resources/rules.json`): scanned roots, forbidden roots, sensitive keywords, the Apple system-service list, vendor folders that are split into their children, and browser definitions.

### Regression tests

Every real-world scan can be exported from the app as a JSON test case (**Test vakası**) and dropped into `Core/Tests/DustBusterCoreTests/Fixtures/`; the test suite replays it against a virtual `~/Library` and checks what must be selected, what must be listed unselected and what must never appear. CI runs the suite and builds the app with both Xcode 26 and Xcode 16 on every push.

```bash
cd ~/Desktop/DustBuster/Core
swift test
```

## Privacy

- No network access. The Homebrew database and all rules are embedded in the app.
- Logs stay on the device (os.log) and are sanitized of usernames, hostnames and home paths; export is manual only.
- Files are moved to the Trash, never deleted directly.

## Project layout

```
DustBuster/                        # SwiftUI app (views, view models, managers)
Core/                              # DustBusterCore Swift package (no UI)
├── Sources/DustBusterCore/        # Scanner, matching rules, cask database, cleanup policy, fixtures
│   └── Resources/                 # cask-zap.json, conditions.json, rules.json
└── Tests/                         # XCTest suite + Fixtures/*.json
tools/                             # build-cask-db.py, make-fixtures.py
scripts/                           # install / uninstall / make-dmg
design/                            # App icon master
project.yml                        # XcodeGen project definition
```

## License

DustBuster is released under the [MIT License](LICENSE). The embedded leftover database is derived from Homebrew Cask (BSD-2-Clause); see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## Author

Murat Onurcu — muratonurcu@outlook.com
