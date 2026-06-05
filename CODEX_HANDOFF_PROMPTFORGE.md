# PromptForge Codex Handoff

## 1. Executive Summary

PromptForge is a local-first, cross-platform Flutter workspace application designed for advanced prompt engineering. It provides a cohesive environment to support the entire prompt engineering lifecycle on a local machine, without mandatory cloud synchronization. The application allows users to capture raw ideas in a prompt inbox, organize prompts with tags and collections, manage context packs, inject dynamic variables, compile prompts with target tool profiles, and compare generated outputs from multiple LLMs. 

## 2. Current Repository State

- **Current branch:** `master`
- **Remote URL:** `https://github.com/LeVietAnhHuy/PromptForge.git` (origin)
- **Latest commit hash:** `3d9f7c2` (Stage 22.14: integrate model catalog and fix file picker)
- **Working tree status:** Clean
- **Whether local repo is clean:** Yes
- **Whether remote appears configured correctly:** Yes

## 3. Completed Feature Summary

### Prompt Library
- **What exists:** Full CRUD operations for prompts, including favorites, archiving, and usage tracking. A focused rich markdown editor is implemented for prompt bodies.
- **Main files:** `lib/features/prompt_library/presentation/prompt_library_screen.dart`, `lib/features/prompt_library/presentation/prompt_editor_screen.dart`, `lib/features/prompt_library/presentation/prompt_body_focus_editor.dart`
- **Database tables/DAOs:** `Prompts` table, `PromptDao`
- **Tests involved:** `test/prompt_library_test.dart`, `test/prompt_editor_test.dart`
- **Known limitations:** Platform visual validation is missing for mobile layouts.

### Prompt Inbox
- **What exists:** A raw text capture mechanism to draft ideas that can later be converted into prompts or workspace runs. Includes a markdown block parser and inline preview.
- **Main files:** `lib/features/inbox/presentation/inbox_screen.dart`, `lib/features/inbox/presentation/inbox_editor_screen.dart`, `lib/features/inbox/presentation/inbox_to_prompt_card_dialog.dart`
- **Database tables/DAOs:** `InboxItems` table, `InboxItemDao`
- **Tests involved:** `test/inbox_test.dart`, `test/inbox_screen_test.dart`, `test/inbox_editor_screen_test.dart`, `test/inbox_processing_test.dart`
- **Known limitations:** Unclear handling of large pasted documents.

### Context Packs
- **What exists:** Reusable chunks of contextual knowledge that can be attached to multiple prompts.
- **Main files:** `lib/features/context_packs/presentation/context_packs_screen.dart`, `lib/features/context_packs/presentation/context_pack_editor_screen.dart`
- **Database tables/DAOs:** `ContextPacks` table, `PromptContextPackLinks` table, `ContextPackDao`
- **Tests involved:** `test/context_packs_test.dart`
- **Known limitations:** No semantic search available for context linking.

### Variables and Compiler
- **What exists:** Users can define dynamic variables inside prompts and compile them with context packs and variables into a final output string. Supports target tool profiles.
- **Main files:** `lib/features/prompt_compiler/presentation/prompt_compiler_screen.dart`, `lib/features/prompt_compiler/domain/prompt_compiler_service.dart`, `lib/features/prompt_compiler/domain/target_tool_profile.dart`
- **Database tables/DAOs:** `PromptVariables` table, `PromptVariableDao`
- **Tests involved:** `test/prompt_compiler_service_test.dart`, `test/prompt_compiler_screen_test.dart`, `test/prompt_variable_test.dart`
- **Known limitations:** Validation for missing/required variables during compilation edge cases might need more comprehensive testing.

### Variable Metadata
- **What exists:** Variables support rich metadata including `label`, `description`, `defaultValue`, `exampleValue`, `isRequired`, and `sortOrder`.
- **Main files:** `lib/core/database/tables/tables.dart` (PromptVariables), `lib/features/prompt_library/presentation/prompt_editor_screen.dart`
- **Database tables/DAOs:** `PromptVariables` table, `PromptVariableDao`
- **Tests involved:** `test/prompt_variable_test.dart`
- **Known limitations:** Complex types (e.g., lists, JSON objects) as variable inputs are not fully typed.

### Tags and Organization
- **What exists:** Prompts can be categorized using tags with custom colors and grouped into collections.
- **Main files:** `lib/core/database/tables/tables.dart` (Tags, Collections)
- **Database tables/DAOs:** `Tags`, `PromptTags`, `Collections`, `PromptCollectionLinks` tables; `TagDao`, `CollectionDao`
- **Tests involved:** `test/tagging_test.dart`
- **Known limitations:** Basic text matching only.

### Import / Export
- **What exists:** Functionality to export and import vault data. Codec services are built using `archive` and `file_selector`.
- **Main files:** `lib/features/import_export/presentation/import_screen.dart`, `lib/features/import_export/presentation/export_preview_screen.dart`, `lib/features/import_export/domain/import_export_codec.dart`
- **Database tables/DAOs:** None directly, interacts with all DAOs via `ImportExportService`.
- **Tests involved:** `test/import_export_test.dart`, `test/import_export_screen_test.dart`
- **Known limitations:** The v0 implementation may lack intelligent conflict resolution (duplicates or overwrites may occur).

