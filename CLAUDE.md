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

