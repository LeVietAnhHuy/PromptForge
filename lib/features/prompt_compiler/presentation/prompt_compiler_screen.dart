import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';
import '../domain/prompt_compiler.dart';

class PromptCompilerScreen extends ConsumerStatefulWidget {
  final String promptId;

  const PromptCompilerScreen({super.key, required this.promptId});

  @override
  ConsumerState<PromptCompilerScreen> createState() => _PromptCompilerScreenState();
}

class _PromptCompilerScreenState extends ConsumerState<PromptCompilerScreen> {
  Prompt? _prompt;
  bool _isLoading = true;
  String? _error;

  List<String> _variables = [];
  final Map<String, TextEditingController> _controllers = {};
  Map<String, PromptVariable> _variableMetadata = {};
  List<ContextPack> _contextPacks = [];
  String? _selectedContextPackId;

  @override
  void initState() {
    super.initState();
    _loadPrompt();
  }

  Future<void> _loadPrompt() async {
    try {
      final promptDao = ref.read(promptDaoProvider);
      final pvDao = ref.read(promptVariableDaoProvider);
      
      final prompt = await promptDao.getPromptById(widget.promptId);
      final metadataList = await pvDao.getVariablesForPrompt(widget.promptId);
      final metadataMap = {for (final v in metadataList) v.name: v};
      
      final variables = PromptCompiler.extractVariables(prompt.body);
      
      for (final variable in variables) {
        final meta = metadataMap[variable];
        _controllers[variable] = TextEditingController(text: meta?.defaultValue ?? '');
        _controllers[variable]!.addListener(() {
          setState(() {}); // Trigger rebuild to update preview
        });
      }

      final contextPackDao = ref.read(contextPackDaoProvider);
      final packs = await contextPackDao.getAllContextPacks();

      setState(() {
        _prompt = prompt;
        _variables = variables;
        _variableMetadata = metadataMap;
        _contextPacks = packs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load prompt: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String get _compiledPrompt {
    if (_prompt == null) return '';
    final values = _controllers.map((key, controller) => MapEntry(key, controller.text));
    final compiled = PromptCompiler.compilePrompt(_prompt!.body, values);
    
    if (_selectedContextPackId != null) {
      final pack = _contextPacks.firstWhere((p) => p.id == _selectedContextPackId, orElse: () => _contextPacks.first);
      return '[Context]\n${pack.content}\n\n[Prompt]\n$compiled';
    }
    
    return compiled;
  }

  bool get _isMissingVariables {
    for (final variable in _variables) {
      final controller = _controllers[variable]!;
      final meta = _variableMetadata[variable];
      final isRequired = meta?.isRequired ?? true;
      if (isRequired && controller.text.trim().isEmpty) {
        return true;
      }
    }
    return false;
  }

  Future<void> _copyToClipboard() async {
    final compiled = _compiledPrompt;
    await Clipboard.setData(ClipboardData(text: compiled));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prompt copied to clipboard!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _prompt == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Compile Prompt')),
        body: Center(child: Text(_error ?? 'Prompt not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Compile: ${_prompt!.title}'),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Variables Input
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Context Pack',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: DropdownButton<String?>(
                      value: _selectedContextPackId,
                      isExpanded: true,
                      underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('No context pack'),
                      ),
                      ..._contextPacks.map((pack) => DropdownMenuItem(
                            value: pack.id,
                            child: Text(pack.name),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedContextPackId = value;
                      });
                    },
                  ),
                  ), // Closing Container
                  const SizedBox(height: 24),
                  Text(
                    'Variables',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  if (_variables.isEmpty)
                    const Text('No variables detected in this prompt.')
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _variables.length,
                        itemBuilder: (context, index) {
                          final variable = _variables[index];
                          final meta = _variableMetadata[variable];
                          final isRequired = meta?.isRequired ?? true;
                          final label = meta?.label ?? variable;
                          final description = meta?.description;
                          final example = meta?.exampleValue;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: TextField(
                              controller: _controllers[variable],
                              decoration: InputDecoration(
                                label: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(text: label),
                                      if (isRequired)
                                        const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
                                      if (!isRequired)
                                        const TextSpan(text: ' (Optional)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                border: const OutlineInputBorder(),
                                helperText: description ?? 'Replace {{ $variable }}',
                                hintText: example,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Right side: Preview
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Preview',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Expanded(
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isMissingVariables ? null : _copyToClipboard,
                              icon: const Icon(Icons.copy),
                              label: const Text('Copy Output'),
                            ),
                            ElevatedButton.icon(
                        onPressed: _isMissingVariables ? null : () async {
                          final title = await showDialog<String>(
                            context: context,
                            builder: (context) {
                              final controller = TextEditingController(text: 'Example for ${_prompt!.title}');
                              return AlertDialog(
                                title: const Text('Save Example'),
                                content: TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(labelText: 'Title'),
                                  autofocus: true,
                                ),
                                actions: [
                                  TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
                                  ElevatedButton(onPressed: () => context.pop(controller.text), child: const Text('Save')),
                                ],
                              );
                            }
                          );
                          
                          if (title != null && title.isNotEmpty && context.mounted) {
                            final dao = ref.read(promptExampleDaoProvider);
                            final exampleId = const Uuid().v4();
                            final now = DateTime.now();
                            
                            // Get current variable values as JSON
                            final varsMap = _controllers.map((k, v) => MapEntry(k, v.text));
                            final jsonStr = jsonEncode(varsMap);

                            await dao.createExample(PromptExamplesCompanion.insert(
                              id: exampleId,
                              promptId: _prompt!.id,
                              title: title,
                              compiledPrompt: _compiledPrompt,
                              contextPackId: _selectedContextPackId != null ? drift.Value(_selectedContextPackId!) : const drift.Value.absent(),
                              variableValuesJson: drift.Value(jsonStr),
                              createdAt: now,
                              updatedAt: now,
                            ));
                            
                            if (context.mounted) {
                              context.push('/library/examples/${_prompt!.id}/compare/$exampleId');
                            }
                          }
                        },
                        icon: const Icon(Icons.compare_arrows),
                        label: const Text('Compare Outputs'),
                      ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_isMissingVariables && _variables.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Fill all variables to enable copying.',
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          _compiledPrompt,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
