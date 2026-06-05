import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_design.dart';
import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';
import '../../../shared/providers/provider_identity.dart';
import '../../execution/application/llm_execution_service.dart';
import '../../execution/domain/llm_provider.dart';
import 'output_editor_dialog.dart';
import 'output_rating_bar.dart';

/// Side-by-side comparison of an example's (or a whole prompt's) outputs.
///
/// Two modes:
///  * example-scoped (default constructor) — shows one example's outputs and
///    offers a multi-model run panel that adds outputs to that example.
///  * prompt-scoped ([ExampleComparisonScreen.forPrompt]) — a read-only view
///    that aggregates outputs across every example of a prompt, so comparison is
///    reachable from any prompt with ≥2 saved outputs.
class ExampleComparisonScreen extends ConsumerStatefulWidget {
  final String? exampleId;
  final String? promptId;

  const ExampleComparisonScreen({super.key, required this.exampleId})
      : promptId = null;

  const ExampleComparisonScreen.forPrompt(this.promptId, {super.key})
      : exampleId = null;

  bool get isPromptScoped => promptId != null;

  @override
  ConsumerState<ExampleComparisonScreen> createState() =>
      _ExampleComparisonScreenState();
}

/// A transient failure column for a model that errored during a multi-model run.
/// Failed runs are never persisted, so the screen holds them in memory until the
/// next run so the user still sees which model failed and why.
class _RunError {
  final String modelName;
  final String? providerId;
  final String providerName;
  final String message;
  const _RunError({
    required this.modelName,
    required this.providerId,
    required this.providerName,
    required this.message,
  });
}