### Backup Bundle
- **What exists:** `.promptforge` archive backup bundle support is implemented via the `archive` and `file_selector` packages within the Import/Export feature.
- **Main files:** `lib/features/import_export/domain/import_export_codec.dart`
- **Database tables/DAOs:** N/A
- **Tests involved:** `test/import_export_test.dart`
- **Known limitations:** Large bundle sizes might cause memory pressure on mobile devices.

### Version History
- **What exists:** Version history tracking for both prompts and context packs.
- **Main files:** `lib/features/prompt_library/presentation/prompt_version_history_screen.dart`, `lib/features/context_packs/presentation/context_pack_version_history_screen.dart`
- **Database tables/DAOs:** `PromptVersions`, `ContextPackVersions` tables; `PromptDao`, `ContextPackDao`
- **Tests involved:** `test/version_history_test.dart`
- **Known limitations:** Overwriting a prompt directly is destructive in some contexts if a new version snapshot isn't triggered.

### Prompt Examples
- **What exists:** Project-based workflow to save test cases and examples for prompts.
- **Main files:** `lib/features/prompt_examples/presentation/prompt_examples_screen.dart`, `lib/features/projects/presentation/prompt_run_editor_screen.dart`
- **Database tables/DAOs:** `PromptExamples` table, `PromptExampleDao`
- **Tests involved:** `test/prompt_examples_test.dart`
- **Known limitations:** Test cases might lack full automated assertion validation capabilities.

### Multi-LLM Output Comparison
- **What exists:** Manual output capture and comparison across multiple LLM models and providers. Outputs can be text, and can include file attachments. Output ranking (isBest).
- **Main files:** `lib/features/prompt_examples/presentation/example_comparison_screen.dart`, `lib/features/prompt_examples/presentation/manual_output_paste_dialog.dart`, `lib/features/prompt_examples/application/llm_model_catalog.dart`
- **Database tables/DAOs:** `PromptExampleOutputs`, `LLMProviders`, `LLMModels`, `LLMOutputAttachments` tables; `PromptExampleOutputDao`, `LLMProviderDao`, `LLMModelDao`, `LLMOutputAttachmentDao`
- **Tests involved:** `test/llm_model_catalog_test.dart`
- **Known limitations:** API Key integration is mocked or limited. Currently relies heavily on manual output capture rather than direct API calls.

### Settings / Navigation / Layout
- **What exists:** Responsive shell layout using GoRouter and persistent settings management. Features premium markdown themes and TOC navigation.
- **Main files:** `lib/app/layout/responsive_shell.dart`, `lib/app/router/router.dart`, `lib/features/settings/presentation/settings_screen.dart`, `lib/features/settings/presentation/api_keys_screen.dart`
- **Database tables/DAOs:** `UserSettings` table, `UserSettingsDao`
- **Tests involved:** `test/app_test.dart`
- **Known limitations:** Responsive shell might not perfectly adapt to very small mobile screens.

## 4. Architecture Overview

PromptForge uses a feature-first architectural pattern combined with Flutter Riverpod for state management:

- **Flutter app structure:** Organized into `lib/app/` (core app config, theme, router), `lib/core/` (database, security), `lib/shared/` (shared UI components like markdown editors), and `lib/features/` (feature-specific code).
- **Routing approach:** Declarative routing using `go_router` (`lib/app/router/router.dart`).
- **Riverpod/state management:** Providers are grouped in `application` folders within each feature (e.g., `lib/features/prompt_library/application/prompt_providers.dart`).
- **Drift database usage:** SQLite via Drift (`lib/core/database/database.dart`). Code is generated into `*.g.dart` files. Data access is abstracted behind specific DAOs (`lib/core/database/daos/daos.dart`).
- **Feature folder organization:** Each feature folder typically contains `presentation/` (screens, widgets), `application/` (providers, services), and `domain/` (models, parsers).
- **Important patterns Codex must follow:** Ensure Drift database changes update both `tables.dart` and `daos.dart`, followed by running `build_runner`. Riverpod providers should be used for all state bridging to DAOs. Avoid direct UI-to-DB calls.

## 5. Database and Persistence Overview

The application utilizes Drift for SQLite local persistence. Key relationships include:

- **prompts:** The central table (`Prompts`). Connects `1:N` to `PromptVersions` and `PromptVariables`.
- **tags:** Connects to `Prompts` via the junction table `PromptTags` (`M:N`). Collections connect via `PromptCollectionLinks`.
- **variables:** Stored in `PromptVariables`. Linked to a specific prompt via `promptId`.
- **context packs:** Stored in `ContextPacks`. Links to `Prompts` via `PromptContextPackLinks`. Has history in `ContextPackVersions`.
- **inbox items:** `InboxItems` table represents loose ideas. Can be converted and reference a `convertedPromptId`.
- **examples (runs):** `PromptExamples` table. Represents a compiled prompt execution. Belongs to a `Projects` record (via `projectId`) and a `Prompts` record (via `promptId`).
- **outputs:** `PromptExampleOutputs`. Belongs to a `PromptExamples` record (`1:N`). Tracks provider, model, and output content. Can have `LLMOutputAttachments` (`1:N` from outputs).
- **version history:** Separate snapshot tables (`PromptVersions`, `ContextPackVersions`) linked back to their parent IDs.
- **import/export entities:** Not standalone tables, but a codec mechanism that serializes the above tables into a JSON structure/archive.

