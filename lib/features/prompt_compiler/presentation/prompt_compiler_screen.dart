import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  void initState() {
    super.initState();
    _loadPrompt();
  }

  Future<void> _loadPrompt() async {
    try {
      final promptDao = ref.read(promptDaoProvider);
      final prompt = await promptDao.getPromptById(widget.promptId);
      
      final variables = PromptCompiler.extractVariables(prompt.body);
      
      for (final variable in variables) {
        _controllers[variable] = TextEditingController();
        _controllers[variable]!.addListener(() {
          setState(() {}); // Trigger rebuild to update preview
        });
      }

      setState(() {
        _prompt = prompt;
        _variables = variables;
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
    return PromptCompiler.compilePrompt(_prompt!.body, values);
  }

  bool get _isMissingVariables {
    for (final controller in _controllers.values) {
      if (controller.text.trim().isEmpty) {
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
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: TextField(
                              controller: _controllers[variable],
                              decoration: InputDecoration(
                                labelText: variable,
                                border: const OutlineInputBorder(),
                                helperText: 'Replace {{ $variable }}',
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
                      ElevatedButton.icon(
                        onPressed: _isMissingVariables ? null : _copyToClipboard,
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy Output'),
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
