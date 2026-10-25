# Privacy Policy

**DustBuster** — last updated 25 October 2026

DustBuster is a free, open-source macOS application developed by Murat Onurcu. This policy describes what the application does with data on your Mac.

## Summary

DustBuster does not collect, store, transmit or share any personal data. It has no user accounts, no analytics, no advertising, no crash reporting service and no network access at runtime.

## Data stored on your Mac

- The undo history of the last 50 trashed items (original path, location in the Trash, size) in the application's user defaults (`com.muratonurcu.DustBuster`), so that they can be restored from the app. `scripts/uninstall.sh` removes it.
- Scan results (file paths, sizes, dates) are held in memory while the app runs. Reports and JSON test cases are written only when you export them, to the location you choose; file paths in them refer to your own Mac, so review them before sharing.
- Diagnostic logs use Apple's unified logging (`os.log`) and stay on the device. The optional export in Settings sanitizes usernames, hostnames and home-folder paths.

All of this stays on your Mac. Nothing is uploaded anywhere.

## Data that leaves your Mac

None. DustBuster never opens a network connection. It does not check for updates and never downloads rule data; the Homebrew Cask snapshot ships inside the app.

## Permissions

- **Full Disk Access** — required to read `~/Library/Caches`, `~/Library/Logs` and application containers. DustBuster reads these locations to list caches, logs and leftovers; it never reads the contents of documents, mail, messages or browser data, and it never transmits anything.

No Accessibility, Screen Recording, location, camera, microphone, contacts or calendar permissions are used.

## Third-party components

- **Homebrew Cask** — the leftover-path database embedded in the app is generated from the `zap` and `uninstall` stanzas of the Homebrew Cask definitions (BSD-2-Clause); see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). It is data, not code, and it is never updated over the network at runtime.

No analytics SDKs, no advertising SDKs, no crash reporters.

## Children's privacy

DustBuster does not collect data from anyone, including children.

## Changes to this policy

Changes are recorded in this file and in `CHANGELOG.md`. The version history of this document is available in the repository.

## Contact

Murat Onurcu — muratonurcu@outlook.com