## 6. Testing Overview

- **Existing test files:** Cover major DAOs, models, and parsing logic. Examples include `test/database_test.dart`, `test/prompt_compiler_service_test.dart`, `test/inbox_processing_test.dart`, `test/llm_model_catalog_test.dart`, and standard widget tests (`test/prompt_library_test.dart`, `test/import_export_screen_test.dart`).
- **Missing or weak tests:** UI tests for complex responsive layouts, visual regression tests for mobile layouts, and comprehensive integration tests covering the end-to-end flow from Inbox to Project Run.

## 7. Validation Commands

Codex must run these commands before and after implementation to ensure the codebase remains healthy:

```bash
export PATH=$PATH:$HOME/flutter/bin
git status --short
git branch --show-current
git remote -v
git log --oneline -5
git diff --stat
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build linux
flutter run -d linux
```
*(Note: Codex must ensure this Flutter SDK path is correct in the current environment.)*

## 8. GitHub Workflow Requirement

Every completed stage must be:
1. Validated locally.
2. Committed locally.
3. Pushed to the online GitHub repository.

Codex final reports must include:
* Current branch
* Remote URL
* Local commit hash
* Push command used
* Push result
* Final git status
* Whether GitHub is up to date

Codex must not claim success unless `git push` actually succeeds.

## 9. Known Limitations

- **Platform validation gaps:** Currently, only Linux Desktop is strictly validated visually. Mobile layouts are untested and may have rendering issues.
- **Mobile visual validation:** No automated visual testing for iOS/Android form factors.
- **Import/Export limitations:** The v0 JSON sync does not merge conflicts intelligently, relying on blind overwrites or duplicating data.
- **Backup limitations:** No cloud backup; relies entirely on local `.promptforge` zip export.
- **API integrations:** Real execution against LLM endpoints is mocked or rudimentary; the system is currently designed around "Bring Your Own Key" (BYOK) but relies heavily on manual output pasting.
- **Test coverage gaps:** Some newer UI features like TOC markdown readers and premium themes lack dedicated visual widget tests.

## 10. Recommended Next Stage

You considered building a **Rich Prompt Project Workspace + Multi-Format LLM Output Lab**.

**Recommendation:** *Do not build this from scratch.* 
Based on repository inspection, the architecture for this feature **already exists**. The `Projects`, `PromptExamples`, `PromptExampleOutputs`, `LLMProviders`, `LLMModels`, and `LLMOutputAttachments` tables, as well as their corresponding screens (e.g., `lib/features/projects/presentation/prompt_run_editor_screen.dart`, `lib/features/prompt_examples/presentation/example_comparison_screen.dart`) were implemented in recent stages (up to Stage 22.14). 

**Recommended Next Step:**
Instead of re-architecting the project workspace, the next stage should focus on **Actual Execution Integration and Mobile Polish**. 
1. Move the multi-LLM outputs from a *manual capture process* (Stage 22.11) to an *automated API execution engine* using the saved API keys and the BYOK structure audited in Stage 22.5.
2. Address the known cross-platform visual validation gaps by running and polishing the mobile (Android/iOS) UI constraints, specifically targeting the complex Example Comparison Screen and Rich Markdown editors.

## 11. Codex Implementation Prompt

```text
You are Codex, an expert Flutter developer. You are continuing development on PromptForge, a local-first prompt engineering workspace.

Before you write any code:
1. Read the `CODEX_HANDOFF_PROMPTFORGE.md` document in the root directory to understand the current architecture and database schema.
2. Inspect the repository using standard git commands (`git log`, `git status`) and explore `lib/features/` and `lib/core/database/` to see the actual implementation. 
3. DO NOT guess file names, class names, or database structures. The data model for Projects, PromptExamples (runs), and PromptExampleOutputs already exists. DO NOT duplicate these concepts. Reuse `PromptExampleDao`, `ProjectDao`, and `PromptExampleOutputDao`.
4. Your goal is to implement the next stage of development as discussed in the handoff document.

When you make changes, follow the existing Riverpod + Drift architecture. If you modify database tables in `lib/core/database/tables/tables.dart`, you MUST run the build runner.

Validation Commands:
Run these commands locally to ensure your code is clean and functional:
export PATH=$PATH:$HOME/flutter/bin
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test

When your work is complete and validated:
1. Commit your changes locally.
2. Push your branch to GitHub (`git push origin master`).

In your final report, you MUST provide:
- Current branch
- Remote URL
- Local commit hash
- The exact push command used
- The exact output/result of the push command
- Final `git status`
- Confirmation that GitHub is up to date

Do not claim success until `git push` has succeeded.
```