class _ExampleComparisonScreenState
    extends ConsumerState<ExampleComparisonScreen> {
  PromptExample? _example;
  String _title = 'Compare Outputs';
  String? _scopePromptId; // prompt used for best-pin scoping + provenance
  bool _isLoading = true;
  String? _error;
  // Subscribed once (not per-build) so run-time setState calls don't reset the
  // StreamBuilder to its waiting state and blank the columns mid-run.
  Stream<List<PromptExampleOutput>>? _outputs;

  // Run panel state (example mode only).
  LlmExecutionProvider? _selectedProvider;
  List<Map<String, String>> _availableModels = [];
  final Set<String> _selectedModelIds = {};
  bool _isExecuting = false;
  List<_RunError> _runErrors = [];

  // Sync-scroll: one controller per output column, linked when enabled.
  bool _syncScroll = false;
  bool _syncing = false;
  final Map<String, ScrollController> _scrollControllers = {};

  static const int _maxModels = 4;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _scrollControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final outputDao = ref.read(promptExampleOutputDaoProvider);
      if (widget.isPromptScoped) {
        final prompt =
            await ref.read(promptDaoProvider).getPromptById(widget.promptId!);
        setState(() {
          _title = 'Compare: ${prompt.title}';
          _scopePromptId = widget.promptId;
          _outputs = outputDao.watchOutputsForPrompt(widget.promptId!);
          _isLoading = false;
        });
        return;
      }

      final example =
          await ref.read(promptExampleDaoProvider).getExampleById(widget.exampleId!);
      final providers = ref.read(executionProvidersProvider);
      LlmExecutionProvider? initialProvider;
      List<Map<String, String>> initialModels = [];
      if (providers.isNotEmpty) {
        initialProvider = providers.first;
        initialModels = await initialProvider.listAvailableModels();
      }
      setState(() {
        _example = example;
        _title = 'Compare: ${example.title}';
        _scopePromptId = example.promptId;
        _outputs = outputDao.watchOutputsForExample(example.id);
        _selectedProvider = initialProvider;
        _availableModels = initialModels;
        _selectedModelIds
          ..clear()
          ..addAll(initialModels.isNotEmpty
              ? {initialModels.first['id']!}
              : <String>{});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load: $e';
        _isLoading = false;
      });
    }
  }

  ScrollController _controllerFor(String id) {
    return _scrollControllers.putIfAbsent(id, () {
      final c = ScrollController();
      c.addListener(() {
        if (!_syncScroll || _syncing || !c.hasClients) return;
        _syncing = true;
        final off = c.offset;
        for (final other in _scrollControllers.values) {
          if (!identical(other, c) && other.hasClients) {
            other.jumpTo(off.clamp(
              other.position.minScrollExtent,
              other.position.maxScrollExtent,
            ));
          }
        }
        _syncing = false;
      });
      return c;
    });
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied to clipboard')),
    );
  }

  Future<void> _deleteOutput(String id) =>
      ref.read(promptExampleOutputDaoProvider).deleteOutput(id);

  String _modelNameFor(String modelId) {
    for (final model in _availableModels) {
      if (model['id'] == modelId) return model['name'] ?? modelId;
    }
    return modelId;
  }

  void _toggleModel(String id) {
    setState(() {
      if (_selectedModelIds.contains(id)) {
        _selectedModelIds.remove(id);
      } else {
        if (_selectedModelIds.length >= _maxModels) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Select at most 4 models to compare.')),
          );
          return;
        }
        _selectedModelIds.add(id);
      }
    });
  }

  Future<void> _runSelectedModels() async {
    if (_example == null || _selectedProvider == null) return;
    if (_selectedModelIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one model to run.')),
      );
      return;
    }

    setState(() {
      _isExecuting = true;
      _runErrors = [];
    });

    // Record provenance: which prompt version produced these outputs (latest
    // version of the linked prompt, if any). No tunable params here, so params
    // stay null and the provenance line shows "v# · model".
    String? promptVersionId;
    if (_scopePromptId != null) {
      final versions =
          await ref.read(promptDaoProvider).getPromptVersions(_scopePromptId!);
      if (versions.isNotEmpty) promptVersionId = versions.first.id;
    }

    final provider = _selectedProvider!;
    final targets = _selectedModelIds
        .map((id) => ModelRunTarget(
              providerId: provider.providerId,
              modelId: id,
              modelName: _modelNameFor(id),
            ))
        .toList();

    final service = ref.read(llmExecutionServiceProvider);
    final outcomes = await service.executeAndSaveMany(
      exampleId: _example!.id,
      compiledPrompt: _example!.compiledPrompt,
      targets: targets,
      promptVersionId: promptVersionId,
    );

    if (!mounted) return;
    final errors = outcomes
        .where((o) => !o.isSuccess)
        .map((o) => _RunError(
              modelName: o.target.modelName,
              providerId: provider.providerId,
              providerName: provider.providerName,
              message: o.error ?? 'Unknown error',
            ))
        .toList();

    setState(() {
      _isExecuting = false;
      _runErrors = errors;
    });

    final ok = outcomes.length - errors.length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errors.isEmpty
            ? '$ok output(s) saved.'
            : '$ok saved · ${errors.length} failed (see error columns). '
                'Use Add Output for manual fallback.'),
        backgroundColor: errors.isEmpty
            ? null
            : Theme.of(context).colorScheme.errorContainer,
      ),
    );
  }

  void _showManualOutputDialog() {
    if (_example == null) return;
    showDialog(
      context: context,
      builder: (context) => OutputEditorDialog(exampleId: _example!.id),
    );
  }

  // ---- Run panel (example mode only) -------------------------------------

  Widget _buildExecutionPanel() {
    final providers = ref.watch(executionProvidersProvider);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Run LLM Outputs',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 16),
              Expanded(child: _buildProviderDropdown(providers)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Models (pick up to $_maxModels to run concurrently)',
              style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableModels.map((m) {
              final id = m['id']!;
              final selected = _selectedModelIds.contains(id);
              return FilterChip(
                label: Text(m['name'] ?? id),
                selected: selected,
                onSelected:
                    _isExecuting ? null : (_) => _toggleModel(id),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _isExecuting ? null : _runSelectedModels,
                icon: _isExecuting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.play_arrow),
                label: Text(_selectedModelIds.isEmpty
                    ? 'Run'
                    : 'Run (${_selectedModelIds.length})'),
              ),
              OutlinedButton.icon(
                onPressed: _isExecuting ? null : _showManualOutputDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Output'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProviderDropdown(List<LlmExecutionProvider> providers) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Provider',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: DropdownButton<LlmExecutionProvider>(
        value: _selectedProvider,
        isExpanded: true,
        underline: const SizedBox(),
        items: providers.map((provider) {
          final identity = ProviderRegistry.resolve(
              providerId: provider.providerId,
              providerName: provider.providerName);
          return DropdownMenuItem(
            value: provider,
            child: Row(
              children: [
                ProviderLogo(identity: identity, size: 18),
                const SizedBox(width: 8),
                Flexible(child: Text(provider.providerName)),
              ],
            ),
          );
        }).toList(),
        onChanged: _isExecuting
            ? null
            : (provider) async {
                if (provider == null) return;
                final models = await provider.listAvailableModels();
                if (!mounted) return;
                setState(() {
                  _selectedProvider = provider;
                  _availableModels = models;
                  _selectedModelIds
                    ..clear()
                    ..addAll(models.isNotEmpty
                        ? {models.first['id']!}
                        : <String>{});
                });
              },
      ),
    );
  }

  // ---- Columns -----------------------------------------------------------

  Widget _buildErrorCard(_RunError err, {required bool fillHeight}) {
    final scheme = Theme.of(context).colorScheme;
    final identity = ProviderRegistry.resolve(
        providerId: err.providerId, providerName: err.providerName);
    final body = SingleChildScrollView(
      child: Text(err.message, style: TextStyle(color: scheme.onErrorContainer)),
    );
    return Card(
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProviderLogo(identity: identity, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(err.modelName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: scheme.onErrorContainer,
                          fontWeight: FontWeight.bold)),
                ),
                Icon(Icons.error_outline, color: scheme.onErrorContainer),
              ],
            ),
            const Divider(),
            fillHeight ? Expanded(child: body) : body,
          ],
        ),
      ),
    );
  }

  Widget _buildOutputCard(PromptExampleOutput output,
      {required bool fillHeight}) {
    final scheme = Theme.of(context).colorScheme;
    final identity = ProviderRegistry.resolve(
        providerId: output.providerId, providerName: output.providerName);
    final accent = output.isBest ? AppDesign.emberPrimary : identity.accent;

    final outputText = SingleChildScrollView(
      controller: _controllerFor(output.id),
      child: SelectableText(output.outputText),
    );
    final textSection = fillHeight
        ? Expanded(child: outputText)
        : ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: outputText,
          );

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: AppDesign.borderLg,
        side: BorderSide(
            color: output.isBest
                ? AppDesign.emberPrimary.withValues(alpha: 0.7)
                : accent.withValues(alpha: 0.4),
            width: output.isBest ? 2 : 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProviderLogo(identity: identity, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${output.providerName}'
                    '${output.modelName != null && output.modelName!.isNotEmpty ? ' (${output.modelName})' : ''}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: accent,
                          fontWeight: output.isBest ? FontWeight.bold : null,
                        ),
                  ),
                ),
                _sourceChip(output.sourceType),
                PopupMenuButton<String>(
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                        value: 'copy', child: Text('Copy Text')),
                    PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete',
                            style: TextStyle(color: scheme.error))),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      showDialog(
                        context: context,
                        builder: (context) => OutputEditorDialog(
                          exampleId: output.exampleId,
                          existingOutput: output,
                        ),
                      );
                    } else if (value == 'copy') {
                      _copyToClipboard(output.outputText, 'Output');
                    } else if (value == 'delete') {
                      _deleteOutput(output.id);
                    }
                  },
                ),
              ],
            ),
            const Divider(),
            // Shared rating control — same widget + DAO as the library card.
            OutputRatingBar(
              output: output,
              promptId: _scopePromptId,
              compact: true,
            ),
            const SizedBox(height: 8),
            textSection,
            if (output.notes != null && output.notes!.isNotEmpty) ...[
              const Divider(),
              Text('Notes:',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text(
                output.notes!,
                maxLines: fillHeight ? 3 : null,
                overflow:
                    fillHeight ? TextOverflow.ellipsis : TextOverflow.clip,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sourceChip(String sourceType) => Chip(
        label: Text(sourceType.toUpperCase()),
        visualDensity: VisualDensity.compact,
      );

  // ---- Build -------------------------------------------------------------

  Widget _inputSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 8,
            children: [
              SizedBox(
                width: 180,
                child: Text('Input Prompt',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              TextButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('Copy Input'),
                onPressed: () =>
                    _copyToClipboard(_example!.compiledPrompt, 'Input prompt'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.2),
            child: SingleChildScrollView(
              child: SelectableText(_example!.compiledPrompt),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heading() => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('LLM Outputs',
              style: Theme.of(context).textTheme.headlineSmall),
        ),
      );

  Widget _emptyState() => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
            child: Text(
                'No outputs yet. Run models or add outputs to compare.')),
      );

  // Failure columns first (most recent run feedback), then saved outputs.
  List<Widget Function(bool)> _items(List<PromptExampleOutput> outputs) => [
        ..._runErrors
            .map((e) => (bool fill) => _buildErrorCard(e, fillHeight: fill)),
        ...outputs
            .map((o) => (bool fill) => _buildOutputCard(o, fillHeight: fill)),
      ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Compare Outputs')),
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Sync scroll'),
              Switch(
                value: _syncScroll,
                onChanged: (v) => setState(() => _syncScroll = v),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<PromptExampleOutput>>(
        stream: _outputs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final outputs = snapshot.data ?? [];
          final empty = outputs.isEmpty && _runErrors.isEmpty;
          final items = _items(outputs);

          return LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 700;

              // Narrow: the whole page scrolls as one, so the run panel can never
              // starve the outputs of height (cards size to content).
              if (narrow) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_example != null) _inputSection(),
                      if (_example != null) _buildExecutionPanel(),
                      _heading(),
                      if (empty)
                        _emptyState()
                      else
                        ...items.map((b) => Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: b(false),
                            )),
                    ],
                  ),
                );
              }

              // Wide: fixed header sections + a comparison grid that fills the
              // remaining height for true side-by-side columns.
              final crossAxisCount = constraints.maxWidth > 800 ? 2 : 1;
              return Column(
                children: [
                  if (_example != null) _inputSection(),
                  if (_example != null) _buildExecutionPanel(),
                  _heading(),
                  Expanded(
                    child: empty
                        ? _emptyState()
                        : GridView.builder(
                            padding: const EdgeInsets.all(16.0),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 16.0,
                              crossAxisSpacing: 16.0,
                              childAspectRatio: crossAxisCount == 1 ? 0.8 : 1.0,
                            ),
                            itemCount: items.length,
                            itemBuilder: (context, index) => items[index](true),
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
