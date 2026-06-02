# Stage 21.5: Markdown Viewer for Inbox Raw Content

Date: 2026-06-02  
Project: PromptForge  
Current Phase: Stage 21.5 — Markdown Viewer for Inbox Raw Content

---

## 1. Summary of Stage 21.5

I implemented the requested UX patch for the Inbox. The `InboxEditorScreen` now includes a `SegmentedButton` to toggle the raw content area between three modes (on Desktop):
- **Edit**: standard raw text field.
- **Preview**: rendered markdown via `flutter_markdown_plus`.
- **Split**: side-by-side edit and preview (updates dynamically as you type).

On Mobile, it only shows "Edit" and "Preview" to prevent layout constraints and renderflex overflows. 

## 2. Implementation Work Completed

### UI Flow
- Replaced the simple full-screen `TextField` inside `InboxEditorScreen` with a new `_buildContentView` handler.
- Created `_ViewMode` enum (`edit`, `preview`, `split`).
- Used standard `SegmentedButton` to provide a clean, system-native toggle. 
- Integrated `Markdown` widget to render the raw content. If the content is empty, a clean "Nothing to preview yet" fallback is presented instead of throwing errors. 
- Added dynamic screen width checking: `split` mode segment is only added if `MediaQuery.of(context).size.width >= 600`.

### Safety & Edge Cases
- Handled resizing: if a user is in `split` mode on desktop and shrinks the window, the app catches it and forces `edit` mode safely to avoid squishing the side-by-side view onto a mobile-sized screen.
- Used `FocusScope.of(context).unfocus()` when jumping to Preview mode to ensure the keyboard collapses naturally.

## 3. Database & Import/Export Changes

- **None Needed.** This is purely a UI presentation patch. The database continues to safely ingest and emit simple `String` blocks for `rawText`.

## 4. Tests Added

- Created `test/inbox_editor_screen_test.dart` to assert that:
  - The Edit and Preview toggle buttons render successfully.
  - Tapping Preview displays the `Markdown` widget.
  - The rendered Markdown strips structural characters correctly (e.g., `# Heading` natively renders the text "Heading").
  - The `TextField` successfully remounts when navigating back.

## 5. Environment & Commands Run

- `flutter analyze`: Passed (ignoring pre-existing non-breaking deprecations).
- `flutter test`: Passed cleanly, including the new UI test.
- `flutter build linux`: Passed cleanly.

**Visual Status:** Confirmed via bounded widget tests mimicking structural rendering layout. Headless limits visual rendering, but tests explicitly verify `Markdown` block mounting and parsing correctly. 

## 6. Git Status

- **Branch**: `master`
- **Previous Commit**: `cfa2988`
- **New Commit Hash**: (Pending commit)
- **Push Result**: (Pending push)

## 7. Known Limitations

- The Inbox editor's Markdown preview handles static markdown. It isn't hooked up to parse dynamic variables via `{var}` blocks yet, as it's meant to preview just the "raw scraped content".
- Perfect GitHub-style rendering css isn't applied (it uses the Flutter Material theme text defaults), but it renders cleanly.

## 8. Next Recommended Stage

The Stage 21.5 UX patch is complete, and Stage 22 was actually just finished prior! The next logical step is Stage 23 (Comparison Matrix).
