import 'dart:async';

import 'package:dart_mcp/server.dart';
import 'package:json_rpc_2/json_rpc_2.dart' show RpcException;

import 'prompt_read_store.dart';

/// JSON-RPC error code (server-error range) for "MCP server unavailable"
/// conditions: disabled in Settings, missing/busy database, or schema mismatch.
const int kMcpUnavailableCode = -32000;

/// PromptForge's read-only MCP server.
///
/// Exposes the prompt library over stdio: `prompts/list` + `prompts/get` (with
/// template variables as arguments) and the `search_prompts` / `get_prompt`
/// tools (added in Part B). It is **read-only** and **off by default** — it
/// refuses to serve anything until the user enables it in Settings, and it never
/// touches API keys / secure storage (that data isn't in this database at all).
base class PromptForgeMcpServer extends MCPServer
    with PromptsSupport, ToolsSupport {
  /// Absolute path to the PromptForge SQLite database (read-only).
  final String dbPath;

  PromptReadStore? _store;

  PromptForgeMcpServer(
    super.channel, {
    required this.dbPath,
    required String appVersion,
  }) : super.fromStreamChannel(
          implementation:
              Implementation(name: 'PromptForge', version: appVersion),
          instructions:
              'Read-only access to your PromptForge prompt library: list and '
              'fetch prompts (template variables become arguments), and search.',
        );

  /// The opened store, available only after a successful [initialize].
  PromptReadStore get store =>
      _store ??
      (throw RpcException(kMcpUnavailableCode, 'Server is not initialized.'));

  @override
  FutureOr<InitializeResult> initialize(InitializeRequest request) async {
    // Gate every capability behind a successful open + the enabled flag. Any
    // failure becomes a clean JSON-RPC error on `initialize` (no crash, no
    // stack trace), exactly as the security model requires.
    try {
      final opened = PromptReadStore.open(dbPath);
      if (!opened.mcpEnabled) {
        opened.close();
        throw const McpStoreException(
            'The PromptForge MCP server is disabled. Enable it in '
            'PromptForge → Settings → MCP Server.');
      }
      _store = opened;
    } on McpStoreException catch (e) {
      throw RpcException(kMcpUnavailableCode, e.message);
    }
    return super.initialize(request);
  }
}
