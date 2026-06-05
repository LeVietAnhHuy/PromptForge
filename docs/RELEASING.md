# Releasing PromptForge

PromptForge ships desktop builds for **Linux, Windows, and macOS**. Artifacts are
produced by CI; signing/notarization are maintainer actions documented below.
Nothing here fakes a signature — unsigned artifacts are clearly labeled.

## Versioning (single source of truth)

The version lives only in [`pubspec.yaml`](../pubspec.yaml) as `version: X.Y.Z+B`
(`X.Y.Z` = semantic version, `B` = build number). Everything else derives from it:

- Artifact filenames embed `X.Y.Z` (e.g. `promptforge-1.0.0-windows-x64.msix`).
- The MSIX package version is `X.Y.Z.0` (CI passes `--version` to `msix:create`).

To cut a release, bump `version:` in `pubspec.yaml`, commit, then tag (below).

## One-command release flow

1. Bump `version:` in `pubspec.yaml` and commit on `master`.
2. Tag and push the tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. The **Release** workflow (`.github/workflows/release.yml`, triggered by `v*`
   tags) builds all three platforms and uploads version-stamped artifacts to a
   **draft GitHub Release**.
4. Download the artifacts, perform the per-platform signing below, then publish
   the draft release.

> The push/PR **CI** workflow (`.github/workflows/ci.yml`) builds + tests every
> platform on each push/PR but does not produce release artifacts.

## Artifacts per platform

| Platform | Artifact(s) | Signed? |
| --- | --- | --- |
| Windows | `promptforge-<v>-windows-x64.msix`, `promptforge-<v>-windows-x64.zip` | **Unsigned** (see below) |
| macOS   | `promptforge-<v>-macos.dmg` (zipped `.app` fallback) | **Unsigned** (see below) |
| Linux   | `PromptForge-<v>-x86_64.AppImage` (preferred), `promptforge-<v>-linux-x64.tar.gz` (always) | n/a |

Local equivalents:

```bash
# Linux (tar.gz always; AppImage best-effort)
flutter build linux --release
scripts/package_linux.sh            # -> dist/

# Windows (run on Windows)
flutter build windows --release
dart run msix:create --version 1.0.0.0   # -> build/windows/x64/runner/Release/*.msix

# macOS (run on macOS)
flutter build macos --release       # -> build/macos/Build/Products/Release/PromptForge.app
```

## Windows signing (maintainer action)

The MSIX is built **unsigned** (`msix_config: sign_msix: false` in `pubspec.yaml`),
so CI needs no certificate. Windows will not install an unsigned MSIX without a
trusted signature. To distribute:

1. Obtain a code-signing certificate:
   - **Production:** buy an OV/EV code-signing certificate from a CA (DigiCert,
     Sectigo, etc.), or publish through the **Microsoft Store** (Store signs for you).
   - **Testing only:** create a self-signed cert and have users trust it manually:
     ```powershell
     New-SelfSignedCertificate -Type Custom -Subject "CN=Le Viet Anh Huy" `
       -KeyUsage DigitalSignature -FriendlyName "PromptForge Test" `
       -CertStoreLocation "Cert:\CurrentUser\My" `
       -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3","2.5.29.19={text}")
     ```
2. Sign the MSIX (the cert Subject must equal `msix_config: publisher`,
   `CN=Le Viet Anh Huy`):
   ```powershell
   signtool sign /fd SHA256 /a /f mycert.pfx /p <password> promptforge.msix
   ```
   Or rebuild signed in one step: `dart run msix:create` with `sign_msix: true`
   and `certificate_path` / `certificate_password` set in `pubspec.yaml`
   (do **not** commit the certificate or password — pass via env/secrets).
3. The portable `.zip` is unsigned by nature; SmartScreen may warn until the
   contained `.exe` is signed.

## macOS signing + notarization (maintainer action)

CI produces an **unsigned** `.app`/`.dmg`. macOS Gatekeeper will block it until
it is signed with a Developer ID and notarized. With an **Apple Developer account**:

1. Code-sign the app with your Developer ID Application certificate (hardened
   runtime on):
   ```bash
   codesign --deep --force --options runtime --timestamp \
     --sign "Developer ID Application: Le Viet Anh Huy (TEAMID)" \
     "PromptForge.app"
   ```
2. Build a DMG (e.g. `hdiutil create -volname PromptForge -srcfolder PromptForge.app -ov -format UDZO promptforge-<v>-macos.dmg`) and sign it the same way.
3. Notarize and staple:
   ```bash
   xcrun notarytool submit promptforge-<v>-macos.dmg \
     --apple-id <apple-id> --team-id <TEAMID> --password <app-specific-password> \
     --wait
   xcrun stapler staple promptforge-<v>-macos.dmg
   ```
4. Until notarized, users must right-click → Open (or
   `xattr -dr com.apple.quarantine PromptForge.app`) to run it.

> CI never attempts signing/notarization — that requires private credentials and
> must be done by the maintainer with the Apple Developer / certificate secrets.

## Linux

The AppImage bundles libmpv (and its dependency tree, via `linuxdeploy`) so it is
self-contained. The tar.gz bundles `libmpv.so.2` (via
`scripts/bundle_linux_libmpv.sh`) but relies on the host having libmpv's own
runtime deps; the AppImage is preferred for distribution. Neither is signed
(Linux desktop apps generally aren't); checksums can be attached to the release.
