import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';
import '../../execution/application/pricing_service.dart';
import 'mcp_settings_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _retentionCap = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadRetention();
  }

  Future<void> _loadRetention() async {
    final s = await ref
        .read(userSettingsDaoProvider)
        .getSetting('version_retention_cap');
    if (mounted) {
      setState(() {
        _retentionCap = int.tryParse(s?.value ?? '') ?? 0;
        _loaded = true;
      });
    }
  }

  Future<void> _editPricing() async {
    final service = ref.read(pricingServiceProvider);
    final raw = await service.rawJson();
    if (!mounted) return;
    final controller = TextEditingController(text: raw);
    String? error;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Model pricing (community-maintained)'),
          content: SizedBox(
            width: 560,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Approximate per-1M-token prices used only for cost '
                    'estimates. Verify against the provider; costs are shown as '
                    '"est." and only when real token counts are available.'),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  maxLines: 14,
                  style: const TextStyle(
                      fontFamily: 'JetBrainsMono', fontSize: 12),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    errorText: error,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final bundled = await service.bundledJson();
                controller.text = bundled;
                setLocal(() => error = null);
              },
              child: const Text('Reset to bundled'),
            ),
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                try {
                  await service.save(controller.text);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                } catch (e) {
                  setLocal(() => error = 'Invalid JSON: $e');
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
  }

  Future<void> _editRetention() async {
    final controller =
        TextEditingController(text: _retentionCap > 0 ? '$_retentionCap' : '');
    final result = await showDialog<int?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Per-prompt version cap'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Keep at most this many versions per prompt; oldest are pruned. '
                'Leave blank or 0 to keep all.'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Max versions (0 = unlimited)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(ctx)
                .pop(int.tryParse(controller.text.trim()) ?? 0),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null) return;
    final cap = result < 0 ? 0 : result;
    await ref.read(userSettingsDaoProvider).setSetting(
          UserSettingsCompanion.insert(
            key: 'version_retention_cap',
            value: '$cap',
            updatedAt: DateTime.now(),
          ),
        );
    if (mounted) setState(() => _retentionCap = cap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.key),
            title: const Text('API Keys'),
            subtitle:
                const Text('Configure your BYOK LLM execution keys safely.'),
            onTap: () => context.go('/settings/keys'),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Version history retention'),
            subtitle: Text(!_loaded
                ? 'Loading…'
                : _retentionCap > 0
                    ? 'Keep the last $_retentionCap versions per prompt'
                    : 'Keep all versions (unlimited)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _editRetention,
          ),
          ListTile(
            leading: const Icon(Icons.toll_outlined),
            title: const Text('Model pricing'),
            subtitle: const Text(
                'Edit community-maintained prices used for cost estimates.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _editPricing,
          ),
          ListTile(
            leading: const Icon(Icons.hub_outlined),
            title: const Text('MCP Server'),
            subtitle: const Text(
                'Expose your prompt library (read-only) to MCP clients. '
                'Off by default.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const McpSettingsScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export Data'),
            subtitle:
                const Text('Export your prompts and context packs to JSON.'),
            onTap: () => context.go('/settings/export'),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import Data'),
            subtitle: const Text('Import prompts and context packs from JSON.'),
            onTap: () => context.go('/settings/import'),
          ),
        ],
      ),
    );
  }
}
