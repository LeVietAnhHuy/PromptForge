import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';
import '../../execution/application/llm_execution_service.dart';
import '../../execution/domain/llm_provider.dart';
import 'output_editor_dialog.dart';

class ExampleComparisonScreen extends ConsumerStatefulWidget {
  final String exampleId;

  const ExampleComparisonScreen({super.key, required this.exampleId});

  @override
  ConsumerState<ExampleComparisonScreen> createState() => _ExampleComparisonScreenState();
}

class _ExampleComparisonScreenState extends ConsumerState<ExampleComparisonScreen> {
  PromptExample? _example;
  bool _isLoading = true;
  String? _error;
  LlmExecutionProvider? _selectedProvider;
  List<Map<String, String>> _availableModels = [];
  String? _selectedModelId;
  bool _isExecuting = false;

  @override
  void initState() {
    super.initState();
    _loadExample();
  }

  Future<void> _loadExample() async {
    try {
      final dao = ref.read(promptExampleDaoProvider);
      final example = await dao.getExampleById(widget.exampleId);
      final providers = ref.read(executionProvidersProvider);
      LlmExecutionProvider? initialProvider;
      List<Map<String, String>> initialModels = [];
      String? initialModelId;
      if (providers.isNotEmpty) {
        initialProvider = providers.first;
        initialModels = await initialProvider.listAvailableModels();
        initialModelId = initialModels.isNotEmpty ? initialModels.first['id'] : null;
      }
      setState(() {
        _example = example;
        _selectedProvider = initialProvider;
        _availableModels = initialModels;
        _selectedModelId = initialModelId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load example: $e';
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied to clipboard')),
    );
  }

  Future<void> _deleteOutput(String id) async {
    final dao = ref.read(promptExampleOutputDaoProvider);
    await dao.deleteOutput(id);
  }

  Future<void> _markAsBest(String id) async {
    final dao = ref.read(promptExampleOutputDaoProvider);
    await dao.markOutputAsBest(widget.exampleId, id);
  }

  String _modelNameFor(String modelId) {
    for (final model in _availableModels) {
      if (model['id'] == modelId) {
        return model['name'] ?? modelId;
      }
    }
    return modelId;
  }

  Future<void> _runSelectedModel() async {
    if (_example == null || _selectedProvider == null || _selectedModelId == null) {
      return;
    }

    setState(() => _isExecuting = true);
    final service = ref.read(llmExecutionServiceProvider);
    final result = await service.executeAndSaveOutput(
      exampleId: widget.exampleId,
      compiledPrompt: _example!.compiledPrompt,
      providerId: _selectedProvider!.providerId,
      modelId: _selectedModelId!,
      modelName: _modelNameFor(_selectedModelId!),
      targetProfileId: 'comparison',
      outputType: 'markdown',
      sourceType: 'api',
    );

    if (!mounted) return;
    setState(() => _isExecuting = false);

    if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.error} Use Add Output for manual fallback.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API output saved.')),
    );
  }

  void _showManualOutputDialog() {
    showDialog(
      context: context,
      builder: (context) => OutputEditorDialog(exampleId: widget.exampleId),
    );
  }

