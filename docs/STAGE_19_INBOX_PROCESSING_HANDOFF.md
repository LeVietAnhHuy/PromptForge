# Stage 19: Inbox Processing + Safe Capture-to-Prompt Workflow

## 1. Summary of Stage 19
This stage implemented a deterministic and robust processing workflow for the Inbox. Users can now convert raw captured ideas directly into reusable `Prompt Cards` in the Library or `Prompt Runs` in their Workspace. The workflow securely retains raw captures without risky migrations while opening up the capture-to-execution pipeline.

## 2. Inbox Processing Behavior
*   The `InboxScreen` now allows users to swipe left to quickly `Archive` an item.
*   Trailing menu actions provide two primary workflows: **Convert to Prompt Card** and **Convert to Workspace Run**.
*   Converting an item invokes a dialog to verify the extracted details, maintaining the principle that raw captures are merely staging areas for structured assets.

## 3. Conversion Flow Behavior
**To Prompt Card (`InboxToPromptCardDialog`)**:
*   *Title*: Inferred first from explicit `# Heading` markdown, failing back to the first non-empty truncated text line.
*   *Body*: Extracted straight from the raw capture text.
*   *Target Notes*: Auto-populated with the date of capture and original capture source (if it exists).
*   *Database*: The system natively marks the `InboxItems.status` as `'converted'` and saves the new `Prompt.id` into `convertedPromptId`.
*   *Versioning*: Instantiates an initial `PromptVersion` snapshot to guarantee immediate traceability.

**To Workspace Run (`InboxToWorkspaceRunDialog`)**:
*   *Project*: Selectable via a dropdown menu fetching active projects.
*   *Run Title*: Same inference rule as above.
*   *Input Body*: Pre-seeded with the raw text.
*   *Database*: The system natively creates the `PromptExamples` run inside the target `projectId` and then updates the original Inbox item `status` to `'converted'`. *Note*: We intentionally avoided schema modifications to append `converted_run_id` on the `InboxItems` table in order to adhere strictly to low-risk development patterns; the item is simply marked converted.

## 4. Files Changed
*   `lib/features/inbox/domain/inbox_processing_service.dart` (New: business logic for extraction)
*   `lib/features/inbox/presentation/inbox_to_prompt_card_dialog.dart` (New: responsive conversion UI)
*   `lib/features/inbox/presentation/inbox_to_workspace_run_dialog.dart` (New: responsive project run UI)
*   `lib/features/inbox/presentation/inbox_screen.dart` (Modified: Added list-tile actions & swipe dismissal)
*   `lib/core/database/daos/daos.dart` (Modified: Added safe `markInboxItemConvertedToRun` and `getActiveProjects` queries)

## 5. Database Changes
**None**. Schema versioning remains strictly untouched to preserve stable drift configurations. `InboxItems` leverages its pre-existing status flags (`open`, `converted`, `archived`) seamlessly.

## 6. Import / Export Changes
*   `lib/features/import_export/domain/import_export_codec.dart`
*   `lib/features/import_export/application/import_export_service.dart`
*   **Result**: The backup subsystem has been explicitly extended to securely serialize, compress, and hydrate `InboxItems` across Zip bundles. Legacy backups smoothly parse without inbox collections (defaulting to empty arrays), while new backups retain capture workflows accurately. Tests have been successfully modernized.

## 7. Tests Added/Updated
*   Added `test/inbox_processing_test.dart` to strictly validate heading derivation, prompt card schema mutations, workspace run instantiations, and DAO verification states.
*   Modified `test/import_export_test.dart` to assert structural validity for the newly integrated inbox data.

## 8. Commands Run and Results
*   `flutter pub add intl`: Passed.
*   `flutter pub get`: Passed.
*   `dart run build_runner build`: Passed cleanly.
*   `flutter analyze`: Passed (0 errors, 6 pre-existing UI deprecation warnings ignored).
*   `flutter test`: Passed (54 tests passing flawlessly).

## 9. Platform Builds / Launches
*   **Linux**: Fully compiled. Binary generated natively at `build/linux/x64/release/bundle/promptforge`.
*   **Windows / Android / iOS**: Not physically launched; Target OS environments remain unavailable inside the headless execution pipeline.

## 10. Screenshots or Visual Notes
Due to the headless VM constraints, screenshots cannot be appended. However, architectural bindings reflect:
*   The Inbox utilizes a `Dismissible` with a red `Icons.archive` swipe-background for physical feedback.
*   The `InboxToPromptCardDialog` and `InboxToWorkspaceRunDialog` dynamically query screen-width constraint (`> 600px`). They deploy locked `< 500px` `AlertDialogs` on desktop scaling, and fullscreen `showGeneralDialog` scaffolds on mobile variants to completely eliminate `RenderFlex` keyboard overflows.

## 11. Git Branch
`master`

## 12. Commit Hash
*(Pending final commit)*

## 13. Push Result
*(Pending final push)*

## 14. Known Limitations
*   No strict schema-linked `convertedRunId` field exists inside `InboxItems`. Though marked as converted, the direct backwards traceability pointer for Runs is not yet hardcoded.
*   Real AI autocompletion or scoring is still mock-driven.

## 15. Readiness for User Visual Evaluation
The application core is completely **ready** for user visual assessment on designated hardware.

## 16. Recommended Next Stage
**Stage 20: Cross-Device Context Pack Injector / Rich LLM Variables**. With the core creation and experimentation loops finalized, refining Context Pack embeddings and dynamic `$variables` into the Workspace Compiler will vastly improve real-world engineering speed.
