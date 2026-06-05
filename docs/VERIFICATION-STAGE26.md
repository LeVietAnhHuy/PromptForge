# Stage 26 — Owner Hands-On Verification Checklist

CI proves PromptForge **builds, analyzes, and passes tests** on Linux, Windows,
and macOS. It cannot prove the app actually *runs and renders* correctly on real
Windows/macOS hardware (GUI, native media, OS keychain, file dialogs). This is
the final acceptance gate — run it on a real machine per platform and check each
box. Until it's done, Windows/macOS support is "CI-green, owner-verification
pending."

How to get a build:
- Download the artifacts from the **draft Release** produced by a `v*` tag (see
  [`RELEASING.md`](RELEASING.md)), **or**
- Build locally: `flutter run -d windows` / `flutter run -d macos` (or the
  `--release` build).

Unsigned-artifact note:
- **Windows MSIX** is unsigned → Windows blocks install until you trust a
  certificate. For a quick test, run the portable `.zip`'s `promptforge.exe`
  directly, or sign per RELEASING.md.
- **macOS** `.app`/`.dmg` is unsigned → Gatekeeper blocks it. Right-click → Open,
  or `xattr -dr com.apple.quarantine PromptForge.app`, then launch.

---

## Run on each platform: ☐ Windows  ☐ macOS

### 1. Launch & window
- [ ] App launches without a crash or error dialog.
- [ ] Title bar / dock shows **PromptForge** with the ember flame icon.
- [ ] Resize the window down — it stops at a sensible **minimum (~800×600)** and
      the layout switches to the narrow (bottom-nav) form without overflow.
- [ ] Maximize — content reflows to the wide (nav-rail + columns) form.

### 2. Data directory (correct per-OS location)
- [ ] Create a prompt, then confirm the database file exists at the OS-correct
      app-data path:
  - Windows: `%APPDATA%\io.github.levietanhhuy.promptforge\` (or the app
    documents dir) contains `promptforge_db.sqlite`.
  - macOS: `~/Library/Containers/io.github.levietanhhuy.promptforge/Data/` (app
    is sandboxed) → `…/Documents/promptforge_db.sqlite`.
- [ ] No files are written to unexpected locations (e.g. the app folder).

### 3. BYOK key save/load (secure storage)
- [ ] Settings → API Keys: paste a Google Gemini key, Save → "Saved API key…".
- [ ] Fully quit and relaunch → the key is still present (read back from the OS
      store: **DPAPI** on Windows, **Keychain** on macOS).
- [ ] (macOS) On first Keychain access, if prompted, Allow. The key persists.
- [ ] Clear the field and Save → key is removed; relaunch confirms it's gone.

### 4. Quick capture shortcut (platform modifier)
- [ ] Windows: **Ctrl+Shift+N** opens Quick Capture from anywhere.
- [ ] macOS: **⌘+Shift+N** opens Quick Capture (Cmd, not Ctrl).
- [ ] The body is prefilled from the clipboard; **Ctrl/⌘+Enter** saves it to the
      Inbox; the item appears in the Inbox list.
- [ ] The Inbox app-bar bolt icon also opens Quick Capture.

### 5. Command palette
- [ ] Windows: **Ctrl+K** / macOS: **⌘+K** opens the palette.
- [ ] Typing a prompt title shows results; Enter navigates to it.

### 6. Inline media (native backends bundled)
Add outputs with attachments (or open existing ones) and open the viewer:
- [ ] **PDF** renders inline (pdfium) — pages scroll, zoom works.
- [ ] **Video** (e.g. a small `.mp4`) plays inline (libmpv) with controls.
- [ ] **Audio** (e.g. `.mp3`/`.m4a`) plays inline with the transport.
- [ ] If any backend is unavailable, you get the in-app error panel + **Open
      externally** (never a crash).

### 7. File pickers (user-selected files)
- [ ] Attach a file via the OS file picker (Add Output → Attach Files) — the
      native dialog opens and the file is captured.
- [ ] (macOS) The sandbox allows the chosen file (user-selected-files
      entitlement).

### 8. Export → import round-trip
- [ ] Settings → Export Data → save the `.promptforge` bundle to disk (native
      save dialog).
- [ ] Settings → Import Data → choose the bundle → the dry-run summary shows the
      right counts → Confirm.
- [ ] Imported prompts/outputs (and any attachment files) appear intact.
- [ ] A prompt's **Export as Markdown** writes a `.md` with YAML front-matter.

### 9. Multi-model run (optional, needs a real key)
- [ ] With a Gemini key set, run a prompt against ≥2 models — outputs appear in
      the comparison view; a failing model shows a per-column error, others
      still save.

---

## Result

- Platform: ____________  Build: ____________ (tag/commit)
- All boxes checked? ☐ Yes ☐ No (note failures below)
- Notes / issues:

When both Windows and macOS pass this checklist, mark Stage 26 fully accepted in
`ROADMAP.md` / `HANDOFF.md` (CI-green + owner-verified).
