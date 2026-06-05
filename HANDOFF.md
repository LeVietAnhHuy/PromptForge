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

## Stage 23 — UI/UX overhaul (Claude Code)
Delivered the Stage 23 brief. The brief was written in web/CSS terms (CSS
variables, DOM, HTML5 players, pdf.js); this is a Flutter app, so every concept
was translated to Flutter idioms (ThemeData + tokens, `ThemeExtension`,
`flutter_svg`, `Shortcuts`/`OverlayPortal`, etc.). One commit per part, all
prefixed `stage23:`.

- Part F — Forge design system. `lib/app/theme/app_design.dart` holds the token
  set (4px spacing scale, radii, motion durations/easings, the forge color ramp,
  font families) plus a `ForgeTokens` theme extension; `theme.dart` builds a
  dark-first `ThemeData` whose `ColorScheme` fills the M3 surface slots existing
  screens already use, so the palette + typography apply app-wide. Self-hosted
  OFL fonts (Space Grotesk / Atkinson Hyperlegible / JetBrains Mono).
  `AppDesign.motion(context, ...)` respects `prefers-reduced-motion`.
- Part A — Edit Prompt two-column layout (≥1100 px: body editor + Contents
  outline | saved outputs, independent scroll; single column below). Added live
  char/token counts and a "Saved · / Unsaved changes" indicator. Save now stays
  in place (transitions a new prompt into edit mode) instead of popping.
- Part B — Provider identity registry (`lib/shared/providers/provider_identity.dart`)
  with bundled SVG logos or monogram fallback; output cards show logo + accent
  left border + tinted model badge, an "edited" indicator, and an Edit action
  (hover pencil + kebab) reusing the paste dialog in edit mode.
- Part C — `ModelPickerField`: grouped-by-family combobox with sticky headers,
  collapsed Legacy expanders, a pinned Recent group (persisted per provider in
  `UserSettings`), and type-to-filter with full keyboard nav.
- Part D — `AttachmentViewer`: modal preview with prev/next, image zoom, SVG,
  code/text/JSON/HTML highlighting, Markdown (raw toggle), CSV/TSV tables, ZIP
  listing; PDF/video/audio fall back to open-externally (see deviation below).
- Part E — Removed the Search tab; added a global Ctrl/Cmd+K command palette
  querying existing DAOs (prompts/tags/outputs) with Enter-to-navigate.

### Deviations from the brief (codebase wins per the rules)
- Web→Flutter translation throughout (no CSS/DOM/HTML).
- Provider logos: Simple Icons (CC0) where available; OpenAI/Cohere/Zhipu use an
  authored monogram badge and Microsoft an authored 4-square mark, because their
  marks aren't in the CC0 set. All licenses noted in `THIRD_PARTY_NOTICES.md`.
- PDF/video/audio are not rendered inline. Reliable Linux-desktop AV/PDF
  rendering needs native backends (libmpv/pdfium) that can't be verified in this
  environment and would add system dependencies; the viewer offers an
  "Open externally" action plus metadata instead. Revisit with `media_kit` /
  `pdfrx` if in-app playback becomes a priority.
- A few existing tests that asserted the old pop-on-save navigation were updated
  to the new in-place-save flow; data assertions are unchanged.

## Stage 24 (Claude Code) — complete

Translated the Stage 24 brief into the Flutter stack. One commit per part,
`stage24:` prefix. **Verification:** `flutter analyze` clean; `flutter test`
142/142 pass; `flutter build linux --release` succeeds (bundles `libpdfium.so`;
media_kit links system `libmpv.so.2` — see Part C note). Stage 25 not yet
started. All parts:

- Part B — real provider logos. Root cause: OpenAI/Cohere/Zhipu had no bundled
  SVG so the registry fell back to a monogram. Vendored real marks from the
  LobeHub icon set (MIT) into `assets/provider_icons/`; minimum set now all show
  real logos. Kept `assets/provider_icons/` (brief suggested `provider_logos/`)
  — deviation. Asset test verifies each bundled logo loads + parses.
- Part A — model picker. Root cause of the unusable scroll: every group header
  was `SliverPersistentHeader(pinned: true)`, so all headers pinned and stacked
  at the top. Rewrote with naturally-scrolling expandable group headers, 60%-of-
  window max height + always-visible scrollbar, family-first grouping with
  capability buckets collapsed at the bottom, capability filter chips, and
  keyboard expand/collapse. `capabilityOfFamily()` classifies models.
