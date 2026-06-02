import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';
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

  @override
  void initState() {
    super.initState();
    _loadExample();
  }

  Future<void> _loadExample() async {
    try {
      final dao = ref.read(promptExampleDaoProvider);
      final example = await dao.getExampleById(widget.exampleId);
      setState(() {
        _example = example;
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Input Prompt', style: Theme.of(context).textTheme.titleMedium),
                    TextButton.icon(
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Input'),
                      onPressed: () => _copyToClipboard(_example!.compiledPrompt, 'Input prompt'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SelectableText(_example!.compiledPrompt),
              ],
            ),
          ),
          // Middle section: Add output button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text('LLM Outputs', style: Theme.of(context).textTheme.headlineSmall),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => OutputEditorDialog(exampleId: widget.exampleId),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Output'),
                ),
              ],
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

                // Determine crossAxisCount based on screen width
                final screenWidth = MediaQuery.of(context).size.width;
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
                    final output = outputs[index];
                    return Card(
                      color: output.isBest ? Theme.of(context).colorScheme.primaryContainer : null,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (output.isBest)
                                  const Icon(Icons.star, color: Colors.amber),
                                if (output.isBest)
                                  const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${output.providerName}${output.modelName != null && output.modelName!.isNotEmpty ? ' (${output.modelName})' : ''}',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: output.isBest ? FontWeight.bold : null,
                                    ),
                                  ),
                                ),
                                if (output.score != null)
                                  Row(
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
                            Expanded(
                              child: SingleChildScrollView(
                                child: SelectableText(output.outputText),
                              ),
                            ),
                            if (output.notes != null && output.notes!.isNotEmpty) ...[
                              const Divider(),
                              Text('Notes:', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                              Text(output.notes!, style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ],
                        ),
                      ),
                    );
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
