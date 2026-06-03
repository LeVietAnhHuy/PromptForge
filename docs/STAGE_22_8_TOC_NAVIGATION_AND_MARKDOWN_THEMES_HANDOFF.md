# Stage 22.8: Fix TOC Navigation Precision + Premium Markdown Theme System

Date: 2026-06-04  
Project: PromptForge  
Current Phase: Stage 22.8 — Fix TOC Navigation + Markdown Themes

---

## 1. Summary

Fixed TOC navigation so clicking any heading jumps to the exact section on the first click, with the heading aligned near the top of the content viewport. Also enhanced all five Markdown reader themes with richer typography inspired by open-source documentation styles.

## 2. Root Cause

**The block parser was generating random IDs using `DateTime.now().microsecondsSinceEpoch`**. This meant every call to `parse()` produced entirely new block IDs. The `_blockIdToTocId` mapping was rebuilt, but the widgets were built with the *previous* parse's block IDs, so the `GlobalKey` lookup path broke on every reparse. This caused:

- TOC clicks to jump to wrong sections (stale key references)
- Active highlight to show wrong items (mismatched IDs)
- Multiple clicks sometimes landing closer because repeated parses eventually created a fresh mapping that partially aligned

## 3. Root Cause Fix: Deterministic Block IDs

Changed `_createBlock()` from:
```dart
id: DateTime.now().microsecondsSinceEpoch.toString() + '_$start'
```
To:
```dart
id: 'block_${start}_${type.name}'
```

This makes block IDs deterministic and stable across reparses. A heading at line 42 always has ID `block_42_heading`, so the `blockId → tocId → GlobalKey` chain is always consistent.

## 4. Jump/Scroll Implementation

Uses `RenderAbstractViewport.getOffsetToReveal(renderObject, 0.0)` to calculate the exact pixel offset needed to place the heading at the top of the viewport. A small 8px compensation is subtracted, and the result is clamped to `[0, maxScrollExtent]`. The scroll controller uses `animateTo()` with a 220ms `easeOutCubic` curve.

## 5. Active Highlight Behavior

- On TOC click: immediately sets `_activeTocId` and `_isProgrammaticScroll = true`
- During programmatic scroll: `_onScroll` is suppressed by the guard flag
- After animation completes: guard is released
- On manual scroll: `_computeActiveHeading()` walks TOC items and finds the last heading whose screen-relative top is ≤ 180px

## 6. Premium Markdown Themes

All five themes were enhanced with richer typography:

| Theme | Inspiration | Key Characteristics |
|-------|------------|---------------------|
| PromptForge | Tailwind Typography prose | Calm dark, cyan/blue accents, clean block rhythm, subtle heading hierarchy |
| GitHub | sindresorhus/github-markdown-css | Familiar dev docs feel, crisp borders, `#F6F8FA` code blocks, blue links |
| Docs | VitePress / mdBook | Large H1, green accent H2, generous spacing, docs-focused hierarchy |
| Paper | Tufte CSS / LaTeX.css | Serif fonts, italic H2, academic calm, minimal borders |
| Terminal | Terminal.css | Full monospace, green/cyan accents, zero-radius code blocks, dark |

Each theme now defines: h1/h2/h3 with padding, paragraph with line height, code/codeblock, blockquote, horizontal rule, list bullets, and link styling.

## 7. Files Changed

- `lib/features/inbox/domain/markdown_block_parser.dart` — Deterministic block IDs
- `lib/features/inbox/domain/markdown_reader_style.dart` — Enhanced all 5 themes
- `lib/features/inbox/presentation/inline_markdown_editor.dart` — Fixed key mapping, scroll, active highlight
- `lib/features/inbox/presentation/inbox_editor_screen.dart` — Removed unused import
- `test/markdown_block_parser_test.dart` — Added 4 deterministic ID tests
- `docs/STAGE_22_8_TOC_NAVIGATION_AND_MARKDOWN_THEMES_HANDOFF.md` — This file

## 8. Tests Added

- `Block IDs are stable across repeated parses` — Parses same text twice, asserts all IDs match
- `Block IDs use line number and type` — Asserts `block_0_heading`, `block_1_paragraph` format
- `TOC blockId matches heading block ID` — Every TOC item's blockId exists in the heading blocks set
- `TOC blockId is stable across reparses` — Both TOC id and blockId are identical across two parses

## 9. Validation Results

- `flutter analyze`: 0 errors (only pre-existing infos about deprecated RadioButton API)
- `flutter test`: 93/93 tests passing
- `flutter build linux`: ✓ Built successfully

## 10. Git Status

- **Branch**: `master`
- **Previous Commit Hash**: `8255509`
- **New Commit Hash**: (pending)
- **Push Result**: (pending)

## 11. Known Limitations

- Reader style choice is session-local (not persisted to disk)
- Syntax highlighting inside code blocks is not implemented (Flutter Markdown Plus limitation)
- If a heading is at the absolute bottom of a document with insufficient trailing content, it will be visible but may not reach the very top of the viewport (standard scroll clamping)

## 12. Can Stage 23 Begin?

**Yes.** TOC navigation is now precise and reliable. Themes are rich and differentiated. Stage 23 (Prompt Comparison Matrix) can safely begin.
