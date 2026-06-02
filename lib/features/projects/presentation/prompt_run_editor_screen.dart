import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:drift/drift.dart' as drift;

import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';
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
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    try {
      final providerDao = ref.read(lLMProviderDaoProvider);
      _providers = await providerDao.getAllProviders();

      if (widget.runId != null) {
        final exampleDao = ref.read(promptExampleDaoProvider);
        final run = await exampleDao.getExampleById(widget.runId!);
        _run = run;
        _titleController.text = run.title;
        _inputController.text = run.compiledPrompt;
        _notesController.text = run.refinementNote ?? '';
        
        final outputDao = ref.read(promptExampleOutputDaoProvider);
        final outputsStream = outputDao.watchOutputsForExample(run.id);
        outputsStream.listen((data) {
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

  Future<void> _save() async {
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
    } else {
      await dao.updateExample(PromptExamplesCompanion(
        id: drift.Value(_run!.id),
        title: drift.Value(_titleController.text.isEmpty ? 'Untitled Run' : _titleController.text),
        compiledPrompt: drift.Value(_inputController.text),
        refinementNote: drift.Value(_notesController.text.isEmpty ? null : _notesController.text),
        updatedAt: drift.Value(now),
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved!')));
      }
    }
  }
  
  Color _getProviderColor(String? providerId) {
    if (providerId == null) return Colors.grey;
    final p = _providers.firstWhere((p) => p.id == providerId, orElse: () => _providers.first);
    if (p.accentColorHex != null && p.accentColorHex!.length == 7) {
      return Color(int.parse(p.accentColorHex!.replaceFirst('#', '0xFF')));
    }
    return Colors.grey;
  }

  void _addMockOutput() async {
    if (_run == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Save the run first')));
      return;
    }
    
    final outputDao = ref.read(promptExampleOutputDaoProvider);
    final id = const Uuid().v4();
    final now = DateTime.now();
    
    // Pick a random provider
    final provider = _providers[DateTime.now().millisecond % _providers.length];
    
    await outputDao.addOutput(PromptExampleOutputsCompanion.insert(
      id: id,
      exampleId: _run!.id,
      providerId: drift.Value(provider.id),
      providerName: provider.name,
      modelName: const drift.Value('Mock Model'),
      outputText: 'Mock output generated at ${now.toIso8601String()}',
      createdAt: now,
      updatedAt: now,
    ));
  }

  Widget _buildEditor() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Outputs Lab', style: Theme.of(context).textTheme.titleLarge),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Mock Output'),
                  onPressed: _addMockOutput,
                ),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Chip(
                                    label: Text(output.providerName, style: const TextStyle(color: Colors.white)),
                                    backgroundColor: color,
                                  ),
                                  if (output.isBest)
                                    const Icon(Icons.star, color: Colors.amber),
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
        ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: const Text('Save'),
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
            Expanded(flex: 1, child: _buildEditor()),
            if (_run != null) Expanded(flex: 1, child: _buildOutputsLab()),
          ],
        ),
      );
    } else {
      if (_run == null) {
        return Scaffold(
          appBar: appBar,
          body: _buildEditor(),
        );
      } else {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: appBar,
            body: TabBarView(
              children: [
                _buildEditor(),
                _buildOutputsLab(),
              ],
            ),
          ),
        );
      }
    }
  }
}
