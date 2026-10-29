# Security Policy

## Supported versions

Only the latest release on the [Releases](https://github.com/murtaza1905/DustBuster-macOS/releases/latest) page receives fixes. Please update before reporting a problem.

## Reporting a vulnerability

Please do **not** open a public issue for security problems.

Email **muratonurcu@outlook.com** with:

- a description of the issue and its impact,
- steps to reproduce or a proof of concept,
- the DustBuster version and macOS version you tested on.

You will receive an acknowledgement within 7 days. Once the issue is confirmed, a fix is prepared and published as a new release, and the report is credited in `CHANGELOG.md` unless you prefer to stay anonymous.

## Security model

- DustBuster never deletes a file outright: everything it removes goes to the Trash through the system API and can be restored from the app (last cleanup, last 50 items, per-app uninstall).
- Protected user data (Keychains, Mail, Documents, browser history, cookies, passwords, bookmarks) is excluded by rules that apply whatever a matching layer proposes; see `rules.json` and `conditions.json` in `Core/`.
- Full Disk Access is requested only to read `~/Library/Caches`, `~/Library/Logs` and app containers. The app has no network code; the Homebrew Cask database and all rules are embedded.
- Logs stay on the device, are sanitized of usernames, hostnames and home paths, and are exported only when you click the button in Settings.
- Releases are built by GitHub Actions from the tagged commit; the workflow is in `.github/workflows/release.yml` and every build log is public.

## Verifying downloads

Every release ships a `SHA256SUMS.txt` file. To verify a download:

```bash
cd ~/Downloads
shasum -a 256 -c SHA256SUMS.txt --ignore-missing
```
