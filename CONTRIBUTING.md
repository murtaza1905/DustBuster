# Contributing to DustBuster

Thank you for taking the time to contribute. Bug reports, feature ideas, documentation fixes and code are all welcome.

## Reporting a bug

- Open an issue with the **Bug report** template.
- Include your macOS version, whether the Mac is Intel or Apple Silicon, the DustBuster version (shown in the About window) and the exact steps to reproduce.
- For a wrong match or a miss in the **App Uninstaller** or **System Cleanup**, attach the report the app exports (`.txt`) or, better, the JSON test case (**Test vakası**). A test case can be replayed by the test suite and becomes a permanent regression test, so it is the fastest route to a fix.
- Mention whether Full Disk Access was granted and which macOS version the Mac runs (the UI differs between macOS 14/15 and 26).

## Suggesting a feature

- Open an issue with the **Feature request** template.
- Describe the problem you are trying to solve before the solution you have in mind.

## Development setup

Xcode 16 or later. XcodeGen is downloaded into `.tools/` automatically when it is not installed; Homebrew is not required. The matching logic lives in the `Core/` Swift package and has its own test suite.

```bash
git clone https://github.com/murtaza1905/DustBuster-macOS.git
cd DustBuster-macOS
./scripts/build.sh          # build/DustBuster.app (universal, ad-hoc signed)
./scripts/install.sh        # pull, build, archive to releases/, install to /Applications, launch
(cd Core && swift test)     # DustBusterCore fixture tests
```

The Xcode project is generated from `project.yml`; it is not committed. Run `./scripts/install.sh` once (or `xcodegen generate`) and open `DustBuster.xcodeproj`. Keep the clone as a permanent hub: `install.sh` pulls, builds, archives every build to `releases/` and reinstalls on top of the previous one. Matching rules are data: `conditions.json` (per-app include/exclude globs), `rules.json` (cleanup policy) and `cask-zap.json` (Homebrew Cask snapshot, regenerated with `tools/build-cask-db.py`). New real-world cases go into `Core/Tests/DustBusterCoreTests/Fixtures/` as JSON test cases rather than into code.

## Pull requests

1. Fork the repository and create a branch from `main`.
2. Keep each pull request focused on one change.
3. Make sure the project builds with `./scripts/build.sh` and `(cd Core && swift test)` — the CI workflow runs the same check on every pull request.
4. Add a line to the **Unreleased** section of `CHANGELOG.md`.
5. Open the pull request; the template lists what to include.

## Code style

- Swift, following Apple's API Design Guidelines; four-space indentation; no trailing whitespace.
- No new third-party dependencies without prior discussion in an issue.
- The interface is currently Turkish; new user-facing strings follow the wording of the surrounding views. English localization is a roadmap item — when it lands, every string moves to a string catalog.
- Shell scripts use `set -euo pipefail` and must run on a clean Mac with only Xcode installed.

## Release process (maintainers)

1. Bump the version (`MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in `project.yml`) and move the **Unreleased** notes in `CHANGELOG.md` under the new version heading.
2. Commit, push to `main` and wait for CI to pass.
3. Start the release in one of two ways:
   - **Actions tab → Release → Run workflow**, enter the version (for example `1.2.0`). The workflow creates and pushes the tag itself.
   - Or tag from Terminal:

     ```bash
     git tag v<version>
     git push origin v<version>
     ```

4. The **Release** workflow builds a universal (Apple Silicon + Intel) app, packages the `.dmg` and `.zip`, writes `SHA256SUMS.txt` and publishes the GitHub Release using the matching `CHANGELOG.md` section as release notes. The version must match the project version or the run stops before building.

## License

By contributing you agree that your contributions are licensed under the [MIT License](LICENSE).
