# Stage 22.6: Rich Markdown Reader + Table of Contents

Date: 2026-06-03  
Project: PromptForge  
Current Phase: Stage 22.6 — Rich Markdown Reader + Table of Contents Navigation

---

## 1. Summary of Work
The Markdown preview in the Inbox editor has been upgraded from a plain view into a rich, navigable document reader. This significantly improves the experience of scanning and navigating long Markdown handoffs.

The new features include:
- A richer Markdown style sheet tailored for PromptForge's theme.
- A Table of Contents (TOC) automatically extracted from H1, H2, and H3 headings.
- A Desktop layout that shows the TOC sidebar on the right.
- A Mobile/Narrow layout that shows a FloatingActionButton to open the TOC in a BottomSheet.
- Seamless "Click-to-jump" navigation that instantly scrolls to the corresponding section using exact `GlobalKey` widget locations.

## 2. Visual Styling Upgrades
- **Headings**: H1, H2, H3 now use primary and secondary theme colors with bolder font weights.
- **Code Blocks**: Rounded corners, distinct `surfaceContainerHighest` backgrounds, and a subtle border. Monospace fonts are enforced.
- **Blockquotes**: Left-accented border with a muted background.
- **General Spacing**: Increased line height for paragraphs to improve readability.
- **Lists & HRs**: Subtle styling improvements that map to the underlying material theme.

## 3. Table of Contents & Navigation
- The `MarkdownBlockParser` now extracts `MarkdownTocItem` records, intelligently tracking `blockId` and level, and strips Markdown heading markers (e.g., `#`, `##`).
- Empty headings are ignored.
- Duplicate heading text correctly generates unique deterministic ID suffixes to prevent jump conflicts.
- Clicking a TOC item calls `Scrollable.ensureVisible` for pinpoint-accurate scrolling to the target heading block.
- The TOC is strictly navigational; clicking a TOC item *does not* accidentally enter inline edit mode.

## 4. Inline Editing Compatibility
- Clicking any content block in the main Markdown view still instantly opens the inline text editor.
- The TOC automatically rebuilds and refreshes the layout immediately after an inline edit is committed.
- Both the `Edit Full Text` mode and `Preview` mode tabs continue to work flawlessly.
- Conversion to Prompt Card remains unchanged.

## 5. Files Changed
- `lib/features/inbox/domain/markdown_block_parser.dart`: Added `MarkdownTocItem` and `extractToc` logic.
- `lib/features/inbox/presentation/inline_markdown_editor.dart`: Massive upgrade to implement `MarkdownStyleSheet`, Desktop/Mobile TOC layouts, `GlobalKey` management for headings, and `Scrollable.ensureVisible` jumping.
- `test/markdown_block_parser_test.dart`: Added unit tests for TOC extraction logic, including duplicate heading behavior and H1/H2/H3 filtering.
- `test/inbox_editor_screen_test.dart`: Added an integration test to simulate TOC layout switching, TOC clicking, and inline editing bypass rules.

## 6. Tests Added/Updated
- **Unit Tests**: `Extracts H1, H2, H3 headings`, `Ignores non-heading blocks`, `Handles duplicate headings with unique IDs`, `Handles empty headings`.
- **UI Tests**: `InboxEditorScreen shows TOC on desktop when multiple headings exist` verifies that the `Contents` sidebar renders, that TOC items can be tapped, and that doing so doesn't trigger inline editing hooks.

## 7. Validation & Build Results
- `flutter analyze`: Passed with 0 structural errors.
- `flutter test`: Passed (89/89 tests passing).
- `flutter build linux`: Built successfully.

## 8. Git Status
- **Branch**: `master`
- **Previous Commit Hash**: `c3926db`
- **New Commit Hash**: (Pending)
- **Push Result**: (Pending)

## 9. Known Limitations
- The TOC is only generated up to depth H4. H5 and H6 are intentionally excluded to reduce noise.
- Current scroll position does not dynamically highlight the active TOC item as you manually scroll down the page (this would require a very complex IntersectionObserver-like implementation).
- Horizontal scroll is not strictly enforced in TOC items; instead, long headings use `TextOverflow.ellipsis` with a 2-line maximum.

## 10. Can Stage 23 Begin?
**Yes.** Stage 22.6 is complete. The Markdown reader is now beautiful and usable for long documents. We are cleared to proceed to Stage 23 (Prompt Comparison Matrix).
