# Stage 21.6: Synchronized Markdown Split Scroll

Date: 2026-06-02  
Project: PromptForge  
Current Phase: Stage 21.6 — Synchronized Markdown Split Scroll

---

## 1. Summary of Stage 21.6

I implemented synchronized scrolling between the raw Markdown editor and the rendered Markdown preview in the Inbox Split mode. As a user scrolls one side, the other side matches proportionally, making reading and editing long documents vastly smoother.

## 2. Implementation Work Completed

### Scroll Sync Strategy
- Created two `ScrollController`s (`_rawScrollController` and `_previewScrollController`).
- Attached one to the `TextField` and the other to the `Markdown` widget.
- Used a **proportional mapping** strategy rather than an explicit AST block mapping, ensuring stability without heavy dependency re-writes.
- Formula: `targetOffset = (sourceOffset / sourceMax) * targetMax`.

### Safe Execution Loop
- Utilized an `_isSyncingScroll` guard flag to prevent infinite ping-pong feedback loops between the two controllers.
- Applied `.clamp(0.0, targetMax)` to prevent `ScrollPosition` out-of-bounds exceptions which can happen if layout constraints adjust mid-scroll.
- Verified controllers properly deregister in `dispose()` to prevent memory leaks or calling hooks on unmounted trees.

## 3. Database & Import/Export Changes
- **None.** Purely a UI interaction patch.

## 4. Tests Added/Updated
- Fixed `test/inbox_screen_test.dart` which had temporarily broken due to the `SegmentedButton` introducing an internal checkmark icon causing `find.byIcon(Icons.check)` to ambiguously trigger. Re-mapped to `find.byTooltip('Save')`.

## 5. Environment & Commands Run

- `flutter analyze`: Passed cleanly.
- `flutter test`: Passed cleanly (56/56 passing tests).
- `flutter build linux`: Passed cleanly.

**Visual Status:** Confirmed logic mathematically routes proportional clamps safely. Headless runtime prevents visual scrolls, but test suites verified no RenderFlex or logic boundaries were broken.

## 6. Git Status

- **Branch**: `master`
- **Previous Commit**: `c101ef0`
- **New Commit Hash**: (Pending commit)
- **Push Result**: (Pending push)

## 7. Known Limitations
- The proportional mapping does not perfectly map a specific raw word to the rendered word (e.g. if one side has huge blocks of HTML images taking up space). But it keeps you strictly proportional to your document completion percentage, which fulfills the prompt guidelines safely.

## 8. Next Recommended Stage

Stage 22 was actually just finished prior to 21.5! The next logical step is Stage 23 (Comparison Matrix).
