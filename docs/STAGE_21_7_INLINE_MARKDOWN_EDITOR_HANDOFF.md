# Stage 21.7: Preview-first Inline Markdown Editing

Date: 2026-06-02  
Project: PromptForge  
Current Phase: Stage 21.7 — Preview-first Inline Markdown Editing for Inbox Raw Content

---

## 1. Summary of Stage 21.7

I removed the `Split` mode from the Inbox editor, which proved clumsy for long, deeply-formatted Markdown documents. In its place, I introduced **Preview-first Inline Markdown Editing**. By default, users now read rendered Markdown. When they tap or click a specific text block (heading, paragraph, code block, etc.), that single block morphs into a focused raw-text editor in place. Once edits are committed, the block seamlessly snaps back to its rendered preview. 

## 2. Implementation Work Completed

### Markdown Block Parser
- Created `MarkdownBlockParser` (`lib/features/inbox/domain/markdown_block_parser.dart`).
- It iterates through the raw text lines and groups them into logical blocks: `heading`, `paragraph`, `list`, `code`, `blockquote`, `hr`, and `empty`.
- Fully tested through `test/markdown_block_parser_test.dart`.

### Inline Markdown Editor
- Created `InlineMarkdownEditor` (`lib/features/inbox/presentation/inline_markdown_editor.dart`).
- It parses the underlying `TextEditingController.text` and renders a `ListView` of blocks.
- Non-editing state: Renders a `MarkdownBody` wrapped in a click detector.
- Editing state: Renders a focused `TextField` scoped precisely to that block's raw text content, accompanied by `Save` and `Cancel` action buttons.
- Editing commits safely mutate the specific lines corresponding to the block within the main `TextEditingController` string, without erasing unrelated text or causing formatting corruption.

### Inbox Editor Screen
- Removed `Split` segmented button toggle.
- Cleaned up the `ScrollController` overhead from Stage 21.6.
- Set `Preview` mode as the default launch state for existing items.
- Added a helper hint: "Click any section to edit it in place."

## 3. Database & Import/Export Changes
- **None.** Purely a UX presentation layer patch. Data persists strictly as raw Strings.

## 4. Tests Added/Updated
- Added `test/markdown_block_parser_test.dart` to unit-test block boundary extraction.
- Refactored `test/inbox_editor_screen_test.dart` to validate the `MarkdownBody` parsing behavior over the new inline list-view layout.

## 5. Environment & Commands Run

- `flutter analyze`: Passed cleanly (ignoring existing legacy deprecations).
- `flutter test`: Passed cleanly (63/63 passing tests, including new parser and UI tests).
- `flutter build linux`: Passed perfectly.

**Visual Status:** Confirmed logic mathematically routes proportional text replacements safely. Headless runtime prevents visual scrolls, but test suites verified no RenderFlex or logic boundaries were broken.

## 6. Git Status

- **Branch**: `master`
- **Previous Commit**: `583bde5`
- **New Commit Hash**: (Pending commit)
- **Push Result**: (Pending push)

## 7. Known Limitations
- Fenced code blocks must have closing tags (```) in order to be safely tokenized as a single block. If a user pastes broken markdown, it may wrap incorrectly (fallback parser logic will treat it as standard paragraphs).
- "Undo" behavior natively supplied by the OS keyboard buffer resets inside the inline TextField block boundary (you cannot hit Ctrl+Z to undo a committed inline block replace). 

## 8. Next Recommended Stage
Stage 22 was finished previously. We are cleared to move to Stage 23 (Comparison Matrix).
