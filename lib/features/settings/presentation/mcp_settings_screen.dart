import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../app/theme/app_design.dart';
import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';
import '../../../mcp/prompt_read_store.dart' show kMcpEnabledKey;

/// Settings → MCP Server: enable/disable the read-only MCP sidecar and copy
/// ready-made client configuration snippets (with the real binary + DB paths).
class McpSettingsScreen extends ConsumerStatefulWidget {
  const McpSettingsScreen({super.key});

  @override
  ConsumerState<McpSettingsScreen> createState() => _McpSettingsScreenState();
}

class _McpSettingsScreenState extends ConsumerState<McpSettingsScreen> {
  bool _enabled = false;
  bool _loaded = false;
  String _dbPath = '';
  late final String _sidecarPath = _computeSidecarPath();
  late final bool _sidecarExists = File(_sidecarPath).existsSync();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final setting =
        await ref.read(userSettingsDaoProvider).getSetting(kMcpEnabledKey);
    final docs = await getApplicationDocumentsDirectory();
    if (!mounted) return;
    setState(() {
      _enabled = (setting?.value.toLowerCase().trim() ?? '') == 'true';
      _dbPath = p.join(docs.path, 'promptforge_db.sqlite');
      _loaded = true;
    });
  }

  /// Where the bundled sidecar lives in an installed/extracted artifact:
  /// `<dir of app binary>/mcp/bin/promptforge_mcp[.exe]` (its native libs sit
  /// in the sibling `mcp/lib/`). See docs/RELEASING.md / docs/MCP.md.
  String _computeSidecarPath() {
    final exeDir = p.dirname(Platform.resolvedExecutable);
    final name = Platform.isWindows ? 'promptforge_mcp.exe' : 'promptforge_mcp';
    return p.join(exeDir, 'mcp', 'bin', name);
  }

  Future<void> _setEnabled(bool value) async {
    await ref.read(userSettingsDaoProvider).setSetting(
          UserSettingsCompanion.insert(
            key: kMcpEnabledKey,
            value: value ? 'true' : 'false',
            updatedAt: DateTime.now(),
          ),
        );
    if (mounted) setState(() => _enabled = value);
  }

  void _copy(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$label copied')));
    }
  }

  String get _claudeCodeSnippet =>
      'claude mcp add promptforge -- "$_sidecarPath" --db "$_dbPath"';

  String get _jsonSnippet {
    // jsonEncode handles Windows backslash + space escaping correctly.
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert({
      'mcpServers': {
        'promptforge': {
          'command': _sidecarPath,
          'args': ['--db', _dbPath],
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('MCP Server')),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppDesign.spacingLg),
              children: [
                SwitchListTile(
                  value: _enabled,
                  onChanged: _setEnabled,
                  title: const Text('Enable MCP server'),
                  subtitle: const Text(
                      'Off by default. When on, any MCP client you configure '
                      'can read your prompt library (read-only) — list, fetch, '
                      'and search prompts. Your API keys are never exposed.'),
                ),
                const SizedBox(height: AppDesign.spacingMd),
                Text('How it works', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppDesign.spacingXs),
                Text(
                  'A small local program (the sidecar) talks to MCP clients over '
                  'stdio — no network, no ports. It reads this app\'s database '
                  'read-only and never writes. You must enable it above AND add '
                  'it to each client using a snippet below.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppDesign.spacingLg),
                _pathTile(theme, 'Sidecar binary', _sidecarPath,
                    warn: !_sidecarExists
                        ? 'Not found here yet — this is its path in an installed '
                            'build. In a dev checkout, build it with '
                            '`dart build cli bin/promptforge_mcp.dart`.'
                        : null),
                const SizedBox(height: AppDesign.spacingMd),
                _pathTile(theme, 'Database (read-only)', _dbPath),
                const SizedBox(height: AppDesign.spacingLg),
                Text('Client setup', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppDesign.spacingXs),
                Text(
                  'Examples — exact syntax may vary by client version. See '
                  'docs/MCP.md for troubleshooting.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppDesign.spacingMd),
                _snippet(theme, 'Claude Code', _claudeCodeSnippet),
                const SizedBox(height: AppDesign.spacingMd),
                _snippet(theme, 'Claude Desktop / Cursor (mcpServers JSON)',
                    _jsonSnippet),
              ],
            ),
    );
  }

  Widget _pathTile(ThemeData theme, String label, String value,
      {String? warn}) {
    return Container(
      padding: const EdgeInsets.all(AppDesign.spacingMd),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: AppDesign.borderMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(label, style: theme.textTheme.labelLarge)),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                tooltip: 'Copy $label',
                onPressed: () => _copy(value, label),
              ),
            ],
          ),
          SelectableText(value,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontFamily: AppDesign.fontMono)),
          if (warn != null) ...[
            const SizedBox(height: AppDesign.spacingXs),
            Text(warn,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.error)),
          ],
        ],
      ),
    );
  }

  Widget _snippet(ThemeData theme, String label, String code) {
    return Container(
      padding: const EdgeInsets.all(AppDesign.spacingMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: AppDesign.borderMd,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(label, style: theme.textTheme.labelLarge)),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy'),
                onPressed: () => _copy(code, label),
              ),
            ],
          ),
          const SizedBox(height: AppDesign.spacingSm),
          SelectableText(code,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontFamily: AppDesign.fontMono)),
        ],
      ),
    );
  }
}
