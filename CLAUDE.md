# promptForge

## What this is
PromptForge is a local-first Flutter workspace for prompt engineering. It helps users capture prompt ideas, organize reusable prompt cards and context packs, compile prompts with variables, and compare outputs from multiple LLM providers. It is built for single-user local workflows; there is no cloud sync or account system.

## Tech stack
- Dart SDK constraint: `>=3.2.0 <4.0.0`
- Flutter app with Material 3 UI
- State management: `flutter_riverpod`
- Routing: `go_router`
- Local database: Drift over SQLite (`drift`, `sqlite3_flutter_libs`, generated `*.g.dart`)
- Secure API key storage: `flutter_secure_storage`
- LLM execution v0: `google_generative_ai` for Google/Gemini plus a mock provider for tests
- Import/export: `archive` for `.promptforge` zip bundles and `file_selector` for file picking
- Markdown UI: `flutter_markdown_plus`
- Vector logos: `flutter_svg` (provider brand marks)
- Attachment previews: `flutter_highlight` (code syntax highlighting), `url_launcher` (open files in a system app); CSV/TSV parsed with a small in-repo RFC-4180 parser
- Inline media: `pdfrx` (PDF, bundles `libpdfium.so`), `media_kit` + `media_kit_video` + `media_kit_libs_video` (audio/video via libmpv). `MediaKit.ensureInitialized()` runs in `main.dart`. NOTE: on Linux, media_kit links the **system** `libmpv.so.2` (package `libmpv2`/`mpv`); it is not bundled — see HANDOFF for the packaging copy step. PDF (pdfium) is bundled.
- Self-hosted fonts (OFL): Space Grotesk (display), Atkinson Hyperlegible (body), JetBrains Mono (mono) under `assets/fonts/`
- Package manager: Flutter/Dart pub (`pubspec.lock` is committed)

## Repository layout
```text
lib/
  app/theme/           Design tokens (app_design.dart) + the "forge" ThemeData (theme.dart)
  app/                 App shell, router, responsive navigation, command-palette shortcut
  core/database/       Drift database, tables, DAOs, generated database code
  core/security/       Secure storage wrapper for BYOK API keys
  features/            Feature-first modules: inbox, projects, library, compiler, examples, search, settings
  shared/markdown/     Shared markdown reader/editor helpers
  shared/providers/    provider_identity.dart — provider→logo/accent registry
  shared/attachments/  attachment_viewer.dart — modal attachment preview
assets/fonts/          Self-hosted OFL fonts
assets/provider_icons/ Bundled provider brand SVGs (Simple Icons CC0 + authored marks)
test/                  Unit and widget tests for DAOs, services, screens, and layouts
docs/                  Historical stage handoffs, validation notes, known limitations
android/ ios/ linux/   Flutter platform folders
```

## Commands
- Install: `flutter pub get`
- Generate Drift code: `dart run build_runner build --delete-conflicting-outputs`
- Run dev app: `flutter run -d linux` (or another available Flutter device)
- Build: `flutter build linux`
- Test: `flutter test`
- Lint/format: `flutter analyze` and `dart format .`

## Conventions
- Keep the app local-first. Do not add cloud sync, accounts, remote storage, or secret export paths unless explicitly requested.
- Use the existing feature-first layout: `presentation/` for widgets/screens, `application/` for providers/services, `domain/` for pure logic/models.
- Use Riverpod providers for database/services instead of creating direct database instances inside UI code.
- Use existing Drift DAOs in `lib/core/database/daos/daos.dart`; do not duplicate tables, DAOs, or project/example/output concepts.
- If tables change, update `lib/core/database/tables/tables.dart`, update migrations in `lib/core/database/database.dart`, then run build runner.
- API keys are saved only through `SecureStorageService`; never store them in Drift, import/export payloads, logs, tests, or docs.
- Preserve manual output capture as the fallback for API execution failures or missing keys.
- Keep responsive fixes targeted. Prefer stacking controls and scrollable text areas over large redesigns.
- Match existing Material widget style and concise code comments.
- Use design tokens from `lib/app/theme/app_design.dart` (spacing, radii, motion, the forge color ramp, font-family names) and the derived `ThemeData`; do not hardcode colors or magic spacing. Extra semantic colors live on the `ForgeTokens` theme extension (`context.forge`). Wrap non-essential animations in `AppDesign.motion(context, ...)` to respect reduced motion.
- Provider visual identity (display name, brand accent, logo) is data-driven in `lib/shared/providers/provider_identity.dart`; add a provider with a one-line registry entry (and optionally drop `assets/provider_icons/<id>.svg`). Render with the `ProviderLogo` widget.
- The LLM model catalog is a single data source in `lib/features/prompt_examples/application/llm_model_catalog.dart` (`isLegacy`/`isPreview` are metadata booleans); the `ModelPickerField` renders the grouped/legacy/recent picker. Adding models requires no widget changes.
- Bundle any new fonts/logos locally with their license, and note them in `THIRD_PARTY_NOTICES.md`; use provider logos only to identify the provider, unmodified.

