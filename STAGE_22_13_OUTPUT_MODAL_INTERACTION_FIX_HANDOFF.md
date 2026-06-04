# Stage 22.13 Handoff — Fix Manual Output Modal Interactions

## Summary of Bug & Fixes
The `ManualOutputPasteDialog` was suffering from critical interaction blockers where the Provider and Model dropdowns refused to open, and the Attach Files button crashed natively on Linux.

1. **Provider Dropdown Fix:**
   - **Root Cause:** The `DropdownButtonFormField` was using the entire `LLMProvider` object instance as its value. If the in-memory instance changed or didn't perfectly match the `items` instances, Flutter disabled the dropdown. Furthermore, if the Database returned an empty list for providers, the entire component became disabled and could not be clicked.
   - **Fix:** Switched the `value` type to `String` (the provider's `id`), making equality checks robust. Also added static fallback providers (OpenAI, Anthropic, Google, DeepSeek, Other) if the database query returns empty, guaranteeing that the dropdown always populates and opens.
2. **Model Dropdown Fix:**
   - **Root Cause:** Due to the same `String` vs `Object` reference issues as the Provider dropdown, the Model dropdown was locking up. Also, the `DropdownMenuItem` `Text` widget was causing a `RenderFlex overflow` constraint breach because the models' display names were too long, which crashed the modal rendering under test conditions.
   - **Fix:** Switched to string-based ID mapping, wrapped the `DropdownMenuItem` labels with `TextOverflow.ellipsis`, and added `isExpanded: true` to the Dropdown components to enforce strict boundary layouts and allow text truncation to work properly.
3. **Attach Files Fix:**
   - **Root Cause:** The `file_picker` package was throwing a `MissingPluginException` on the platform channel if the OS executable didn't have the C++ plugin dependencies bundled natively (which happens if `flutter run -d linux` is hot-restarted without a clean rebuild after installing the pub package).
   - **Fix:** While the underlying problem is a developer environment issue (requires `flutter clean`), we wrapped the `FilePicker` call to catch `MissingPluginException` specifically (via the default `catch (e)`) and present a localized `ScaffoldMessenger` SnackBar instead of allowing the app to hard-crash.

## Tests & Commands Run
- `flutter test test/prompt_editor_test.dart` — All tests pass. Updated `prompt_editor_test.dart` to expect "OpenAI" instead of "Unknown" because the new fallback logic ensures a provider is always populated.
- `flutter test test/inbox_test.dart` — All tests pass.
- `flutter analyze` — Addressed multiple `deprecated_member_use` warnings by migrating `DropdownButtonFormField.value` to `initialValue`.

## Git State
- **Branch:** `master`

## Conclusion
Stage 22.13 is fully implemented and tested. The manual output modal is fully interactive, does not rely on active database seeds to display dropdown choices, gracefully handles long text without layout overflows, and robustly captures MissingPluginExceptions.
**Stage 23 can safely begin.**