- Part E — "3 attached, 2 saved" bug. **Root cause:** `_copyDraftsInto` wrote
  every file to `attachments/<outputId>/<originalFileName>` with no uniqueness,
  so two attachments sharing a base name overwrote each other on disk, and a
  single failed/`path == null` copy mid-loop silently dropped the rest while the
  already-written rows persisted — the saved count could fall below the attached
  count with no error. **Fix:** extracted `AttachmentStorageService` that stores
  each file under a unique `<uuid>__<name>` destination, never silently skips,
  and returns saved/failed counts so the dialog warns instead of losing data.
  Regression tests cover create + edit flows and the same-name case.
  **Existing-data check:** the user's local DB isn't accessible from this
  environment, so no automated scan was run. The bug only ever *under*-saved
  (fewer rows than files) or overwrote a same-named file; it did not create rows
  pointing at deleted files except in the same-name-overwrite case (two rows →
  one file). Nothing was deleted as part of this fix; users who hit the bug
  should re-attach the missing files. No silent cleanup performed.

- Part D — preview attachments before saving. Added `ViewerSource` (persisted
  or pending) and made the viewer accept `List<ViewerSource>`. Every chip in the
  Paste/Edit dialog — existing or just-attached — now has the eye affordance and
  opens the full viewer immediately over the combined set. Pending drafts persist
  only on Save; Cancel copies nothing and never deletes the user's source files.
- Part C — inline PDF / video / audio. Added `pdfrx` (PDF) and
  `media_kit` + `media_kit_video` + `media_kit_libs_video` (A/V). New
  `lib/shared/attachments/media_renderers.dart` provides `PdfRenderer`
  (continuous scroll, page indicator + jump, zoom), `VideoRenderer` (media_kit
  default controls: play/pause/seek/volume/fullscreen) and `AudioRenderer`
  (compact transport). The viewer routes pdf/video/audio to these inline; "Open
  externally" stays as a secondary header action for every type; backend
  failures show an in-viewer `MediaErrorPanel` (never crash). `main.dart` calls
  `MediaKit.ensureInitialized()`.
  - **Native deps / packaging (deviation from Part C.2):** `flutter build linux
    --release` succeeds and **bundles `libpdfium.so`** (PDF is fully
    self-contained). However `media_kit_libs_video` on **Linux links the system
    `libmpv.so.2`** and does **not** bundle libmpv (confirmed via `ldd`). So
    audio/video have a runtime dependency on system libmpv (package `libmpv2` /
    `mpv`), which is present on this dev machine. To make A/V self-contained,
    packaging should copy `libmpv.so.2` into the release bundle's `lib/`
    (the exe rpath `$ORIGIN/lib` resolves it first), e.g.
    `cp /usr/lib/libmpv.so.2 build/linux/x64/release/bundle/lib/`. Not baked into
    the repo build because the source path varies per distro.
  - **Verification limit:** this environment is headless (no display), so actual
    rendering/playback of a PDF/mp4/mp3 could not be visually confirmed. What is
    verified: the release build compiles and links the backends, type-routing
    sends pdf/video/audio to the inline renderers, and the graceful-failure path
    exists. The native renderer widgets can't be pumped in `flutter test` (they
    need libmpv/pdfium init), so routing is covered by `detectAttachmentKind`
    unit tests; manual playback verification on a display is still recommended.

- Part F — visual polish (focused pass within the forge system). Added a
  navigation-rail brand mark (ember-gradient anvil-spark glyph + "Forge"
  wordmark, the signature touch). New shared widgets: `EmptyState`
  (`lib/shared/widgets/empty_state.dart`, ember radial-glow mark + title +
  message + optional action) applied to the Library, Inbox, Workspaces and
  Context-Packs empty screens (tested strings preserved); `AppFeedback`
  (`lib/shared/widgets/app_feedback.dart`) with a styled snackbar/toast helper,
  a uniform confirm dialog (secondary-left / primary-right, destructive style),
  and `SkeletonBox`/`SkeletonList` loaders. Wired the confirm dialog into the
  prompt/output delete flows. Cards/inputs/dialogs already share the Stage 23
  theme recipe; reduced-motion is honored via `AppDesign.motion`. NOTE: the
  brief's "Settings pinned to the rail bottom" was not done because the desktop
  nav test requires a `NavigationRail` with all five destinations in one list
  (index-mapped to the shell branches); true bottom-pinning needs a custom rail
  — deferred to avoid breaking that contract. Remaining polish (per-screen
  header audit, stagger-fade list entrances) is iterative.

## Test status
- `flutter pub get`: passed. The first sandboxed attempt failed because Flutter tried to write SDK cache files outside the workspace; rerun with approved Flutter SDK-cache access passed.
- `dart run build_runner build --delete-conflicting-outputs`: passed. Current build_runner reports that `--delete-conflicting-outputs` is ignored, then completes successfully.
- `flutter analyze`: passed, no issues found.
- `flutter test`: passed, 110/110 tests.
- `flutter build linux`: passed and produced `build/linux/x64/release/bundle/promptforge`.
- `flutter run -d linux`: debug build launched on Linux; command returned exit code 0 after startup with `Lost connection to device`.
- Android/iOS validation: not run in this handoff session; no mobile validation command was executed.