## Architecture decisions
- Drift is the source of truth for local persistence because PromptForge is designed as a local-first workspace with portable backup bundles.
- `PromptExamples` represent saved compiled prompt runs; `PromptExampleOutputs` represent manual or API model outputs for a run. Reuse these instead of introducing a new run/output system.
- `PromptExampleOutputs.sourceType` tracks provenance (`manual` or `api`) separately from `outputType`, so content format and capture method do not conflict.
- BYOK execution is intentionally user-triggered. The app sends prompts to a provider only when the user presses Run.
- Google/Gemini is the only real API execution provider currently wired. The provider id is `google`; legacy secure-storage key id `gemini` is still read for compatibility.
- Import/export serializes local app data but excludes secure-storage API keys by design.
- Responsive navigation uses a bottom `NavigationBar` below 700 px width and a `NavigationRail` at wider widths.
- The UI uses a dark-first "forge" design system (deep warm charcoal + ember accent). The dark `ColorScheme` fills the Material 3 surface-container slots, so screens adopt it without per-widget changes; the app pins `ThemeMode.dark`.
- The Edit Prompt screen splits into two independently scrolling columns at ≥1100 px (body editor | saved outputs) and collapses to one scroll view below; saving stays in place so the "Saved ·" indicator can update.
- Saved-output edits reuse `ManualOutputPasteDialog` in edit mode (it updates the output in place and stamps `updatedAt`); the per-card "edited" indicator is derived from `updatedAt` vs `createdAt` — no schema change was needed.
- Attachment previews render in-app for image/SVG/text/code/JSON/Markdown/CSV/ZIP; PDF/video/audio intentionally fall back to "open externally" because reliable Linux-desktop AV/PDF rendering needs native backends (libmpv/pdfium) that aren't bundled. HTML is shown as escaped text; attachment bytes are treated as untrusted data and never executed.
- There is no Search tab; per-tab search plus a global Ctrl/Cmd+K command palette (`lib/features/search/`) are the search surfaces. The palette queries existing DAOs rather than a separate index.
- Output ratings (1-5 `score`) and the Best pin (`isBest`) are mutated only through `PromptExampleOutputDao` and rendered by the one shared `OutputRatingBar` widget, so every surface stays in sync. Best is scoped per-prompt in the library Saved Outputs (`markOutputAsBestForPrompt`, because it aggregates many one-output examples) and per-example in the comparison/run surfaces (`markOutputAsBest`).
- Token/cost are never fabricated: outputs store only real provider-reported token counts (`inputTokens`/`outputTokens`, null when absent); cost is derived at display time from `assets/pricing/model_pricing.json` — a community-maintained, user-editable data file (Settings → Model pricing). Show "—" unless real tokens AND a price entry exist; computed costs are labelled "est."; an incomplete per-prompt sum is labelled "… · partial".
- Multi-model comparison runs targets concurrently via `LlmExecutionService.executeAndSaveMany`; each target is isolated so one failure (or throw) never aborts the others — failed targets render as per-column error panels and are not persisted.
- BYOK outputs record provenance (`promptVersionId` = the prompt version at run time, plus model); manual outputs have none. The export bundle (schemaVersion 4, zip with `backup.json` + `attachments/<id>` bytes) is lossless except `promptVersionId`, which is omitted because import regenerates version row IDs. Exports never contain API key material.
- The OS-global quick-capture hotkey is deferred (unverifiable headless); the in-app Ctrl/Cmd+Shift+N `QuickCaptureDialog` ships. `hotkey_manager` is the intended path once a real display is available.
- Cross-platform desktop (Linux/Windows/macOS) is verified by the GitHub Actions matrix in `.github/workflows/ci.yml` (analyze + test + release build per OS, with a post-build assertion that libmpv + pdfium shipped). Development happens on Linux; Windows/macOS are CI-verified, with final visual sign-off via `docs/VERIFICATION-STAGE26.md`. Never claim a platform works beyond what CI proves. The bundle/application id is `io.github.levietanhhuy.promptforge`; Flutter is pinned `>=3.44.0` and CI pins 3.44.0.
- All command shortcuts go through one helper, `cmdOrCtrl()` in `lib/shared/shortcuts/keyboard_shortcuts.dart` (Cmd on macOS, Ctrl on Windows/Linux); never hand-roll separate `control:`/`meta:` bindings.
- Media backend per platform: media_kit bundles libmpv on Windows/macOS via `media_kit_libs_video`; Linux links the **system** libmpv and `scripts/bundle_linux_libmpv.sh` copies it into release artifacts (the AppImage bundles its full dep tree). Init is guarded (`initMediaBackend()` → `mediaBackendReady` in `lib/shared/attachments/media_capability.dart`); the audio/video renderers skip player creation and show the error panel + "Open externally" when the backend is unavailable — never a crash.
- Secure storage uses each OS's store explicitly (Windows DPAPI, macOS Keychain data-protection, Linux Secret Service); reads degrade to null (→ manual fallback) and writes throw `SecureStorageException` so the UI can warn. macOS entitlements grant network-client + user-selected-files with App Sandbox on. Minimum window size is 800×600 on all three.
- Release artifacts are produced only by `.github/workflows/release.yml` on `v*` tags: unsigned MSIX + portable zip (Windows), dmg + zip (macOS), AppImage + tar.gz (Linux), version-stamped from `pubspec.yaml`. Signing/notarization are maintainer actions documented in `docs/RELEASING.md`; CI never fakes a signature.
- MCP server (`bin/promptforge_mcp.dart`) is a **standalone stdio sidecar**, not part of the Flutter app: a pure-Dart CLI sharing the data layer, that MCP clients spawn over stdio. Rationale: works whether or not the GUI is running; no network listener / port / auth surface (stdio only); the standard local-MCP pattern. It is **read-only** (opens SQLite read-only via `package:sqlite3`, never writes), **off by default** (gated on the `mcp_enabled` UserSettings row, which the Settings toggle writes), and exposes only the prompt library — API keys live in the OS keychain, not this database, so they're unreachable through every MCP surface by construction.
- MCP SDK = **`dart_mcp`** (official Dart-team package), pinned; chosen over `mcp_dart` for its focused, mixin-based server API (`MCPServer` + `PromptsSupport`/`ToolsSupport` over `stdioChannel`) that cleanly matches a minimal read-only server. It requires Dart `^3.7.0`, so the SDK floor was raised to `>=3.7.0` (we already require Flutter ≥3.44 = Dart 3.12). Variable resolution is shared with the in-app compiler via the Flutter-free `lib/features/prompt_compiler/domain/variable_resolver.dart` so the sidecar (which can't import Flutter/Drift) and `PromptCompilerService` never diverge.
- The sidecar is built with **`dart build cli`** (produces `bundle/bin/` + `bundle/lib/`), **not** `dart compile exe`: `sqlite3` (and transitive `pdfium_dart`) ship native build hooks that `dart compile exe` rejects. `dart build cli` runs the hooks and bundles the native SQLite library, making the sidecar self-contained on every OS (incl. Windows). Deviation from the Stage 27 brief's `dart compile exe`, logged in HANDOFF.

