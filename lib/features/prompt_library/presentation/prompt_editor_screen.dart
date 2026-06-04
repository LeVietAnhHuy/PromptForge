import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:drift/drift.dart' as drift;
import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';

import '../../prompt_compiler/domain/prompt_compiler_service.dart';
import 'dart:convert' as dart_convert;
import 'package:flutter/foundation.dart';

import '../../../shared/markdown/inline_markdown_editor.dart';
import '../../../shared/markdown/markdown_reader_style.dart';
import '../../../app/theme/app_design.dart';
import 'prompt_body_focus_editor.dart';




class _VariableMetadataForm {
  final String name;
  final TextEditingController labelController;
  final TextEditingController descriptionController;
  final TextEditingController defaultController;
  final TextEditingController exampleController;
  bool isRequired;

  _VariableMetadataForm({
    required this.name,
    String? label,
    String? description,
    String? defaultValue,
    String? exampleValue,
    required this.isRequired,
  })  : labelController = TextEditingController(text: label),
        descriptionController = TextEditingController(text: description),
        defaultController = TextEditingController(text: defaultValue),
        exampleController = TextEditingController(text: exampleValue);

  void dispose() {
    labelController.dispose();
    descriptionController.dispose();
    defaultController.dispose();
    exampleController.dispose();
  }
}

class PromptEditorScreen extends ConsumerStatefulWidget {
  final String? promptId;

  const PromptEditorScreen({super.key, this.promptId});

  @override
  ConsumerState<PromptEditorScreen> createState() => _PromptEditorScreenState();
}

class _PromptEditorScreenState extends ConsumerState<PromptEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _purposeController = TextEditingController();
  final _tagsController = TextEditingController();
  
  Prompt? _existingPrompt;
  bool _isLoading = true;

  Map<String, _VariableMetadataForm> _variableForms = {};
  List<String> _detectedVariables = [];


@override
  void initState() {
    super.initState();
    _bodyController.addListener(_onBodyChanged);
    _loadPrompt();
  }

  void _onBodyChanged() {
    final variables = PromptCompilerService.extractVariables(_bodyController.text);
    if (listEquals(_detectedVariables, variables)) return;
    
      setState(() {
      _detectedVariables = variables;
      final newForms = <String, _VariableMetadataForm>{};
      for (final v in variables) {
        newForms[v] = _variableForms[v] ?? _VariableMetadataForm(name: v, isRequired: true);
      }
      
      // Dispose old forms that are no longer present
      for (final v in _variableForms.keys) {
        if (!variables.contains(v)) {
          _variableForms[v]?.dispose();
        }
      }
      
      _variableForms = newForms;
    });
  }

  Future<void> _loadPrompt() async {
    if (widget.promptId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final promptDao = ref.read(promptDaoProvider);
      final tagDao = ref.read(tagDaoProvider);
      final pvDao = ref.read(promptVariableDaoProvider);
      
      final prompt = await promptDao.getPromptById(widget.promptId!);
      final tags = await tagDao.getTagsForPrompt(widget.promptId!);
      final vars = await pvDao.getVariablesForPrompt(widget.promptId!);
      
      setState(() {
        _existingPrompt = prompt;
        _titleController.text = prompt.title;
        _bodyController.text = prompt.body;
        _purposeController.text = prompt.purpose ?? '';
        _tagsController.text = tags.map((t) => t.name).join(', ');
        
        final variables = PromptCompilerService.extractVariables(prompt.body);
        _detectedVariables = variables;
        _variableForms = {};
        for (final v in vars) {
          if (variables.contains(v.name)) {
            _variableForms[v.name] = _VariableMetadataForm(
              name: v.name,
              label: v.label,
              description: v.description,
              defaultValue: v.defaultValue,
              exampleValue: v.exampleValue,
              isRequired: v.isRequired,
            );
          }
        }
        for (final v in variables) {
          if (!_variableForms.containsKey(v)) {
            _variableForms[v] = _VariableMetadataForm(name: v, isRequired: true);
          }
        }

        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load prompt: $e')),
        );
        context.pop();
      }
    }
  }

