# Stage 27 — Owner Hands-On Verification Checklist (MCP Server)

Automated tests + a dev dogfood already cover the protocol and the compiled
binary (see "What CI/dev already verified" below). This checklist is the final
hands-on gate on a **real machine with real MCP clients** (Claude Code and
Claude Desktop), against your **real** prompt library.

Run on: ☐ the OS you use daily (and optionally a second desktop OS).

## Setup
- [ ] Install/extract a PromptForge build for your OS (from a release artifact,
      or a local `flutter build`). Confirm `mcp/bin/promptforge_mcp` sits next to
      the app binary (with `mcp/lib/` beside it).
- [ ] Launch PromptForge → **Settings → MCP Server**.
- [ ] The screen shows a sidecar path that exists and your real database path.
- [ ] Toggle **Enable MCP server** ON.

## Claude Code
- [ ] Copy the **Claude Code** snippet and run it in a terminal
      (`claude mcp add promptforge -- "<sidecar>" --db "<db>"`).
- [ ] `claude mcp get promptforge` shows **✓ Connected**.
- [ ] In a Claude Code session, confirm your prompts are listed (e.g. ask it to
      use the `promptforge` prompts, or call `search_prompts`).
- [ ] Fetch a prompt that has variables — supplying values fills them in; the
      result uses defaults for omitted optional variables.
- [ ] Omitting a required (no-default) variable returns a clear "missing
      required argument" error.
- [ ] `search_prompts` returns relevant matches; a `tags` filter narrows them.

## Claude Desktop
- [ ] Copy the **mcpServers JSON** snippet into Claude Desktop's MCP config and
      restart it.
- [ ] PromptForge appears as a connected MCP server.
- [ ] Its prompts are listed and one with variables can be inserted.

## Security gate (must verify)
- [ ] Toggle **Enable MCP server** OFF in Settings.
- [ ] Re-check the client (`claude mcp get promptforge`, or restart Claude
      Desktop): it now **fails to connect** with a "disabled — enable in
      Settings" message. (Dev dogfood confirmed this: disabled → ✗ Failed to
      connect.)
- [ ] No API key ever appears in any prompt, fetch, or search result.

## What CI/dev already verified (so you don't have to)
- The sidecar **builds and `--version` runs on Linux, Windows, and macOS** in CI.
- In-process + **spawned compiled-binary** tests cover: initialize handshake,
  `prompts/list` argument mapping (required = no default), `prompts/get` with
  defaults / overrides / missing-required error, `search_prompts` (+ tags AND
  filter, empty-query guard), `get_prompt` tool, the **disabled-flag** block, a
  **newer-schema** refusal, and a **no-API-key-leak** scan of all wire output.
- Dev dogfood: **Claude Code 2.1.165 connected to the compiled sidecar over
  stdio (✓ Connected)** against a copy of the dev DB, and the **disabled toggle
  blocked it (✗ Failed to connect)**. Not verified headlessly: a full
  model-driven Claude Code / Claude Desktop conversation on real hardware — that
  is what this checklist covers.

## Result
- Platform(s): ____________  Build: ____________
- All boxes checked? ☐ Yes ☐ No (notes):
