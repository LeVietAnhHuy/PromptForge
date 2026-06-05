# Handoff Notes (from Codex, 2026-06-05)

## Done and working
- Repository is on `master`, remote `origin` is `https://github.com/LeVietAnhHuy/PromptForge.git`, and latest completed feature commit before this handoff is `1cca042 Stage 23: add LLM execution integration and mobile polish`.
- Prompt library CRUD, tags, collections, context packs, prompt variables, compiler, import/export, version history, inbox, project runs, and output comparison all exist in the codebase.
- Stage 23 added automated LLM execution through the existing `PromptExamples` / `PromptExampleOutputs` data model.
- `lib/features/execution/application/llm_execution_service.dart` centralizes execute-and-save behavior and avoids saving failed or empty API responses.
- Google/Gemini API execution is wired through `google_generative_ai` and saved API keys from `flutter_secure_storage`; mock execution remains available for tests.
- Manual output capture remains available through comparison and project-run UI paths.
- `PromptExampleOutputs.sourceType` is in schema version 6 and records `manual` or `api` provenance.
- Import/export includes output `sourceType` and still does not export API keys.
- Narrow-width layout fixes were made for Example Comparison, Prompt Run Editor, Prompt Compiler, Inbox Editor, Import/Export, API Keys, output dialogs, and the Prompt Body Focus Editor.
- `pubspec.lock` is present and committed.
- No `.env.example` was added because the app does not require environment variables; API keys are entered in Settings and stored in secure storage.

## In progress / half-finished
- No active in-progress implementation is intentionally left half-finished.
- Real API execution is only implemented for Google/Gemini. Other providers in the model catalog are available for metadata/manual capture, not direct API calls.
- Mobile layouts have widget coverage for narrow widths, but Android/iOS device or emulator validation was not completed in this handoff session because only Linux was available locally.

## Known bugs and dead ends
- No known failing tests at handoff.
- Import/export conflict handling remains basic (`skip`, `overwrite`, `duplicate`) and is not a full merge system.
- `.promptforge` bundles do not include attachment file bytes; imported attachment rows cannot restore original local files.
- API execution is synchronous full-response execution; streaming and token telemetry are not implemented.
- Do not re-create project/output models: `Projects`, `PromptExamples`, `PromptExampleOutputs`, `LLMProviders`, `LLMModels`, and `LLMOutputAttachments` already exist.
- Cleanup search found an existing `// TODO: Project Settings` in `lib/features/projects/presentation/project_detail_screen.dart` and an existing `debugPrint` in `lib/features/prompt_compiler/presentation/prompt_compiler_screen.dart`; neither was introduced by this handoff task.

## Next intended tasks (in priority order)
1. Add another real execution provider, likely OpenAI or Anthropic, behind `LlmExecutionProvider` and `LlmExecutionService`.
2. Add optional execution settings such as temperature/max tokens while keeping manual fallback and secure key handling.
3. Validate Android/iOS layouts on real devices or emulators, especially comparison cards, dialogs, and long markdown editors.
4. Improve import/export attachment handling if backup fidelity becomes a priority.
5. Consider richer evaluation support for prompt examples, such as assertions or structured scoring.

## Test status
- `flutter pub get`: passed. The first sandboxed attempt failed because Flutter tried to write SDK cache files outside the workspace; rerun with approved Flutter SDK-cache access passed.
- `dart run build_runner build --delete-conflicting-outputs`: passed. Current build_runner reports that `--delete-conflicting-outputs` is ignored, then completes successfully.
- `flutter analyze`: passed, no issues found.
- `flutter test`: passed, 110/110 tests.
- `flutter build linux`: passed and produced `build/linux/x64/release/bundle/promptforge`.
- `flutter run -d linux`: debug build launched on Linux; command returned exit code 0 after startup with `Lost connection to device`.
- Android/iOS validation: not run in this handoff session; no mobile validation command was executed.
