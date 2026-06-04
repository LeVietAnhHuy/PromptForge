# Stage 22.12 Handoff — Provider/Model Catalog + Multi-format Output Attachments

## Goal Description
Upgraded the Manual Output Capture system from a simple free-text paste dialog into a structured, catalog-driven, multi-format intake mechanism. Users can now attribute outputs strictly to company Providers and their corresponding Models, define output types accurately (Markdown, JSON, Code, Images, PDFs), and securely attach relevant files.

## Summary of Changes
1. **Model Catalog Service (`llm_model_catalog.dart`)**: 
   - Introduced a hardcoded catalog linking Providers (OpenAI, Anthropic, Google) to their known models sorted chronologically (e.g., GPT-3.5 Turbo -> GPT-4o, Claude 2 -> Claude 3.5 Sonnet).
2. **Schema & DB Updates**:
   - Incremented `schemaVersion` to 5.
   - Added `sizeBytes` and `attachmentType` to `LLMOutputAttachments`.
   - Updated Database logic to migrate existing legacy provider records from product names ("ChatGPT", "Claude") to strict company semantic ("OpenAI", "Anthropic").
3. **Multi-format Manual Paste Dialog (`manual_output_paste_dialog.dart`)**:
   - Converted Provider to a strict dropdown filtering the secondary Model dropdown.
   - Added `file_picker` dependency to allow multi-file selection natively.
   - Outputs can now have distinct semantic types (JSON, Code, Image, Video, PDF) driving conditional UI in the resulting `PromptOutputCard`.
4. **Output Rendering (`prompt_output_card.dart`)**:
   - Displays file attachments as cards/chips appended to the output block.
   - Conditionally wraps code and json responses in markdown blocks for cleaner rendering.
   - Retrieves locally stored attachment files mapped natively to the SQLite output record.
5. **Import/Export Data Integrity**:
   - `import_export_codec.dart` and `import_export_service.dart` upgraded to persist and correctly reload JSON metadata for `attachments` natively mapping to imported examples, allowing seamless transitions without data loss (Note: currently degrades cleanly to metadata-only for safety).

## Review Notes
The application requires a full restart (`flutter clean` / restart debug session) to properly trigger `schemaVersion 5` drift migrations, guaranteeing no structural loss from previous sessions while accommodating the file handling expansion.

All widget test suites updated and verified to pass under the strict catalog environment.
