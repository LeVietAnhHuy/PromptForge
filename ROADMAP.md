# PromptForge Roadmap

> Renumbering note (Stage 27): the **MCP server** was pulled forward from the old
> Stage 36 by owner decision and executed as **Stage 27**. Everything after it
> shifted by one — old Stages 27–35 are now **28–36**; Stages 37–38 are
> unchanged.

Done:
- Stage 22 — BYOK LLM execution + output capture
- Stage 23 — Forge design system, layout, provider identity, model picker,
  attachment viewer, command palette
- Stage 24 — Picker/logo/media fixes, inline PDF+AV, pre-save preview,
  attachment persistence bug, app-wide polish
- Stage 25 — Workbench core: card-refresh fix, version history + provenance,
  template variables, multi-model comparison + ratings + token/cost, quick
  capture, import/export (versioned bundle + attachments, Markdown export)
- Stage 26 — Cross-platform desktop: Windows + macOS targets, media backends
  per platform, packaging (MSIX/zip, DMG/zip, AppImage/tar.gz), GitHub Actions
  CI matrix + release workflow. **CI-green on all three OSes**; owner hands-on
  verification pending (`docs/VERIFICATION-STAGE26.md`).
- Stage 27 — **MCP server** (pulled forward from old Stage 36): a read-only,
  local, off-by-default stdio sidecar (`bin/promptforge_mcp.dart`, built with
  `dart build cli`) exposing the prompt library to MCP clients — `prompts/list`
  + `prompts/get` (template variables as arguments) and `search_prompts` /
  `get_prompt` tools. SDK: `dart_mcp`. **CI builds + version-checks it on all
  three OSes** and ships it inside every release artifact; dev-dogfooded with
  Claude Code (connect + disabled-gate). Owner hands-on verification pending
  (`docs/VERIFICATION-STAGE27.md`).

MCP backlog (deferred from v1): a write tool (e.g. `save_prompt`); exposing
attachments/outputs as MCP resources; `listChanged` notifications.

## Phase 1 — Workbench foundation — COMPLETE (Stages 25–26)

## Phase 2 — Reach
- Stage 28 — Web app: Flutter web build, browser storage adapter, viewer
  adaptations, deploy
- Stage 29 — Sync & accounts foundation: optional local-first sync
  (Supabase), conflict handling; API keys never sync
- Stage 30 — Mobile: iOS + Android, adaptive layouts, share-sheet capture,
  store packaging
- Stage 31 — Capture everywhere: browser extension clipping from
  ChatGPT/Claude/Gemini web UIs; chat-transcript → prompt importer

## Phase 3 — Trust
- Stage 32 — Compliance lint v1: versioned policy rule-pack data files,
  heuristics, free moderation-API backend; strictly advisory framing
- Stage 33 — Compliance lint v2: BYOK checker with cross-provider routing and
  privacy warnings; per-provider compliant variations with hard-blocked
  categories (rewrite legitimate wording only — never assist evading safety
  systems); optional local guard models (gpt-oss-safeguard desktop; Llama
  Guard 3-1B mobile as user download, license surfaced)

## Phase 4 — Community
- Stage 34 — Read-only gallery (PocketBase): featured prompts, open-in-app
- Stage 35 — Publish: accounts, publish flow, CC0/CC-BY license picker,
  automated moderation on every submission + report system (Supabase)
- Stage 36 — Social + forks: votes, comments, leaderboards, trust levels;
  fork lineage with verified outputs tied to multi-model comparison

## Phase 5 — Agent era
- Stage 37 — Agent context types: CLAUDE.md / AGENTS.md / SKILL.md as
  first-class versioned content; repo import/export; context-budget linter
- Stage 38 — Eval harness: prompt/instruction regression testing across
  models; re-test on model updates
