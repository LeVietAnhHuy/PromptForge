# PromptForge Roadmap

Done:
- Stage 22 — BYOK LLM execution + output capture
- Stage 23 — Forge design system, layout, provider identity, model picker,
  attachment viewer, command palette
- Stage 24 — Picker/logo/media fixes, inline PDF+AV, pre-save preview,
  attachment persistence bug, app-wide polish
- Stage 25 — Workbench core: card-refresh fix, version history + provenance,
  template variables, multi-model comparison + ratings + token/cost, quick
  capture, import/export (versioned bundle + attachments, Markdown export)

## Phase 1 — Workbench foundation
- Stage 26 — Cross-platform desktop: Windows + macOS builds, conditional
  media backends, packaging (MSIX/DMG/AppImage), CI build matrix

## Phase 2 — Reach
- Stage 27 — Web app: Flutter web build, browser storage adapter, viewer
  adaptations, deploy
- Stage 28 — Sync & accounts foundation: optional local-first sync
  (Supabase), conflict handling; API keys never sync
- Stage 29 — Mobile: iOS + Android, adaptive layouts, share-sheet capture,
  store packaging
- Stage 30 — Capture everywhere: browser extension clipping from
  ChatGPT/Claude/Gemini web UIs; chat-transcript → prompt importer

## Phase 3 — Trust
- Stage 31 — Compliance lint v1: versioned policy rule-pack data files,
  heuristics, free moderation-API backend; strictly advisory framing
- Stage 32 — Compliance lint v2: BYOK checker with cross-provider routing and
  privacy warnings; per-provider compliant variations with hard-blocked
  categories (rewrite legitimate wording only — never assist evading safety
  systems); optional local guard models (gpt-oss-safeguard desktop; Llama
  Guard 3-1B mobile as user download, license surfaced)

## Phase 4 — Community
- Stage 33 — Read-only gallery (PocketBase): featured prompts, open-in-app
- Stage 34 — Publish: accounts, publish flow, CC0/CC-BY license picker,
  automated moderation on every submission + report system (Supabase)
- Stage 35 — Social + forks: votes, comments, leaderboards, trust levels;
  fork lineage with verified outputs tied to multi-model comparison

## Phase 5 — Agent era
- Stage 36 — MCP server: expose library via MCP prompts/resources to Claude
  Code, Cursor, ChatGPT etc.; local-only by default, explicit enablement
  (NOTE: depends only on Stage 25 + desktop — may be pulled forward after
  Stage 26 if agent integration is prioritized over mobile reach)
- Stage 37 — Agent context types: CLAUDE.md / AGENTS.md / SKILL.md as
  first-class versioned content; repo import/export; context-budget linter
- Stage 38 — Eval harness: prompt/instruction regression testing across
  models; re-test on model updates
