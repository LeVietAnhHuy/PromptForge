import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';
import '../../execution/application/llm_execution_service.dart';
import '../../prompt_examples/presentation/manual_output_paste_dialog.dart';
import '../../execution/domain/llm_provider.dart';
import '../domain/prompt_compiler_service.dart';
import '../domain/target_tool_profile.dart';


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
  TargetToolProfile _selectedProfile = const GenericProfile();

  PromptCompilerResult? _compileResult;
  
  // Execution state
  LlmExecutionProvider? _selectedProvider;
  List<Map<String, String>> _availableModels = [];
  String? _selectedModelId;
  bool _isExecuting = false;
  LlmExecutionResponse? _executionResponse;

  @override
  void initState() {
    super.initState();
    _loadPrompt();
  }

  Future<void> _loadPrompt() async {
    try {
      final promptDao = ref.read(promptDaoProvider);
      final pvDao = ref.read(promptVariableDaoProvider);
      final contextPackDao = ref.read(contextPackDaoProvider);
      
      final prompt = await promptDao.getPromptById(widget.promptId);
      final metadataList = await pvDao.getVariablesForPrompt(widget.promptId);
      final metadataMap = {for (final v in metadataList) v.name: v};
      
      final variables = PromptCompilerService.extractVariables(prompt.body);
      
      for (final variable in variables) {
        final meta = metadataMap[variable];
        _controllers[variable] = TextEditingController(text: meta?.defaultValue ?? '');
        _controllers[variable]!.addListener(_updateCompile);
      }

      final packs = await contextPackDao.getContextPacksForPrompt(widget.promptId);
      final providers = ref.read(executionProvidersProvider);

      // Simple heuristic to auto-select a profile based on targetNotes
      TargetToolProfile initialProfile = const GenericProfile();
      final notes = prompt.targetNotes?.toLowerCase() ?? '';
      if (notes.contains('image')) {
        initialProfile = const FlowImageProfile();
      } else if (notes.contains('video')) {
        initialProfile = const FlowVideoProfile();
      } else if (notes.contains('claude')) {
        initialProfile = const ClaudeProfile();
      } else if (notes.contains('chatgpt') || notes.contains('gpt')) {
        initialProfile = const ChatGPTProfile();
      } else if (notes.contains('gemini')) {
        initialProfile = const GeminiProfile();
      }

      LlmExecutionProvider? initialProvider;
      List<Map<String, String>> initialModels = [];
      String? initialModelId;
      if (providers.isNotEmpty) {
        initialProvider = providers.first;
        initialModels = await initialProvider.listAvailableModels();
        if (initialModels.isNotEmpty) {
          initialModelId = initialModels.first['id'];
        }
      }

      setState(() {
        _prompt = prompt;
        _variables = variables;
        _variableMetadata = metadataMap;
        _contextPacks = packs;
        _selectedProfile = initialProfile;
        _selectedProvider = initialProvider;
        _availableModels = initialModels;
        _selectedModelId = initialModelId;
        _isLoading = false;
      });
      
      _updateCompile();
    } catch (e) {
      setState(() {
        _error = 'Failed to load prompt: $e';
        _isLoading = false;
      });
    }
  }

  void _updateCompile() {
    if (_prompt == null) return;
    
    final values = _controllers.map((key, controller) => MapEntry(key, controller.text));
    
    final result = PromptCompilerService.compile(
      promptBody: _prompt!.body,
      runtimeValues: values,
      variableMetadata: _variableMetadata,
      contextPacks: _contextPacks,
      profile: _selectedProfile,
      outputFormat: _prompt!.outputFormat,
      targetNotes: _prompt!.targetNotes,
    );
    
    setState(() {
      _compileResult = result;
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _executePrompt() async {
    if (_compileResult == null || _prompt == null || _selectedProvider == null || _selectedModelId == null) return;
    
    final missing = _compileResult!.missingRequiredVariables;
    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot execute: Missing required variables.')),
      );
      return;
    }

    setState(() {
      _isExecuting = true;
      _executionResponse = null;
    });

    final modelName = _modelNameFor(_selectedModelId!);

    final service = ref.read(llmExecutionServiceProvider);
    final response = await service.execute(
      compiledPrompt: _compileResult!.compiledText,
      providerId: _selectedProvider!.providerId,
      modelId: _selectedModelId!,
      modelName: modelName,
      targetProfileId: _selectedProfile.id,
    );

    if (mounted) {
      setState(() {
        _isExecuting = false;
        _executionResponse = response;
      });

      if (response.error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Execution failed: ${response.error}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } else {
        // Save output
        final dao = ref.read(promptExampleDaoProvider);
        final exampleId = const Uuid().v4();
        final now = DateTime.now();
        
        final varsMap = _controllers.map((k, v) => MapEntry(k, v.text));
        final jsonStr = jsonEncode(varsMap);

        // Save a new Run with the output
        await dao.createExample(PromptExamplesCompanion.insert(
          id: exampleId,
          promptId: drift.Value(_prompt!.id),
          title: 'Run: $modelName',
          compiledPrompt: _compileResult!.compiledText,
          variableValuesJson: drift.Value(jsonStr),
          createdAt: now,
          updatedAt: now,
        ));

        await service.saveResponseAsOutput(
          exampleId: exampleId,
          response: response,
          outputType: 'markdown',
          sourceType: 'api',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Execution successful. Output saved to history.')),
          );
        }
      }
    }
  }

  String _modelNameFor(String modelId) {
    for (final model in _availableModels) {
      if (model['id'] == modelId) {
        return model['name'] ?? modelId;
      }
    }
    return modelId;
  }

  Widget _buildExecutionPanel() {
    final providers = ref.watch(executionProvidersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Execute',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 700;
            final providerField = _buildProviderDropdown(providers);
            final modelField = _buildModelDropdown();
            final runButton = ElevatedButton.icon(
              onPressed: _isExecuting || _compileResult == null ? null : _executePrompt,
              icon: _isExecuting 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                : const Icon(Icons.play_arrow),
              label: const Text('Run'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            );
            final pasteButton = OutlinedButton.icon(
              onPressed: _compileResult == null ? null : () async {
                FocusScope.of(context).unfocus();
                await showDialog<bool>(
                  context: context,
                  builder: (context) => ManualOutputPasteDialog(
                    promptId: _prompt!.id,
                    compiledPromptSnapshot: _compileResult!.compiledText,
                  ),
                );
              },
              icon: const Icon(Icons.paste),
              label: const Text('Paste Output'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            );

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  providerField,
                  const SizedBox(height: 12),
                  modelField,
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [runButton, pasteButton],
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: providerField),
                const SizedBox(width: 8),
                Expanded(child: modelField),
                const SizedBox(width: 16),
                runButton,
                const SizedBox(width: 8),
                pasteButton,
              ],
            );
          },
        ),
        if (_executionResponse != null && _executionResponse!.error == null) ...[
          const SizedBox(height: 16),
          Text('Output', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 120),
              child: SingleChildScrollView(
                child: SelectableText(_executionResponse!.outputText),
              ),
            ),
          ),
        ],
      ],
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
        items: providers.map((p) {
          return DropdownMenuItem(value: p, child: Text(p.providerName));
        }).toList(),
        onChanged: _isExecuting ? null : (provider) async {
          if (provider != null) {
            final models = await provider.listAvailableModels();
            setState(() {
              _selectedProvider = provider;
              _availableModels = models;
              _selectedModelId = models.isNotEmpty ? models.first['id'] : null;
            });
          }
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
        items: _availableModels.map((m) {
          return DropdownMenuItem(value: m['id'], child: Text(m['name'] ?? m['id']!));
        }).toList(),
        onChanged: _isExecuting ? null : (modelId) {
          setState(() {
            _selectedModelId = modelId;
          });
        },
      ),
    );
  }

  Future<void> _copyToClipboard() async {
    if (_compileResult == null || _prompt == null) return;
    
    final missing = _compileResult!.missingRequiredVariables;
    if (missing.isNotEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Missing Required Variables'),
          content: Text('The following variables are missing:\n\n${missing.join(', ')}\n\nCopy anyway?'),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => context.pop(true),
              child: const Text('Copy Anyway'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    await Clipboard.setData(ClipboardData(text: _compileResult!.compiledText));
    
    // Update usage stats safely
    try {
      final promptDao = ref.read(promptDaoProvider);
      await promptDao.incrementUsage(_prompt!.id);
    } catch (e) {
      debugPrint('Failed to update usage count: $e');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prompt copied to clipboard!')),
      );
    }
  }

  Widget _buildVariablesPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_contextPacks.isNotEmpty) ...[
          Text(
            'Attached Context Packs (${_contextPacks.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ..._contextPacks.map((p) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.inventory_2, size: 20),
            title: Text(p.name),
            dense: true,
          )),
          const SizedBox(height: 24),
        ],
        
        Text(
          'Target Tool Profile',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(4.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: DropdownButton<TargetToolProfile>(
            value: _selectedProfile,
            isExpanded: true,
            underline: const SizedBox(),
            items: TargetToolProfile.builtIns.map((profile) {
              return DropdownMenuItem<TargetToolProfile>(
                value: profile,
                child: Text(profile.name),
              );
            }).toList(),
            onChanged: (profile) {
              if (profile != null) {
                setState(() {
                  _selectedProfile = profile;
                });
                _updateCompile();
              }
            },
          ),
        ),
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
                      helperText: description ?? 'Replace {$variable}',
                      hintText: example,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPreviewPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Preview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (_compileResult != null)
              Text(
                '${_compileResult!.characterCount} chars',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            ElevatedButton.icon(
              onPressed: _copyToClipboard,
              icon: const Icon(Icons.copy),
              label: const Text('Copy Output'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final title = await showDialog<String>(
                  context: context,
                  builder: (dialogContext) {
                    final controller = TextEditingController(text: 'Example for ${_prompt!.title}');
                    return AlertDialog(
                      title: const Text('Save Example'),
                      content: TextField(
                        controller: controller,
                        decoration: const InputDecoration(labelText: 'Title'),
                        autofocus: true,
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
                        ElevatedButton(onPressed: () => Navigator.of(dialogContext).pop(controller.text), child: const Text('Save')),
                      ],
                    );
                  }
                );
                
                if (title != null && title.isNotEmpty && context.mounted) {
                  final dao = ref.read(promptExampleDaoProvider);
                  final exampleId = const Uuid().v4();
                  final now = DateTime.now();
                  
                  final varsMap = _controllers.map((k, v) => MapEntry(k, v.text));
                  final jsonStr = jsonEncode(varsMap);

                  await dao.createExample(PromptExamplesCompanion.insert(
                    id: exampleId,
                    promptId: drift.Value(_prompt!.id),
                    title: title,
                    compiledPrompt: _compileResult!.compiledText,
                    variableValuesJson: drift.Value(jsonStr),
                    createdAt: now,
                    updatedAt: now,
                  ));
                  
                  if (mounted) {
                    context.push('/library/examples/${_prompt!.id}/compare/$exampleId');
                  }
                }
              },
              icon: const Icon(Icons.compare_arrows),
              label: const Text('Compare Outputs'),
            ),
          ],
        ),
        if (_compileResult != null && _compileResult!.missingRequiredVariables.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Missing required variables: ${_compileResult!.missingRequiredVariables.join(', ')}',
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
                _compileResult?.compiledText ?? '',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ),
      ],
    );
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

    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('Compile: ${_prompt!.title}'),
      ),
      body: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                    ),
                    child: _buildVariablesPanel(),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxHeight < 700) {
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 280,
                                  child: _buildPreviewPanel(),
                                ),
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 16),
                                _buildExecutionPanel(),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: [
                            Expanded(child: _buildPreviewPanel()),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                            _buildExecutionPanel(),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    padding: const EdgeInsets.all(16.0),
                    child: _buildVariablesPanel(),
                  ),
                  const Divider(),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    padding: const EdgeInsets.all(16.0),
                    child: _buildPreviewPanel(),
                  ),
                  const Divider(),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildExecutionPanel(),
                  ),
                ],
              ),
            ),
    );
  }
}