  Widget _buildExecutionPanel() {
    final providers = ref.watch(executionProvidersProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 700;
          final providerField = _buildProviderDropdown(providers);
          final modelField = _buildModelDropdown();
          final runButton = ElevatedButton.icon(
            onPressed: _isExecuting ? null : _runSelectedModel,
            icon: _isExecuting
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.play_arrow),
            label: const Text('Run'),
          );
          final manualButton = OutlinedButton.icon(
            onPressed: _showManualOutputDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Output'),
          );

          final title = Text('Run LLM Output', style: Theme.of(context).textTheme.titleMedium);
          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                title,
                const SizedBox(height: 12),
                providerField,
                const SizedBox(height: 12),
                modelField,
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [runButton, manualButton]),
              ],
            );
          }

          return Row(
            children: [
              title,
              const SizedBox(width: 16),
              Expanded(child: providerField),
              const SizedBox(width: 8),
              Expanded(child: modelField),
              const SizedBox(width: 16),
              runButton,
              const SizedBox(width: 8),
              manualButton,
            ],
          );
        },
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
          return DropdownMenuItem(value: provider, child: Text(provider.providerName));
        }).toList(),
        onChanged: _isExecuting ? null : (provider) async {
          if (provider == null) return;
          final models = await provider.listAvailableModels();
          if (!mounted) return;
          setState(() {
            _selectedProvider = provider;
            _availableModels = models;
            _selectedModelId = models.isNotEmpty ? models.first['id'] : null;
          });
        },
      ),
    );
  }

  Widget _buildModelDropdown() {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Model',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: DropdownButton<String>(
        value: _selectedModelId,
        isExpanded: true,
        underline: const SizedBox(),
        items: _availableModels.map((model) {
          final id = model['id']!;
          return DropdownMenuItem(value: id, child: Text(model['name'] ?? id));
        }).toList(),
        onChanged: _isExecuting ? null : (modelId) => setState(() => _selectedModelId = modelId),
      ),
    );
  }

  Widget _buildOutputCard(PromptExampleOutput output, {required bool fillHeight}) {
    final outputText = SingleChildScrollView(
      child: SelectableText(output.outputText),
    );

    final textSection = fillHeight
        ? Expanded(child: outputText)
        : ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: outputText,
          );

    return Card(
      color: output.isBest ? Theme.of(context).colorScheme.primaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (output.isBest) const Icon(Icons.star, color: Colors.amber),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: fillHeight ? 220 : 520),
                  child: Text(
                    '${output.providerName}${output.modelName != null && output.modelName!.isNotEmpty ? ' (${output.modelName})' : ''}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: output.isBest ? FontWeight.bold : null,
                    ),
                  ),
                ),
                Chip(
                  label: Text(output.sourceType.toUpperCase()),
                  visualDensity: VisualDensity.compact,
                ),
                if (output.score != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (starIndex) {
                      return Icon(
                        starIndex < output.score! ? Icons.star : Icons.star_border,
                        size: 16,
                        color: Colors.amber,
                      );
                    }),
                  ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    if (!output.isBest)
                      const PopupMenuItem(
                        value: 'best',
                        child: Text('Mark as Best'),
                      ),
                    const PopupMenuItem(
                      value: 'copy',
                      child: Text('Copy Text'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      showDialog(
                        context: context,
                        builder: (context) => OutputEditorDialog(
                          exampleId: widget.exampleId,
                          existingOutput: output,
                        ),
                      );
                    } else if (value == 'best') {
                      _markAsBest(output.id);
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
            textSection,
            if (output.notes != null && output.notes!.isNotEmpty) ...[
              const Divider(),
              Text('Notes:', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
              Text(
                output.notes!,
                maxLines: fillHeight ? 3 : null,
                overflow: fillHeight ? TextOverflow.ellipsis : TextOverflow.clip,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _example == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Compare Outputs')),
        body: Center(child: Text(_error ?? 'Example not found')),
      );
    }

    final outputsStream = ref.watch(promptExampleOutputDaoProvider).watchOutputsForExample(widget.exampleId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Compare: ${_example!.title}'),
      ),
      body: Column(
        children: [
          // Top section: Compiled prompt
          Container(
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
                      child: Text('Input Prompt', style: Theme.of(context).textTheme.titleMedium),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Input'),
                      onPressed: () => _copyToClipboard(_example!.compiledPrompt, 'Input prompt'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.25),
                  child: SingleChildScrollView(
                    child: SelectableText(_example!.compiledPrompt),
                  ),
                ),
              ],
            ),
          ),
          _buildExecutionPanel(),
          // Middle section: Outputs heading
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('LLM Outputs', style: Theme.of(context).textTheme.headlineSmall),
            ),
          ),
          // Bottom section: Output comparison area
          Expanded(
            child: StreamBuilder(
              stream: outputsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final outputs = snapshot.data ?? [];
                if (outputs.isEmpty) {
                  return const Center(child: Text('No outputs added yet. Paste some LLM outputs to compare them.'));
                }

                final screenWidth = MediaQuery.of(context).size.width;
                if (screenWidth < 700) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: outputs.length,
                    itemBuilder: (context, index) {
                      return _buildOutputCard(outputs[index], fillHeight: false);
                    },
                  );
                }

                // Determine crossAxisCount based on screen width
                final crossAxisCount = screenWidth > 800 ? 2 : 1;

                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 16.0,
                    childAspectRatio: crossAxisCount == 1 ? 0.8 : 1.0,
                  ),
                  itemCount: outputs.length,
                  itemBuilder: (context, index) {
                    return _buildOutputCard(outputs[index], fillHeight: true);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
