import 'dart:async';

import 'package:dart_mcp/server.dart';
import 'package:json_rpc_2/json_rpc_2.dart' show RpcException;

import '../features/prompt_compiler/domain/variable_resolver.dart' as vars;
import 'prompt_read_store.dart';

/// JSON-RPC error code (server-error range) for "MCP server unavailable"
/// conditions: disabled in Settings, missing/busy database, or schema mismatch.
const int kMcpUnavailableCode = -32000;

/// Defensive caps (a personal library is small; these only guard pathological
/// sizes / abusive input).
const int kMaxExposedPrompts = 500;
const int kMaxQueryLength = 200;
const int kSearchLimit = 20;
const int _kPurposeSnippet = 160;

/// PromptForge's read-only MCP server.
///
/// Over stdio it exposes `prompts/list` + `prompts/get` (template variables as
/// arguments) and the `search_prompts` / `get_prompt` tools. It is **read-only**
/// and **off by default**: it serves nothing until the user enables it in
/// Settings, and it never reaches API keys / secure storage (that data isn't in
/// this database). Each client session spawns a fresh process, so prompts are
/// loaded once at [initialize] — effectively live per session.
base class PromptForgeMcpServer extends MCPServer
    with PromptsSupport, ToolsSupport {
  /// Absolute path to the PromptForge SQLite database (opened read-only).
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
    // stack trace) — the security model's "disabled returns a clear error".
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
    _registerPrompts();
    _registerTools();
    return super.initialize(request);
  }

  @override
  Future<void> shutdown() async {
    // Release the read-only DB handle so the file isn't held open after the
    // session ends (notably so Windows can delete it; the process would release
    // it on exit regardless).
    _store?.close();
    _store = null;
    await super.shutdown();
  }

  // ---- prompts/list + prompts/get -----------------------------------------

  void _registerPrompts() {
    final prompts = store.listActivePrompts();
    final capped = prompts.length > kMaxExposedPrompts
        ? prompts.sublist(0, kMaxExposedPrompts)
        : prompts;
    for (final p in capped) {
      addPrompt(_describe(p), (req) => _getPromptResult(p.id, req.arguments));
    }
  }

  /// Builds the `prompts/list` descriptor: name = the stable prompt id, title =
  /// the prompt title, description = its Purpose (truncated), and arguments
  /// mapped from the template variables. Per the MCP mapping, an argument is
  /// `required` when it has no stored default value.
  Prompt _describe(PromptSummary p) {
    final meta = {
      for (final m in store.variablesForPrompt(p.id)) m.name: m,
    };
    final args = [
      for (final name in vars.extractVariables(p.body))
        PromptArgument(
          name: name,
          description: meta[name]?.description,
          required: _isRequired(meta[name]),
        ),
    ];
    return Prompt(
      name: p.id,
      title: p.title,
      description: _truncate(p.purpose, _kPurposeSnippet),
      arguments: args.isEmpty ? null : args,
    );
  }

  /// MCP "required" = the variable has no usable default value.
  bool _isRequired(PromptVariableMeta? m) {
    final d = m?.defaultValue;
    return d == null || d.isEmpty;
  }

  GetPromptResult _getPromptResult(String id, Map<String, Object?>? arguments) {
    final provided = <String, String>{};
    if (arguments != null) {
      for (final e in arguments.entries) {
        provided[e.key] = '${e.value ?? ''}';
      }
    }
    final resolved = _resolve(id, provided);
    return GetPromptResult(
      description: resolved.title,
      messages: [
        PromptMessage(
          role: Role.user,
          content: TextContent(text: resolved.text),
        ),
      ],
    );
  }

  /// Resolves a prompt body by applying [provided] values over stored defaults
  /// (the shared in-app resolution path). Throws an `invalid_params` RPC error
  /// listing any required (no-default) variables that weren't provided.
  ({String text, String title}) _resolve(
      String id, Map<String, String> provided) {
    final prompt = store.promptById(id);
    if (prompt == null) {
      throw RpcException.invalidParams('Prompt "$id" was not found.');
    }
    final meta = {
      for (final m in store.variablesForPrompt(id)) m.name: m,
    };
    final result = vars.substituteVariables(prompt.body, (name) {
      final value = provided[name];
      if (value != null && value.isNotEmpty) return value;
      final def = meta[name]?.defaultValue;
      if (def != null && def.isNotEmpty) return def;
      return null; // required + not provided → missing
    });
    if (result.missing.isNotEmpty) {
      throw RpcException.invalidParams(
          'Missing required argument(s): ${result.missing.join(', ')}');
    }
    return (text: result.text, title: prompt.title);
  }

  // ---- tools (read-only) --------------------------------------------------

  void _registerTools() {
    registerTool(
      Tool(
        name: 'search_prompts',
        description:
            'Search the PromptForge prompt library (case-insensitive over '
            'title, purpose, body, and tags). Returns up to $kSearchLimit matches.',
        inputSchema: ObjectSchema(
          properties: {
            'query': Schema.string(
                description: 'Text to search for (case-insensitive).'),
            'tags': Schema.string(
                description: 'Optional comma-separated tags; a match must '
                    'contain all of them.'),
          },
          required: ['query'],
        ),
      ),
      _searchPromptsTool,
    );
    registerTool(
      Tool(
        name: 'get_prompt',
        description:
            'Fetch a prompt by id and resolve its template variables. For '
            'clients with limited prompts support.',
        inputSchema: ObjectSchema(
          properties: {
            'id': Schema.string(
                description: 'Prompt id (the name from search_prompts or '
                    'prompts/list).'),
            'variables': ObjectSchema(
              description: 'Map of variable name to value.',
              additionalProperties: true,
            ),
          },
          required: ['id'],
        ),
      ),
      _getPromptTool,
    );
  }

  CallToolResult _searchPromptsTool(CallToolRequest request) {
    try {
      final raw = (request.arguments?['query'] as String?)?.trim() ?? '';
      if (raw.isEmpty) return _toolError('query must not be empty.');
      final query =
          raw.length > kMaxQueryLength ? raw.substring(0, kMaxQueryLength) : raw;
      final tagsArg = (request.arguments?['tags'] as String?) ?? '';
      final tags = tagsArg
          .split(RegExp(r'[,]+'))
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();
      final results = store.search(query, tags: tags, limit: kSearchLimit);
      if (results.isEmpty) {
        return CallToolResult(
            content: [TextContent(text: 'No prompts matched "$query".')]);
      }
      final buf = StringBuffer('${results.length} match(es):\n');
      for (final r in results) {
        final tagList = store.tagsForPrompt(r.id);
        buf.writeln('\n- id: ${r.id}');
        buf.writeln('  title: ${r.title}');
        final purpose = _truncate(r.purpose, _kPurposeSnippet);
        if (purpose != null) buf.writeln('  purpose: $purpose');
        if (tagList.isNotEmpty) buf.writeln('  tags: ${tagList.join(', ')}');
        buf.writeln('  updated: ${r.updatedAt.toIso8601String()}');
      }
      return CallToolResult(content: [TextContent(text: buf.toString())]);
    } catch (e) {
      return _toolError('Search failed: ${_clean(e)}');
    }
  }

  CallToolResult _getPromptTool(CallToolRequest request) {
    try {
      final id = (request.arguments?['id'] as String?)?.trim() ?? '';
      if (id.isEmpty) return _toolError('id must not be empty.');
      final provided = <String, String>{};
      final v = request.arguments?['variables'];
      if (v is Map) {
        v.forEach((key, value) => provided['$key'] = '${value ?? ''}');
      }
      try {
        final resolved = _resolve(id, provided);
        return CallToolResult(content: [TextContent(text: resolved.text)]);
      } on RpcException catch (e) {
        // Missing-required / not-found surface as a tool error (clean message).
        return _toolError(e.message);
      }
    } catch (e) {
      return _toolError('get_prompt failed: ${_clean(e)}');
    }
  }

  // ---- helpers ------------------------------------------------------------

  CallToolResult _toolError(String message) =>
      CallToolResult(isError: true, content: [TextContent(text: message)]);

  /// Keeps error messages free of stack traces / local paths.
  String _clean(Object e) =>
      e is McpStoreException ? e.message : 'unexpected error';

  static String? _truncate(String? s, int max) {
    final t = s?.trim() ?? '';
    if (t.isEmpty) return null;
    return t.length <= max ? t : '${t.substring(0, max).trimRight()}…';
  }
}
