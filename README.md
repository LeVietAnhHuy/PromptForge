# PromptForge

[![CI](https://github.com/LeVietAnhHuy/PromptForge/actions/workflows/ci.yml/badge.svg)](https://github.com/LeVietAnhHuy/PromptForge/actions/workflows/ci.yml)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

A **local-first**, cross-platform Flutter workspace for prompt engineering:
capture ideas, organize reusable prompt cards and context packs, compile prompts
with variables, and compare outputs from multiple LLM providers — all on your own
machine. No cloud sync, no account, no telemetry.

## Highlights

- **Prompt library** — CRUD with tags, favorites, search, sort, and full
  **version history** with line-level diffs and one-click restore.
- **Inbox & quick capture** — jot raw ideas (Ctrl/Cmd+Shift+N) and convert them
  into prompts later.
- **Context packs** — reusable knowledge injected into prompts at compile time.
- **Template variables** — `{{variable}}` detection, defaults, and fill-and-use.
- **Multi-model comparison** — run 2–4 models concurrently (BYOK) and compare
  outputs side-by-side with ratings, a Best pin, and provider branding.
- **Real token & cost** — usage captured from the provider; cost estimated from a
  community-maintained, user-editable pricing file (never fabricated).
- **Attachments** — inline preview for images, code, JSON, Markdown, CSV, PDF,
  audio, and video.
- **Import / export** — single-prompt Markdown export plus a lossless, versioned
  workspace bundle (with attachment files). **API keys are never exported.**

Your BYOK API keys are stored only in the OS secure store (Keychain / DPAPI /
Secret Service) — never in the database, exports, or logs.

## Platform status

PromptForge is built to run on Linux, Windows, and macOS desktops.

| Platform | Status |
| --- | --- |
| Linux   | Built, tested, and released; actively developed on |
| Windows | Target added; CI build matrix being brought up |
| macOS   | Target added; CI build matrix being brought up |

Once green, CI proves each platform **builds, analyzes, and passes tests** (the
badge above reflects the live status). Hands-on visual verification on real
Windows/macOS machines is tracked in
[`docs/VERIFICATION-STAGE26.md`](docs/VERIFICATION-STAGE26.md) and is the final
acceptance gate — we don't claim a platform "works" beyond what CI demonstrates
until that checklist is run.

## Tech stack

Flutter (Material 3) · Riverpod · go_router · Drift over SQLite ·
flutter_secure_storage · media_kit (audio/video) · pdfrx (PDF) ·
google_generative_ai (BYOK execution). Dart `>=3.2.0 <4.0.0`, Flutter `>=3.44`.

## Building from source

### Prerequisites (all platforms)

- Flutter **3.44+** (stable) — see <https://docs.flutter.dev/get-started/install>
- Generated Drift sources are committed, so a plain build needs no codegen. After
  changing database tables, regenerate with
  `dart run build_runner build --delete-conflicting-outputs`.

```bash
flutter pub get
flutter analyze
flutter test
```

### Linux

System packages are required for media playback (media_kit links the system
libmpv) and secure storage:

```bash
sudo apt-get install -y libmpv-dev mpv libsecret-1-dev   # Debian/Ubuntu
flutter run -d linux           # debug
flutter build linux --release  # release bundle
```

### Windows

Install **Visual Studio** with the *Desktop development with C++* workload, then:

```powershell
flutter run -d windows
flutter build windows --release
```

Native media (libmpv) and PDF (pdfium) libraries are bundled automatically — no
system install required.

### macOS

Install **Xcode** (+ command-line tools) and **CocoaPods** (`sudo gem install
cocoapods`), then:

```bash
flutter run -d macos
flutter build macos --release
```

## Releasing

Tagging `v*` triggers a CI workflow that builds version-stamped artifacts
(Windows MSIX + zip, macOS dmg/zip, Linux AppImage). See
[`docs/RELEASING.md`](docs/RELEASING.md) for the full process, including the
code-signing / notarization steps the maintainer performs.

## Roadmap

See [`ROADMAP.md`](ROADMAP.md) for the staged plan (cross-platform desktop, web,
sync, mobile, community gallery, and an MCP server).

## Contributing

Contributions are welcome on any OS. Please run `flutter analyze` and
`flutter test` before opening a PR; CI runs the full matrix on Linux, Windows,
and macOS.

## License

Licensed under the [Apache License 2.0](LICENSE). Copyright 2026 Le Viet Anh Huy.

Third-party fonts, provider logos, and libraries are credited in
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).
