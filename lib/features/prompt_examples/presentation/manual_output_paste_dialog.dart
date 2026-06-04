import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';

class ManualOutputPasteDialog extends ConsumerStatefulWidget {
  final String promptId;
  final String compiledPromptSnapshot;

  const ManualOutputPasteDialog({
    super.key,
    required this.promptId,
    required this.compiledPromptSnapshot,
  });

  @override
  ConsumerState<ManualOutputPasteDialog> createState() => _ManualOutputPasteDialogState();
}

class _ManualOutputPasteDialogState extends ConsumerState<ManualOutputPasteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _providerController = TextEditingController();
  final _modelController = TextEditingController();
  final _outputController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _outputType = 'markdown';
  List<LLMProvider> _providers = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    final providerDao = ref.read(lLMProviderDaoProvider);
    final providers = await providerDao.getAllProviders();
    if (mounted) {
      setState(() {
        _providers = providers;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _providerController.dispose();
    _modelController.dispose();
    _outputController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final exampleDao = ref.read(promptExampleDaoProvider);
      final outputDao = ref.read(promptExampleOutputDaoProvider);
      
      final exampleId = const Uuid().v4();
      final outputId = const Uuid().v4();

      // Create a PromptExample to represent this manual paste run
      await exampleDao.createExample(PromptExamplesCompanion.insert(
        id: exampleId,
        promptId: drift.Value(widget.promptId),
        title: 'Manual Output',
        compiledPrompt: widget.compiledPromptSnapshot,
        notes: const drift.Value('Manual output capture'),
        createdAt: now,
        updatedAt: now,
      ));

      // Find if we have a matching provider ID
      String? matchedProviderId;
      for (final p in _providers) {
        if (p.name.toLowerCase() == _providerController.text.toLowerCase()) {
          matchedProviderId = p.id;
          break;
        }
      }

      // Create the output attached to the example
      await outputDao.addOutput(PromptExampleOutputsCompanion.insert(
        id: outputId,
        exampleId: exampleId,
        providerId: matchedProviderId != null ? drift.Value(matchedProviderId) : const drift.Value.absent(),
        providerName: _providerController.text,
        modelName: _modelController.text.isNotEmpty ? drift.Value(_modelController.text) : const drift.Value.absent(),
        outputType: drift.Value(_outputType),
        outputText: _outputController.text,
        notes: _notesController.text.isNotEmpty ? drift.Value(_notesController.text) : const drift.Value.absent(),
        createdAt: now,
        updatedAt: now,
      ));

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Output saved manually.')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving output: $e'), backgroundColor: Theme.of(context).colorScheme.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AlertDialog(content: SizedBox(height: 100, child: Center(child: CircularProgressIndicator())));
    }

    final isDesktop = MediaQuery.of(context).size.width > 600;

    return AlertDialog(
      title: const Text('Paste External LLM Output'),
      content: SizedBox(
        width: isDesktop ? 600 : double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          final options = _providers.map((p) => p.name).toList();
                          options.addAll(['ChatGPT', 'Claude', 'Gemini', 'Codex', 'Cursor', 'NotebookLM', 'Flow', 'Local Model', 'Other']);
                          final uniqueOptions = options.toSet().toList();
                          
                          if (textEditingValue.text.isEmpty) {
                            return uniqueOptions;
                          }
                          return uniqueOptions.where((option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (String selection) {
                          _providerController.text = selection;
                        },
                        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                          if (textEditingController.text.isEmpty && _providerController.text.isNotEmpty) {
                            textEditingController.text = _providerController.text;
                          }
                          textEditingController.addListener(() {
                            _providerController.text = textEditingController.text;
                          });

                          return TextFormField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Provider (e.g. Claude)',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _modelController,
                        decoration: const InputDecoration(
                          labelText: 'Model (Optional)',
                          hintText: 'e.g. GPT-4o, Sonnet 3.5',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _outputType,
                  decoration: const InputDecoration(
                    labelText: 'Output Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'markdown', child: Text('Markdown')),
                    DropdownMenuItem(value: 'text', child: Text('Plain Text')),
                    DropdownMenuItem(value: 'code', child: Text('Code')),
                    DropdownMenuItem(value: 'json', child: Text('JSON')),
                    DropdownMenuItem(value: 'analysis', child: Text('Analysis')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _outputType = val);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _outputController,
                  decoration: const InputDecoration(
                    labelText: 'Pasted Output',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 12,
                  minLines: 5,
                  validator: (value) => value == null || value.trim().isEmpty ? 'Please paste the output text' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'e.g. temperature, prompt variant, manual context',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isSaving ? null : _save,
          icon: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save),
          label: const Text('Save Output'),
        ),
      ],
    );
  }
}
