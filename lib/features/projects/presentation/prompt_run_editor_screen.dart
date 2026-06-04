import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:drift/drift.dart' as drift;

import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';
import '../../execution/application/llm_execution_service.dart';
import '../../execution/domain/llm_provider.dart';
import '../../prompt_examples/presentation/output_editor_dialog.dart';
import 'prompt_card_conversion_dialog.dart';

class PromptRunEditorScreen extends ConsumerStatefulWidget {
  final String projectId;
  final String? runId;

  const PromptRunEditorScreen({
    super.key,
    required this.projectId,
    this.runId,
  });

  @override
  ConsumerState<PromptRunEditorScreen> createState() => _PromptRunEditorScreenState();
}

class _PromptRunEditorScreenState extends ConsumerState<PromptRunEditorScreen> {
  final _titleController = TextEditingController();
  final _inputController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isPreviewMode = false;
  bool _isLoading = true;
  String? _error;
  
  PromptExample? _run;
  List<PromptExampleOutput> _outputs = [];
  List<LLMProvider> _providers = [];
  StreamSubscription<List<PromptExampleOutput>>? _outputsSubscription;
  LlmExecutionProvider? _selectedExecutionProvider;
  List<Map<String, String>> _availableExecutionModels = [];
  String? _selectedExecutionModelId;
  bool _isExecuting = false;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    try {
      final providerDao = ref.read(lLMProviderDaoProvider);
      _providers = await providerDao.getAllProviders();
      final executionProviders = ref.read(executionProvidersProvider);
      if (executionProviders.isNotEmpty) {
        _selectedExecutionProvider = executionProviders.first;
        _availableExecutionModels = await _selectedExecutionProvider!.listAvailableModels();
        _selectedExecutionModelId = _availableExecutionModels.isNotEmpty
            ? _availableExecutionModels.first['id']
            : null;
      }

      if (widget.runId != null) {
        final exampleDao = ref.read(promptExampleDaoProvider);
        final run = await exampleDao.getExampleById(widget.runId!);
        _run = run;
        _titleController.text = run.title;
        _inputController.text = run.compiledPrompt;
        _notesController.text = run.refinementNote ?? '';
        
        final outputDao = ref.read(promptExampleOutputDaoProvider);
        final outputsStream = outputDao.watchOutputsForExample(run.id);
        _outputsSubscription = outputsStream.listen((data) {
          if (mounted) {
            setState(() {
              _outputs = data;
            });
          }
        });
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _extractTitle() {
    if (_titleController.text.isNotEmpty) return;
    
    final lines = _inputController.text.split('\n');
    for (final line in lines) {
      if (line.startsWith('# ')) {
        _titleController.text = line.substring(2).trim();
        return;
      }
    }
  }

  Future<String?> _saveRun({bool showSnackBar = true}) async {
    final dao = ref.read(promptExampleDaoProvider);
    final now = DateTime.now();
    _extractTitle();

    if (_run == null) {
      final newId = const Uuid().v4();
      await dao.createExample(PromptExamplesCompanion.insert(
        id: newId,
        projectId: drift.Value(widget.projectId),
        title: _titleController.text.isEmpty ? 'Untitled Run' : _titleController.text,
        compiledPrompt: _inputController.text,
        refinementNote: drift.Value(_notesController.text.isEmpty ? null : _notesController.text),
        createdAt: now,
        updatedAt: now,
      ));
      if (mounted) {
        context.go('/projects/${widget.projectId}/runs/$newId');
      }
      return newId;
    } else {
      await dao.updateExample(PromptExamplesCompanion(
        id: drift.Value(_run!.id),
        projectId: drift.Value(_run!.projectId),
        promptId: drift.Value(_run!.promptId),
        title: drift.Value(_titleController.text.isEmpty ? 'Untitled Run' : _titleController.text),
        compiledPrompt: drift.Value(_inputController.text),
        contextPackId: drift.Value(_run!.contextPackId),
        variableValuesJson: drift.Value(_run!.variableValuesJson),
        notes: drift.Value(_run!.notes),
        refinementNote: drift.Value(_notesController.text.isEmpty ? null : _notesController.text),
        createdAt: drift.Value(_run!.createdAt),
        updatedAt: drift.Value(now),
        isArchived: drift.Value(_run!.isArchived),
      ));
      final updatedRun = await dao.getExampleById(_run!.id);
      if (mounted) {
        setState(() {
          _run = updatedRun;
        });
        if (showSnackBar) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved!')));
        }
      }
      return _run!.id;
    }
  }

  Future<void> _save() async {
    await _saveRun();
  }
  
  Color _getProviderColor(String? providerId) {
    if (providerId == null) return Colors.grey;
    if (_providers.isEmpty) return Colors.grey;
    final p = _providers.firstWhere((p) => p.id == providerId, orElse: () => _providers.first);
    if (p.accentColorHex != null && p.accentColorHex!.length == 7) {
      return Color(int.parse(p.accentColorHex!.replaceFirst('#', '0xFF')));
    }
    return Colors.grey;
  }

  String _executionModelNameFor(String modelId) {
    for (final model in _availableExecutionModels) {
      if (model['id'] == modelId) {
        return model['name'] ?? modelId;
      }
    }
    return modelId;
  }

  Future<void> _executeRun() async {
    if (_run == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Save the run first')));
      return;
    }
    if (_selectedExecutionProvider == null || _selectedExecutionModelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a provider and model first.')));
      return;
    }

    final runId = await _saveRun(showSnackBar: false);
    if (runId == null) return;

    setState(() => _isExecuting = true);
    final service = ref.read(llmExecutionServiceProvider);
    final result = await service.executeAndSaveOutput(
      exampleId: runId,
      compiledPrompt: _inputController.text,
      providerId: _selectedExecutionProvider!.providerId,
      modelId: _selectedExecutionModelId!,
      modelName: _executionModelNameFor(_selectedExecutionModelId!),
      targetProfileId: 'project-run',
      outputType: 'markdown',
      sourceType: 'api',
    );

    if (!mounted) return;
    setState(() => _isExecuting = false);

    if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.error} Use Paste Output for manual fallback.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('API output saved.')));
  }

  void _showManualOutputDialog() {
    if (_run == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Save the run first')));
      return;
    }
    showDialog(
      context: context,
      builder: (context) => OutputEditorDialog(exampleId: _run!.id),
    );
  }

  @override
  void dispose() {
    _outputsSubscription?.cancel();
    _titleController.dispose();
    _inputController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Widget _buildEditor({required bool isDesktop}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isDesktop
            ? Border(right: BorderSide(color: Theme.of(context).dividerColor))
            : null,
      ),
      child: Column(
        children: [
          Expanded(
            child: _isPreviewMode
                ? Markdown(
                    data: _inputController.text.isEmpty ? '*No content*' : _inputController.text,
                    selectable: true,
                  )
                : TextField(
                    controller: _inputController,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      hintText: 'Enter your prompt in markdown...',
                      border: OutlineInputBorder(),
                    ),
                    textAlignVertical: TextAlignVertical.top,
                  ),
          ),
          if (_run != null) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Refinement Notes',
                border: OutlineInputBorder(),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildOutputsLab() {
    if (_run == null) {
      return const Center(child: Text('Save the run to see outputs'));
    }
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Outputs Lab', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                _buildExecutionControls(),
              ],
            ),
          ),
          Expanded(
            child: _outputs.isEmpty
                ? const Center(child: Text('No outputs yet.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _outputs.length,
                    itemBuilder: (context, index) {
                      final output = _outputs[index];
                      final color = _getProviderColor(output.providerId);
                      return Card(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: color, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Chip(
                                          label: Text(output.providerName, style: const TextStyle(color: Colors.white)),
                                          backgroundColor: color,
                                        ),
                                        Chip(
                                          label: Text(output.sourceType.toUpperCase()),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (output.isBest) const Icon(Icons.star, color: Colors.amber),
                                ],
                              ),
                              const SizedBox(height: 12),
                              MarkdownBody(data: output.outputText, selectable: true),
                              const Divider(),
                              Row(
                                children: [
                                  TextButton.icon(
                                    icon: const Icon(Icons.star_border),
                                    label: const Text('Mark Best'),
                                    onPressed: () {
                                      ref.read(promptExampleOutputDaoProvider).markOutputAsBest(_run!.id, output.id);
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutionControls() {
    final providers = ref.watch(executionProvidersProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 620;
        final providerField = _buildProviderDropdown(providers);
        final modelField = _buildModelDropdown();
        final runButton = ElevatedButton.icon(
          icon: _isExecuting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.play_arrow),
          label: const Text('Run'),
          onPressed: _isExecuting ? null : _executeRun,
        );
        final pasteButton = OutlinedButton.icon(
          icon: const Icon(Icons.paste),
          label: const Text('Paste Output'),
          onPressed: _showManualOutputDialog,
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              providerField,
              const SizedBox(height: 12),
              modelField,
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [runButton, pasteButton]),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: providerField),
            const SizedBox(width: 8),
            Expanded(child: modelField),
            const SizedBox(width: 12),
            runButton,
            const SizedBox(width: 8),
            pasteButton,
          ],
        );
      },
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
        value: _selectedExecutionProvider,
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
            _selectedExecutionProvider = provider;
            _availableExecutionModels = models;
            _selectedExecutionModelId = models.isNotEmpty ? models.first['id'] : null;
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
        value: _selectedExecutionModelId,
        isExpanded: true,
        underline: const SizedBox(),
        items: _availableExecutionModels.map((model) {
          final id = model['id']!;
          return DropdownMenuItem(value: id, child: Text(model['name'] ?? id));
        }).toList(),
        onChanged: _isExecuting ? null : (modelId) => setState(() => _selectedExecutionModelId = modelId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) return Scaffold(body: Center(child: Text(_error!)));
    
    final isDesktop = MediaQuery.of(context).size.width > 800;

    final appBar = AppBar(
      title: TextField(
        controller: _titleController,
        decoration: const InputDecoration(
          hintText: 'Untitled Prompt Run',
          border: InputBorder.none,
        ),
        style: Theme.of(context).textTheme.titleLarge,
      ),
      actions: [
        IconButton(
          icon: Icon(_isPreviewMode ? Icons.edit : Icons.preview),
          tooltip: _isPreviewMode ? 'Edit Mode' : 'Preview Mode',
          onPressed: () {
            setState(() {
              _isPreviewMode = !_isPreviewMode;
            });
          },
        ),
        if (_run != null)
          IconButton(
            icon: const Icon(Icons.publish),
            tooltip: 'Save as Prompt Card',
            onPressed: () async {
              // Determine initial target notes from best output
              String targetNotes = '';
              if (_outputs.isNotEmpty) {
                final bestOutput = _outputs.firstWhere((o) => o.isBest, orElse: () => _outputs.first);
                targetNotes = 'Originally tested with ${bestOutput.providerName}';
                if (bestOutput.modelName != null) {
                  targetNotes += ' (${bestOutput.modelName})';
                }
              }

              // Load project context
              String projectPurpose = 'Converted from Workspace run';
              try {
                final projectDao = ref.read(projectDaoProvider);
                final project = await projectDao.getProjectById(widget.projectId);
                projectPurpose = 'Converted from Workspace project: ${project.name}';
              } catch (_) {}

              if (!context.mounted) return;
              
              final isDesktop = MediaQuery.of(context).size.width > 600;
              if (isDesktop) {
                showDialog(
                  context: context,
                  builder: (context) => PromptCardConversionDialog(
                    run: _run!,
                    initialPurpose: projectPurpose,
                    initialTargetNotes: targetNotes,
                  ),
                );
              } else {
                showGeneralDialog(
                  context: context,
                  pageBuilder: (context, anim1, anim2) {
                    return PromptCardConversionDialog(
                      run: _run!,
                      initialPurpose: projectPurpose,
                      initialTargetNotes: targetNotes,
                    );
                  },
                );
              }
            },
          ),
        if (isDesktop)
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            onPressed: _save,
          )
        else
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: _save,
          ),
        const SizedBox(width: 16),
      ],
      bottom: (!isDesktop && _run != null)
          ? const TabBar(
              tabs: [
                Tab(text: 'Editor'),
                Tab(text: 'Outputs Lab'),
              ],
            )
          : null,
    );

    if (isDesktop) {
      return Scaffold(
        appBar: appBar,
        body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Expanded(flex: 1, child: _buildEditor(isDesktop: true)),
            if (_run != null) Expanded(flex: 1, child: _buildOutputsLab()),
          ],
        ),
      );
    } else {
      if (_run == null) {
        return Scaffold(
          appBar: appBar,
          body: _buildEditor(isDesktop: false),
        );
      } else {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: appBar,
            body: TabBarView(
              children: [
                _buildEditor(isDesktop: false),
                _buildOutputsLab(),
              ],
            ),
          ),
        );
      }
    }
  }
}
