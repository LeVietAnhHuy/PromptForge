# Stage 21: Target Tool Profiles + Compiler v1

Date: 2026-06-02  
Project: PromptForge  
Current Phase: Stage 21 — Target Tool Profiles + Compiler v1

---

## 1. Context

Stage 21 builds upon the offline deterministic Prompt Compiler established in Stage 20. We have successfully enabled Target Tool Profiles, allowing Prompt Cards to adapt their textual formatting strictly via internal deterministic algorithms without requiring real AI APIs.

## 2. Implementation Work Completed

### Data Model Decision
An **in-memory target schema (`TargetToolProfile`)** was selected over utilizing the database `LLMProviders` table. 
- Reason: Target Tool Profiles (like `Flow Image`, `NotebookLM`, `Cursor`) are distinct structural formatting rules, not strict network providers needing DB persistence. An in-memory mapping provides the exact required compilation determinism while keeping the database perfectly intact and migration-free.

### Domain Layer
* Created `TargetToolProfile` base class and 10 built-in implementations:
  1. `GenericProfile` (Defaults to standard v0 logic).
  2. `ChatGPTProfile` (Uses `# Context` / `# Task`).
  3. `ClaudeProfile` (Uses XML `<context>` / `<task>`).
  4. `GeminiProfile` (Uses `## Background Context` / `## Primary Request`).
  5. `CodexProfile` (Injects implementation rules).
  6. `CursorProfile` (Injects IDE contextual rules).
  7. `NotebookLMProfile` (Injects source-grounded reminders).
  8. `FlowImageProfile` (Concise visual outputs avoiding markdown fluff).
  9. `FlowVideoProfile` (Concise video layout structure).
  10. `LocalModelProfile` (Simple unnested structure).
* `PromptCompilerService` was refactored to parse variables internally, build the `CompilerContext`, and execute the `format()` strategy dictated by the selected profile.

### Presentation Layer
* `PromptCompilerScreen` includes a newly rendered dropdown specifically for `Target Tool Profile` above the Variables list. 
* Integrated a lightweight smart-detection heuristic: if `targetNotes` includes trigger words (like `image`, `video`, `claude`, `gpt`), the compiler immediately defaults to the corresponding profile rather than `Generic`.
* Visual updates trigger dynamically upon dropdown change.

### Tests
* Wrote 7 new domain logic assertions in `prompt_compiler_service_test.dart` to strictly validate wrapper text injections per profile.
* All 25 domain and UI tests fully passed.

## 3. Environment

- `flutter analyze`: Passed (only existing deprecation issues)
- `flutter test`: Passed (all tests successful)
- `flutter build linux`: Passed
- **Platform Inspection**: Due to the headless execution environment, visual tests are asserted exclusively via flutter widget testing (`pumpAndSettle`).

## 4. Next Steps

PromptForge now acts as a multi-tool prompt operating system. A highly recommended next stage would be integrating runtime generation where users can actually execute prompt runs directly through the app utilizing the generated strings against physical remote endpoints.
