# Changelog

All notable changes to DustBuster are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.4.0] - 2026-10-25

First public release on GitHub Releases (build 25). Earlier builds were installed from source only.

### Added
- **System Cleanup** — hybrid browser cache detection (Safari, the Firefox family, every Chromium-based browser found on the Mac, including per-profile `Cache` / `Code Cache` folders), application caches and user logs; Apple system-service caches in a separate, collapsed and unselected section.
- **App Uninstaller** built on the UI-independent `DustBusterCore` package: deterministic signals read from the bundle (bundle-ID paths, entitlement app groups, container metadata, launchd plists, embedded helpers, `pkgutil` receipts), an embedded Homebrew Cask `zap` database, a `~/Library` directory scan, per-app `conditions.json` and safety `rules.json`. Items that might be shared are listed under *Check* and left unselected.
- **Large Files**, **Running Apps** and a **Dashboard** for memory, disk and CPU.
- **Undo** for the last cleanup, the last 50 trashed items and per-app uninstalls.
- Plain-text report export and JSON **test case** export from every scan; the test suite replays test cases against a virtual `~/Library`.
- Design system with Liquid Glass on macOS 26 and the standard material look on macOS 14 and 15; universal binary.
- **DustBuster Hakkında** in the application menu (standard About window with developer contact, source link and third-party notice).
- Privacy manifest (`PrivacyInfo.xcprivacy`) bundled with the app.
- `scripts/build.sh` (build only); `scripts/install.sh` hub workflow (pull, build, archive every build to `releases/`, clean reinstall, rollback); `scripts/uninstall.sh`; `scripts/make-dmg.sh` writing to `dist/` with a laid-out disk image window and volume icon.
- Continuous integration: Core tests plus universal builds with Xcode 26 and Xcode 16 on every push; tag-triggered release workflow that builds the app, packages `.dmg` and `.zip`, writes `SHA256SUMS.txt` and publishes the GitHub Release.
- `CONTRIBUTING.md`, `SECURITY.md`, `PRIVACY.md`, `THIRD_PARTY_NOTICES.md`, issue and pull request templates.

### Changed
- License changed from GPL-3.0 to MIT; the embedded Homebrew Cask data keeps its BSD-2-Clause notice.
- Target and bundle renamed from `CleanerApp` to `DustBuster` (`com.muratonurcu.DustBuster`); the committed Xcode project was replaced by an XcodeGen `project.yml`.

[Unreleased]: https://github.com/murtaza1905/DustBuster/compare/v1.4.0...HEAD
[1.4.0]: https://github.com/murtaza1905/DustBuster/releases/tag/v1.4.0
