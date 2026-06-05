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
- Package manager: Flutter/Dart pub (`pubspec.lock` is committed)

## Repository layout
```text
lib/
  app/                 App shell, router, responsive navigation, theme tokens
  core/database/       Drift database, tables, DAOs, generated database code
  core/security/       Secure storage wrapper for BYOK API keys
  features/            Feature-first modules: inbox, projects, library, compiler, examples, settings
  shared/markdown/     Shared markdown reader/editor helpers
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

## Architecture decisions
- Drift is the source of truth for local persistence because PromptForge is designed as a local-first workspace with portable backup bundles.
- `PromptExamples` represent saved compiled prompt runs; `PromptExampleOutputs` represent manual or API model outputs for a run. Reuse these instead of introducing a new run/output system.
- `PromptExampleOutputs.sourceType` tracks provenance (`manual` or `api`) separately from `outputType`, so content format and capture method do not conflict.
- BYOK execution is intentionally user-triggered. The app sends prompts to a provider only when the user presses Run.
- Google/Gemini is the only real API execution provider currently wired. The provider id is `google`; legacy secure-storage key id `gemini` is still read for compatibility.
- Import/export serializes local app data but excludes secure-storage API keys by design.
- Responsive navigation uses a bottom `NavigationBar` below 700 px width and a `NavigationRail` at wider widths.
