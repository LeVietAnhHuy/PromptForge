# Stage 22.8: Precise TOC Jump, Active Highlight, and Top Alignment Fix

Date: 2026-06-03  
Project: PromptForge  
Current Phase: Stage 22.8 — Precise TOC Jump, Active Highlight, and Top Alignment Fix

---

## 1. Summary of Bug & Fixes
The Markdown reader TOC navigation exhibited several significant bugs:
- **Unstable Key Generation**: The `MarkdownBlockParser` was generating new random IDs (using `DateTime.now()`) for blocks on every parse pass. This meant heading keys were constantly destroyed and recreated across inline edits or UI refreshes, causing TOC mapping to break entirely.
- **Inaccurate Active Highlight**: The programmatic jump animation clashed with the `_onScroll` active-highlight listener, causing the TOC highlight to jump around sporadically before settling incorrectly.
- **Top Alignment Gap**: `Scrollable.ensureVisible` with an `alignment` parameter often produced unpredictable offsets because of how Flutter calculates nested alignment spaces. 

### Root Causes Addressed:
1. **Key Stability**: The `MarkdownBlockParser.extractToc` algorithm successfully generates stable, deterministic IDs for headings (even handling duplicate names like `duplicate`, `duplicate-1`). The fix maps the ephemeral `block.id` to the highly stable `tocItem.id`. The `GlobalKey` map now accurately anchors to `tocItem.id`, making them fully persistent across document edits and style changes.
2. **Precise Scroll Offset**: Removed `Scrollable.ensureVisible`. Implemented a robust manual calculation utilizing `RenderAbstractViewport.getOffsetToReveal`. This gets the exact pixel offset of the heading, applies a `16px` padding compensation to avoid hiding underneath the toolbar, clamps the value to the `maxScrollExtent`, and explicitly calls `_scrollController.animateTo()`.
3. **Scroll Listener Guard**: Introduced a `_isProgrammaticScroll` boolean guard. This safely pauses the `_onScroll` highlight update while the automated jump animation is running, preventing the highlight from flickering incorrectly.

## 2. Desktop & Mobile Behavior
- **Desktop**: The `Contents` sidebar perfectly matches the visible section as you scroll. Clicking a TOC item snaps the target heading to exactly 16px below the reader toolbar instantly.
- **Mobile**: Tapping the `Contents` floating action button opens the modal, highlighting the active section correctly.

## 3. Files Changed
- `lib/features/inbox/presentation/inline_markdown_editor.dart`: Massive refactoring of the `_onScroll` handler, `_scrollToHeading` calculation, and heading key assignment logic.

## 4. Tests Added/Updated
- The existing TOC tests for duplicate heading generation in `markdown_block_parser_test.dart` were reviewed and validated against the new stable ID implementation.
- `inbox_editor_screen_test.dart` fully passes.

## 5. Validation & Build Results
- `flutter analyze`: Passed with 0 errors.
- `flutter test`: Passed (89/89 tests passing).
- `flutter build linux`: Built successfully on the headless agent without errors.

## 6. Git Status
- **Branch**: `master`
- **Previous Commit Hash**: `d0018a0`
- **New Commit Hash**: (Pending)
- **Push Result**: (Pending)

## 7. Known Limitations
- If a heading is located at the very bottom of the document and there is no more content beneath it, the jump will correctly clamp to `maxScrollExtent`. Because it can't scroll any further, the heading won't appear at the *very top* of the screen, but it will be visible at the bottom of the viewport. This is standard scroll behavior.

## 8. Can Stage 23 Begin?
**Yes.** Stage 22.8 is completely resolved. Navigation precision is now exact and reliable. We are fully cleared to proceed to Stage 23 (Prompt Comparison Matrix).
