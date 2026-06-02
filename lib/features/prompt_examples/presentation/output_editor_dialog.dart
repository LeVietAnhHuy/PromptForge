import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';

class OutputEditorDialog extends ConsumerStatefulWidget {
  final String exampleId;
  final PromptExampleOutput? existingOutput;

  const OutputEditorDialog({
    super.key,
    required this.exampleId,
    this.existingOutput,
  });

  @override
  ConsumerState<OutputEditorDialog> createState() => _OutputEditorDialogState();
}

class _OutputEditorDialogState extends ConsumerState<OutputEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _providerController = TextEditingController();
  final _modelController = TextEditingController();
  final _outputController = TextEditingController();
  final _notesController = TextEditingController();
  int? _score;

  @override
  void initState() {
    super.initState();
    if (widget.existingOutput != null) {
      _providerController.text = widget.existingOutput!.providerName;
      _modelController.text = widget.existingOutput!.modelName ?? '';
      _outputController.text = widget.existingOutput!.outputText;
      _notesController.text = widget.existingOutput!.notes ?? '';
      _score = widget.existingOutput!.score;
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

    final dao = ref.read(promptExampleOutputDaoProvider);
    final now = DateTime.now();

    try {
      if (widget.existingOutput == null) {
        // Create
        await dao.addOutput(PromptExampleOutputsCompanion.insert(
          id: const Uuid().v4(),
          exampleId: widget.exampleId,
          providerName: _providerController.text,
          modelName: _modelController.text.isNotEmpty ? drift.Value(_modelController.text) : const drift.Value.absent(),
          outputText: _outputController.text,
          score: _score != null ? drift.Value(_score) : const drift.Value.absent(),
          notes: _notesController.text.isNotEmpty ? drift.Value(_notesController.text) : const drift.Value.absent(),
          createdAt: now,
          updatedAt: now,
        ));
      } else {
        // Update
        await dao.updateOutput(PromptExampleOutputsCompanion.insert(
          id: widget.existingOutput!.id,
          exampleId: widget.exampleId,
          providerName: _providerController.text,
          modelName: _modelController.text.isNotEmpty ? drift.Value(_modelController.text) : const drift.Value.absent(),
          outputText: _outputController.text,
          score: _score != null ? drift.Value(_score) : const drift.Value.absent(),
          notes: _notesController.text.isNotEmpty ? drift.Value(_notesController.text) : const drift.Value.absent(),
          createdAt: widget.existingOutput!.createdAt,
          updatedAt: now,
        ));
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving output: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingOutput == null ? 'Add LLM Output' : 'Edit Output'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  const options = ['ChatGPT', 'Claude', 'Gemini', 'Grok', 'Perplexity', 'Local Model'];
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return options.where((option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                },
                onSelected: (String selection) {
                  _providerController.text = selection;
                },
                fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                  // Link internal controller with autocomplete if needed
                  if (_providerController.text.isEmpty && textEditingController.text.isEmpty) {
                     // init
                  } else if (textEditingController.text.isEmpty && _providerController.text.isNotEmpty) {
                    textEditingController.text = _providerController.text;
                  }
                  textEditingController.addListener(() {
                    _providerController.text = textEditingController.text;
                  });

                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Provider (e.g. ChatGPT)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Model Name (Optional)',
                  hintText: 'e.g. GPT-4o, Claude 3.5 Sonnet',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _outputController,
                decoration: const InputDecoration(
                  labelText: 'Output Text',
                  border: OutlineInputBorder(),
                ),
                maxLines: 10,
                validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int?>(
                initialValue: _score,
                decoration: const InputDecoration(
                  labelText: 'Score (1-5 Stars)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('No Score')),
                  ...List.generate(5, (index) => DropdownMenuItem(value: index + 1, child: Text('${index + 1} Star${index == 0 ? '' : 's'}')))
                ],
                onChanged: (val) => setState(() => _score = val),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
