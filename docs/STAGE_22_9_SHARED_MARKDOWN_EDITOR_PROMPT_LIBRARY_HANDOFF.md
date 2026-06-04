# Stage 22.9 — Shared Rich Markdown Editor for Prompt Library Body

Date: 2026-06-04
Project: PromptForge
Current Phase: Stage 22.9 — Shared Markdown Editor

---

## 1. Summary

Brought the same rich Markdown preview/editing experience from Inbox into the Prompt Library editor. Prompt Body now supports Preview/Edit toggle, inline block editing, TOC navigation, active TOC highlight, reader style selector, and full raw edit mode. Variable syntax `{var}` is preserved. All existing save, compile/run/copy, PromptVersion, and Inbox workflows remain unchanged.

## 2. Shared Component Architecture

Markdown editor components were extracted from `features/inbox/` to a shared location:

```
lib/shared/markdown/
├── inline_markdown_editor.dart   (InlineMarkdownEditor widget)
├── markdown_block_parser.dart    (MarkdownBlockParser + MarkdownBlock + MarkdownTocItem)
└── markdown_reader_style.dart    (MarkdownReaderStyle enum with 5 themes)
```

The original files under `features/inbox/` now contain re-export stubs:

```
lib/features/inbox/domain/markdown_block_parser.dart   → export shared
lib/features/inbox/domain/markdown_reader_style.dart   → export shared
lib/features/inbox/presentation/inline_markdown_editor.dart → export shared
```

This ensures all existing imports from Inbox continue to work without modification while both Inbox and Prompt Library share the same implementation.

## 3. How Inbox and Prompt Library Reuse Markdown Editor Logic

- **Inbox** (`inbox_editor_screen.dart`) imports via the re-export stubs. Zero code changes needed in Inbox.
- **Prompt Library** (`prompt_editor_screen.dart`) imports directly from `shared/markdown/`.
- Both screens instantiate `InlineMarkdownEditor` identically with the same props: `controller` and `readerStyle`.
- No duplicated logic. Single source of truth.

## 4. Prompt Library Behavior

### New Prompt (promptId == null)
- Defaults to **Edit** mode (raw text field visible)
- Body shows monospace `TextFormField` with hint "Enter prompt body (Markdown supported)..."
- User types raw Markdown
- Switch to **Preview** to see rendered Markdown with inline editing

### Existing Prompt (promptId != null)
- Defaults to **Preview** mode (rendered Markdown visible)
- User reads prompt body as rich Markdown
- Can click sections to edit inline
- Switch to **Edit** for full raw text editing

### Layout
- `SizedBox(height: 500)` constrains the body editor
- Preview mode shows info bar + style selector + InlineMarkdownEditor
- Edit mode shows TextFormField with `expands: true`

## 5. Variable Syntax Handling

- Raw Edit mode preserves `{variable}` and `{{variable}}` text exactly
- Inline editing preserves variable syntax exactly (edits raw text)
- Markdown preview displays variables as normal text (no replacement)
- `_onBodyChanged` listener continues to extract variables and show Variable Metadata forms
- Compiler receives the exact raw body text via `_bodyController.text`

**Future work:** Style `{variable_name}` tokens in preview as subtle inline chips/badges.

## 6. TOC Behavior

- TOC appears for long Prompt Body documents with ≥2 headings
- Desktop (≥800px): TOC sidebar on the right
- Mobile (<800px): FAB with Contents bottom sheet
- TOC click jumps to exact heading (via `getOffsetToReveal`)
- Active TOC highlight tracks scroll position
- Duplicate headings work (unique IDs)
- Editing a heading updates TOC
- Clicking TOC does not trigger inline edit mode

## 7. Reader Style Behavior

5 reader styles available via dropdown:

| Style | Description |
|-------|-------------|
| PromptForge | Default theme with primary/secondary heading colors |
| GitHub | Developer docs feel |
| Docs | VitePress-inspired with green accents |
| Paper | Academic serif typography |
| Terminal | Monospace green/cyan |

**Limitation:** Style choice is session-local (not persisted).

## 8. Desktop Layout

```
Title [text field]
Purpose / Description [text field]
Tags [text field]
Prompt Body [label]  [Preview | Edit toggle]
┌─────────────────────────────────────────┐
│ [info bar + style selector]             │
│ [Markdown content] [TOC sidebar]        │
│                                         │
│             500px tall                  │
└─────────────────────────────────────────┘
Variable Metadata (if variables detected)
```

## 9. Mobile Layout

- No permanent TOC sidebar
- FAB "Contents" button opens bottom sheet with TOC
- Preview/Edit controls fit in a Row
- Style selector is compact dropdown
- Body container is 500px tall (scrollable inside ListView)

## 10. Preserved Workflows

Verified no breakage:
- Creating a prompt manually ✓
- Editing an existing prompt ✓
- Saving prompt changes ✓
- Compile/Run action (`/library/compile/:id`) ✓
- Copy/Duplicate action ✓
- Delete action ✓
- Version History action ✓
- Examples & Comparisons action ✓
- PromptVersion snapshots ✓
- Variable detection in compiler ✓
- Import/export ✓
- Inbox Markdown editor ✓
- Prompt Cards from Inbox ✓

## 11. Files Changed

### New files
- `lib/shared/markdown/inline_markdown_editor.dart` — shared widget (moved from inbox)
- `lib/shared/markdown/markdown_block_parser.dart` — shared parser (moved from inbox)
- `lib/shared/markdown/markdown_reader_style.dart` — shared styles (moved from inbox)

### Modified files
- `lib/features/inbox/domain/markdown_block_parser.dart` — re-export stub
- `lib/features/inbox/domain/markdown_reader_style.dart` — re-export stub
- `lib/features/inbox/presentation/inline_markdown_editor.dart` — re-export stub
- `lib/features/prompt_library/presentation/prompt_editor_screen.dart` — integrated rich Markdown editor
- `test/prompt_library_test.dart` — updated body field finder
- `test/prompt_editor_test.dart` — updated body field finder + new Preview/Edit test

### Handoff
- `docs/STAGE_22_9_SHARED_MARKDOWN_EDITOR_PROMPT_LIBRARY_HANDOFF.md` — this file

## 12. Tests Added/Updated

### New test
- `Prompt body supports Preview/Edit toggle with rich markdown` — verifies Edit→Preview→Edit round-trip, InlineMarkdownEditor presence, style selector presence, and text preservation

### Updated tests
- `Creating a prompt flow works` — updated body field finder to match new hint text
- `Prompt editor save with tags + variables works` — updated body field finder and scroll behavior

## 13. Commands Run and Results

| Command | Result |
|---------|--------|
| `flutter analyze` | 0 errors, 0 warnings (24 infos — all pre-existing) |
| `flutter test` | **94/94 passing** |
| `flutter build linux` | ✓ Built successfully |

## 14. Git Status

- **Branch**: `master`
- **HEAD before work**: `7d03842`
- **HEAD after work**: (pending commit)
- **Push result**: (pending)

## 15. Known Limitations

1. Reader style choice is session-local (not persisted to disk)
2. No syntax highlighting inside code blocks (Flutter Markdown Plus limitation)
3. Variable tokens `{var}` are not styled as inline chips in preview (documented as future work)
4. Body container has fixed height (500px) — cannot be resized by the user
5. The `TextFormField` validator for body only runs in Edit mode; a manual empty check was added to `_savePrompt()` to cover Preview mode

## 16. Can Stage 23 Begin?

**Yes.** The Prompt Library body editor is now consistent with the Inbox Markdown editor. All tests pass. Stage 23 (Prompt Comparison Matrix) can safely begin.
