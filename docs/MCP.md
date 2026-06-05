# PromptForge MCP Server

PromptForge can act as a [Model Context Protocol](https://modelcontextprotocol.io)
server, letting MCP clients (Claude Code, Claude Desktop, Cursor, …) read your
prompt library. It is **read-only, local, stdio-only, and off by default.**

## What it exposes

- **`prompts/list`** — every non-archived prompt: `name` (the prompt's stable
  id), `title`, `description` (its Purpose), and `arguments` derived from the
  template `{variables}` (an argument is *required* when the variable has no
  stored default).
- **`prompts/get`** — resolves a prompt's body, applying your argument values
  over stored defaults (the same logic as the in-app "Fill & use"). Missing
  required arguments return an error naming them.
- **Tools** (for clients with weak prompts support):
  - `search_prompts(query, tags?)` — up to 20 matches over title/purpose/body/
    tags (case-insensitive; `tags` filters to prompts carrying *all* listed tags).
  - `get_prompt(id, variables?)` — the resolved prompt text.

**Not in v1:** no resources (attachments/outputs), and **no tools that create,
modify, or delete anything** — the server is strictly read-only.

## Security model

- **Off by default.** The server refuses every request until you enable it in
  **PromptForge → Settings → MCP Server** (it stores an `mcp_enabled` flag).
- **Read-only.** It opens the database read-only and never writes your data. Its
  only filesystem access is that database and the enable flag.
- **stdio only.** No HTTP, no listening socket, no port, no auth surface — the
  client launches it as a child process and talks over stdin/stdout.
- **No secrets.** Your BYOK API keys live in the OS keychain, not in this
  database, so they are unreachable through every MCP surface (there is a test
  asserting this).
- **Local.** Nothing is sent anywhere; the client decides what to do with what
  it reads.

## Setup

Open **Settings → MCP Server** in PromptForge. It shows the exact sidecar binary
path and database path for *your* machine and generates copy-able snippets — use
those (the paths below are placeholders).

- **Claude Code:**
  ```
  claude mcp add promptforge -- "/path/to/mcp/bin/promptforge_mcp" --db "/path/to/promptforge_db.sqlite"
  ```
- **Claude Desktop / Cursor** (`mcpServers` block in the client's MCP config):
  ```json
  {
    "mcpServers": {
      "promptforge": {
        "command": "/path/to/mcp/bin/promptforge_mcp",
        "args": ["--db", "/path/to/promptforge_db.sqlite"]
      }
    }
  }
  ```

These are examples; exact syntax/config-file location varies by client version.

## Where the binary lives

The sidecar ships next to the app inside `mcp/` (binary in `mcp/bin/`, its native
libraries in `mcp/lib/` — keep them together):

| Platform | Path (relative to the installed app) |
| --- | --- |
| Linux (tar.gz/AppImage) | `<app dir>/mcp/bin/promptforge_mcp` |
| Windows (zip/MSIX) | `<app dir>\mcp\bin\promptforge_mcp.exe` |
| macOS (.app) | `PromptForge.app/Contents/MacOS/mcp/bin/promptforge_mcp` |

`promptforge_mcp --version` prints the version and supported MCP protocol range.
`promptforge_mcp --db <path>` overrides the database location (Settings bakes the
correct `--db` into the snippets).

## Troubleshooting

- **"MCP server is disabled"** — enable it in Settings → MCP Server.
- **"database not found"** — pass the right `--db` (copy it from Settings).
- **"database is busy"** — PromptForge was mid-write; retry (the server already
  waits briefly).
- **"schema is newer than this server understands"** — update PromptForge so the
  sidecar matches the database.
- **Client shows no prompts** — confirm the toggle is on, the client points at
  the right binary, and the `mcp/lib/` folder sits beside `mcp/bin/`.

## Limitations (v1)

Read-only; prompts + the two tools only; no resources; no write tools; prompts
are read once per client session (reconnect to pick up changes). A write tool
(e.g. `save_prompt`) and resource exposure are tracked in the roadmap backlog.
