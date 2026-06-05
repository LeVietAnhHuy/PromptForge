import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';

enum PaletteGroup { prompts, tags, outputs }

class PaletteResult {
  final PaletteGroup group;
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;

  const PaletteResult({
    required this.group,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });
}

/// Backs the global command palette by querying the existing DAOs (the same
/// data layer the per-tab search surfaces use) — not a second search engine.
class CommandPaletteService {
  CommandPaletteService(this._ref);

  final Ref _ref;

  Future<List<PaletteResult>> search(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty) return const [];
    final q = query.toLowerCase();
    final results = <PaletteResult>[];

    // Prompts (title / purpose / body).
    final prompts = await _ref.read(promptDaoProvider).getAllPrompts();
    for (final p in prompts.where((p) {
      return p.title.toLowerCase().contains(q) ||
          (p.purpose ?? '').toLowerCase().contains(q) ||
          p.body.toLowerCase().contains(q);
    }).take(8)) {
      results.add(PaletteResult(
        group: PaletteGroup.prompts,
        icon: Icons.description_outlined,
        title: p.title,
        subtitle: (p.purpose != null && p.purpose!.isNotEmpty)
            ? p.purpose!
            : 'Prompt',
        route: '/library/editor/${p.id}',
      ));
    }

    // Tags.
    final tags = await _ref.read(tagDaoProvider).getAllTags();
    for (final t
        in tags.where((t) => t.name.toLowerCase().contains(q)).take(6)) {
      results.add(PaletteResult(
        group: PaletteGroup.tags,
        icon: Icons.label_outline,
        title: '#${t.name}',
        subtitle: 'Tag · open Library',
        route: '/library',
      ));
    }

    // Outputs (text / provider / model), navigating to the owning prompt.
    final outputs =
        await _ref.read(promptExampleOutputDaoProvider).searchOutputs(query);
    for (final (output, promptId) in outputs) {
      final model = (output.modelName != null && output.modelName!.isNotEmpty)
          ? ' · ${output.modelName}'
          : '';
      results.add(PaletteResult(
        group: PaletteGroup.outputs,
        icon: Icons.forum_outlined,
        title: '${output.providerName}$model',
        subtitle: _snippet(output.outputText, q),
        route: promptId != null ? '/library/editor/$promptId' : '/library',
      ));
    }

    return results;
  }

  String _snippet(String text, String q) {
    final clean = text.replaceAll('\n', ' ').trim();
    if (clean.isEmpty) return 'Output';
    final idx = clean.toLowerCase().indexOf(q);
    if (idx <= 0) {
      return clean.length > 80 ? '${clean.substring(0, 80)}…' : clean;
    }
    final start = (idx - 20).clamp(0, clean.length);
    final end = (idx + 60).clamp(0, clean.length);
    final prefix = start > 0 ? '…' : '';
    final suffix = end < clean.length ? '…' : '';
    return '$prefix${clean.substring(start, end)}$suffix';
  }
}

final commandPaletteServiceProvider = Provider<CommandPaletteService>((ref) {
  return CommandPaletteService(ref);
});