@override
  void dispose() {
    _bodyController.removeListener(_onBodyChanged);
    _titleController.dispose();
    _bodyController.dispose();
    _purposeController.dispose();
    _tagsController.dispose();
    for (final form in _variableForms.values) {
      form.dispose();
    }
    super.dispose();
  }

  Future<void> _savePrompt() async {
    // Body validation: in Preview mode the TextFormField validator isn't mounted
    if (_bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the prompt body')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final promptDao = ref.read(promptDaoProvider);
    final tagDao = ref.read(tagDaoProvider);
    final now = DateTime.now();

    try {
      String currentPromptId;
      if (_existingPrompt == null) {
        // Create new
        currentPromptId = const Uuid().v4();
        await promptDao.createPrompt(PromptsCompanion.insert(
          id: currentPromptId,
          title: _titleController.text,
          body: _bodyController.text,
          purpose: _purposeController.text.isNotEmpty ? drift.Value(_purposeController.text) : const drift.Value.absent(),
          createdAt: now,
          updatedAt: now,
        ));
      } else {
        // Update existing
        currentPromptId = _existingPrompt!.id;
        
        // 1. Fetch current live tags and variables to check for changes and to snapshot
        final existingTags = await tagDao.getTagsForPrompt(currentPromptId);
        final pvDao = ref.read(promptVariableDaoProvider);
        final existingVars = await pvDao.getVariablesForPrompt(currentPromptId);
        
        final currentTagNames = existingTags.map((t) => t.name).toList();
        final newTagNames = _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        
        bool titleChanged = _existingPrompt!.title != _titleController.text;
        bool bodyChanged = _existingPrompt!.body != _bodyController.text;
        bool tagsChanged = currentTagNames.join(',') != newTagNames.join(',');
        
        // For simplicity, consider variables changed if names don't match, or just rely on body changes since variables are tied to body.
        bool varsChanged = existingVars.map((v) => v.name).join(',') != _detectedVariables.join(',');

        if (titleChanged || bodyChanged || tagsChanged || varsChanged) {
          // Create snapshot of the existing state before we overwrite it
          final tagsJson = dart_convert.jsonEncode(currentTagNames);
          final varsJson = dart_convert.jsonEncode(existingVars.map((v) => {
            'name': v.name,
            'label': v.label,
            'description': v.description,
            'defaultValue': v.defaultValue,
            'exampleValue': v.exampleValue,
            'isRequired': v.isRequired,
          }).toList());

          await promptDao.createPromptVersion(PromptVersionsCompanion.insert(
            id: const Uuid().v4(),
            promptId: currentPromptId,
            title: _existingPrompt!.title,
            body: _existingPrompt!.body,
            tagsJson: drift.Value(tagsJson),
            variableMetadataJson: drift.Value(varsJson),
            createdAt: now,
          ));
        }

        await promptDao.updatePrompt(PromptsCompanion.insert(
          id: currentPromptId,
          title: _titleController.text,
          body: _bodyController.text,
          purpose: _purposeController.text.isNotEmpty ? drift.Value(_purposeController.text) : const drift.Value.absent(),
          createdAt: _existingPrompt!.createdAt,
          updatedAt: now,
        ));
      }

      // Save tags
      final tagNames = _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      await tagDao.replaceTagsForPrompt(currentPromptId, tagNames);

      // Save variables
      final pvDao = ref.read(promptVariableDaoProvider);
      int order = 0;
      final varCompanions = _detectedVariables.map((vName) {
        final form = _variableForms[vName]!;
        final comp = PromptVariablesCompanion.insert(
          id: const Uuid().v4(),
          promptId: currentPromptId,
          name: vName,
          label: form.labelController.text.isNotEmpty ? drift.Value(form.labelController.text) : const drift.Value.absent(),
          description: form.descriptionController.text.isNotEmpty ? drift.Value(form.descriptionController.text) : const drift.Value.absent(),
          defaultValue: form.defaultController.text.isNotEmpty ? drift.Value(form.defaultController.text) : const drift.Value.absent(),
          exampleValue: form.exampleController.text.isNotEmpty ? drift.Value(form.exampleController.text) : const drift.Value.absent(),
          isRequired: drift.Value(form.isRequired),
          sortOrder: drift.Value(order++),
          createdAt: now,
          updatedAt: now,
        );
        return comp;
      }).toList();
      await pvDao.syncVariablesForPrompt(currentPromptId, varCompanions);

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save prompt: $e')),
        );
      }
    }
  }

  Future<void> _duplicatePrompt() async {
    if (_existingPrompt == null) return;

    final promptDao = ref.read(promptDaoProvider);
    final tagDao = ref.read(tagDaoProvider);
    final now = DateTime.now();

    try {
      final newPromptId = const Uuid().v4();
      await promptDao.createPrompt(PromptsCompanion.insert(
        id: newPromptId,
        title: '${_existingPrompt!.title} (Copy)',
        body: _existingPrompt!.body,
        purpose: _existingPrompt!.purpose != null ? drift.Value(_existingPrompt!.purpose!) : const drift.Value.absent(),
        createdAt: now,
        updatedAt: now,
      ));

// Duplicate tags
      final existingTags = await tagDao.getTagsForPrompt(_existingPrompt!.id);
      final tagNames = existingTags.map((t) => t.name).toList();
      await tagDao.replaceTagsForPrompt(newPromptId, tagNames);

      // Duplicate variable metadata
      final pvDao = ref.read(promptVariableDaoProvider);
      final existingVars = await pvDao.getVariablesForPrompt(_existingPrompt!.id);
      final newVarCompanions = existingVars.map((v) => PromptVariablesCompanion.insert(
        id: const Uuid().v4(),
        promptId: newPromptId,
        name: v.name,
        label: v.label != null ? drift.Value(v.label!) : const drift.Value.absent(),
        description: v.description != null ? drift.Value(v.description!) : const drift.Value.absent(),
        defaultValue: v.defaultValue != null ? drift.Value(v.defaultValue!) : const drift.Value.absent(),
        exampleValue: v.exampleValue != null ? drift.Value(v.exampleValue!) : const drift.Value.absent(),
        isRequired: drift.Value(v.isRequired),
        sortOrder: drift.Value(v.sortOrder),
        createdAt: now,
        updatedAt: now,
      )).toList();
      await pvDao.syncVariablesForPrompt(newPromptId, newVarCompanions);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prompt duplicated')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to duplicate prompt: $e')),
        );
      }
    }
  }

  Future<void> _deletePrompt() async {
    if (_existingPrompt == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Prompt'),
        content: const Text('Are you sure you want to delete this prompt?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final promptDao = ref.read(promptDaoProvider);
      await promptDao.archivePrompt(_existingPrompt!.id);
      
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isEditing = _existingPrompt != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Prompt' : 'New Prompt'),
        actions: [
          if (isEditing) ...[
            IconButton(
              icon: const Icon(Icons.science),
              tooltip: 'Examples & Comparisons',
              onPressed: () => context.push('/library/examples/${_existingPrompt!.id}'),
            ),
            IconButton(
              icon: const Icon(Icons.manage_history),
              tooltip: 'Version History',
              onPressed: () => context.push('/library/versions/${_existingPrompt!.id}'),
            ),
            IconButton(
              icon: const Icon(Icons.play_arrow),
              tooltip: 'Use Prompt (Compile)',
              onPressed: () => context.push('/library/compile/${_existingPrompt!.id}'),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Duplicate',
              onPressed: _duplicatePrompt,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete',
              onPressed: _deletePrompt,
            ),
          ],
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: _savePrompt,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _purposeController,
              decoration: const InputDecoration(
                labelText: 'Purpose / Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (comma-separated)',
                hintText: 'e.g. coding, article, translation',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppDesign.spacingMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Prompt Body', style: Theme.of(context).textTheme.titleSmall),
                FilledButton.tonalIcon(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    final newText = await PromptBodyFocusEditor.show(
                      context,
                      _bodyController.text,
                    );
                    if (newText != null && newText != _bodyController.text) {
                      _bodyController.text = newText;
                      // Form listeners will pick this up to extract variables
                    }
                  },
                  icon: const Icon(Icons.fullscreen),
                  label: const Text('Open Focus Editor'),
                ),
              ],
            ),
            const SizedBox(height: AppDesign.spacingSm),
            InkWell(
              onTap: () async {
                FocusScope.of(context).unfocus();
                final newText = await PromptBodyFocusEditor.show(
                  context,
                  _bodyController.text,
                );
                if (newText != null && newText != _bodyController.text) {
                  _bodyController.text = newText;
                }
              },
              borderRadius: AppDesign.borderMd,
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  borderRadius: AppDesign.borderMd,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                ),
                clipBehavior: Clip.hardEdge,
                child: IgnorePointer(
                  // IgnorePointer so clicks on the preview trigger the InkWell instead of inline edit
                  child: Stack(
                    children: [
                      InlineMarkdownEditor(
                        controller: _bodyController,
                        readerStyle: MarkdownReaderStyle.promptForge,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.0),
                                Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_detectedVariables.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Variable Metadata', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ..._detectedVariables.map((vName) {
                final form = _variableForms[vName]!;
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('{{$vName}}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Row(
                              children: [
                                const Text('Required: '),
                                Switch(
                                  value: form.isRequired,
                                  onChanged: (val) {
                                    setState(() => form.isRequired = val);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: 300,
                              child: TextField(
                                controller: form.labelController,
                                decoration: const InputDecoration(labelText: 'Display Label', border: OutlineInputBorder()),
                              ),
                            ),
                            SizedBox(
                              width: 300,
                              child: TextField(
                                controller: form.descriptionController,
                                decoration: const InputDecoration(labelText: 'Description (Helper text)', border: OutlineInputBorder()),
                              ),
                            ),
                            SizedBox(
                              width: 300,
                              child: TextField(
                                controller: form.defaultController,
                                decoration: const InputDecoration(labelText: 'Default Value', border: OutlineInputBorder()),
                              ),
                            ),
                            SizedBox(
                              width: 300,
                              child: TextField(
                                controller: form.exampleController,
                                decoration: const InputDecoration(labelText: 'Example Value (Hint)', border: OutlineInputBorder()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
