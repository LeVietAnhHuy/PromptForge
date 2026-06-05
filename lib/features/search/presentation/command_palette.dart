import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_design.dart';
import '../application/command_palette_service.dart';

/// Global command palette (Ctrl/Cmd+K): searches prompts, tags and outputs
/// across the workspace and navigates to the chosen result on Enter or tap.
class CommandPalette extends ConsumerStatefulWidget {
  const CommandPalette({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => const CommandPalette(),
    );
  }

  @override
  ConsumerState<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends ConsumerState<CommandPalette> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _fieldFocus = FocusNode();
  Timer? _debounce;
  List<PaletteResult> _results = const [];
  int _highlight = 0;
  bool _searching = false;
  int _queryToken = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _fieldFocus.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 180), () => _run(value));
  }

  Future<void> _run(String value) async {
    final token = ++_queryToken;
    if (value.trim().isEmpty) {
      setState(() {
        _results = const [];
        _highlight = 0;
        _searching = false;
      });
      return;
    }
    setState(() => _searching = true);
    final results = await ref.read(commandPaletteServiceProvider).search(value);
    if (!mounted || token != _queryToken) return;
    setState(() {
      _results = results;
      _highlight = 0;
      _searching = false;
    });
  }

  void _move(int delta) {
    if (_results.isEmpty) return;
    setState(() {
      _highlight = (_highlight + delta).clamp(0, _results.length - 1);
    });
  }

  void _select([int? index]) {
    final i = index ?? _highlight;
    if (i < 0 || i >= _results.length) return;
    final route = _results[i].route;
    Navigator.of(context).pop();
    GoRouter.of(context).go(route);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowDown): () => _move(1),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () => _move(-1),
      },
      child: Dialog(
        alignment: Alignment.topCenter,
        insetPadding: const EdgeInsets.symmetric(
            horizontal: AppDesign.spacingLg, vertical: 80),
        backgroundColor: theme.colorScheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppDesign.borderModal,
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620, maxHeight: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField(theme),
              const Divider(height: 1),
              Flexible(child: _buildResults(theme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDesign.spacingMd, vertical: AppDesign.spacingSm),
      child: Row(
        children: [
          Icon(Icons.search, color: theme.colorScheme.primary),
          const SizedBox(width: AppDesign.spacingSm),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _fieldFocus,
              autofocus: true,
              textInputAction: TextInputAction.go,
              decoration: const InputDecoration(
                hintText: 'Search prompts, tags, outputs…',
                border: InputBorder.none,
                filled: false,
                isCollapsed: true,
              ),
              style: theme.textTheme.titleMedium,
              onChanged: _onChanged,
              onSubmitted: (_) => _select(),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: AppDesign.borderSm,
            ),
            child: Text('Esc',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(ThemeData theme) {
    if (_controller.text.trim().isEmpty) {
      return _hint(theme,
          'Type to search across prompts, tags and outputs. ↑↓ to move, Enter to open.');
    }
    if (_searching && _results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppDesign.spacingLg),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_results.isEmpty) {
      return _hint(theme, 'No matches for “${_controller.text.trim()}”.');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppDesign.spacingXs),
      itemCount: _results.length,
      itemBuilder: (context, i) {
        final r = _results[i];
        final highlighted = i == _highlight;
        final showHeader = i == 0 || _results[i - 1].group != r.group;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppDesign.spacingMd,
                    AppDesign.spacingSm,
                    AppDesign.spacingMd,
                    AppDesign.spacingXs),
                child: Text(_groupLabel(r.group),
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w700)),
              ),
            ListTile(
              dense: true,
              tileColor: highlighted
                  ? theme.colorScheme.primary.withValues(alpha: 0.14)
                  : null,
              leading: Icon(r.icon, color: theme.colorScheme.onSurfaceVariant),
              title:
                  Text(r.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(r.subtitle,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () => _select(i),
              trailing: highlighted
                  ? Icon(Icons.keyboard_return,
                      size: 16, color: theme.colorScheme.primary)
                  : null,
            ),
          ],
        );
      },
    );
  }

  Widget _hint(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.all(AppDesign.spacingLg),
      child: Text(text,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
    );
  }

  String _groupLabel(PaletteGroup group) => switch (group) {
        PaletteGroup.prompts => 'PROMPTS',
        PaletteGroup.tags => 'TAGS',
        PaletteGroup.outputs => 'OUTPUTS',
      };
}
