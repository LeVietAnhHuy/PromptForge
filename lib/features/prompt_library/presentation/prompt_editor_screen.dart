import 'dart:async';
import 'dart:convert' as dart_convert;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';
import '../../prompt_compiler/domain/prompt_compiler_service.dart';
import '../../../shared/markdown/inline_markdown_editor.dart';
import '../../../shared/markdown/markdown_reader_style.dart';
import '../../../app/theme/app_design.dart';
import 'prompt_body_focus_editor.dart';
import '../../prompt_examples/presentation/manual_output_paste_dialog.dart';
import '../../prompt_examples/presentation/prompt_output_card.dart';

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

  List<PromptExampleOutput> _outputs = [];
  StreamSubscription<List<PromptExampleOutput>>? _outputsSubscription;

  DateTime? _lastSavedAt;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _bodyController.addListener(_onBodyChanged);
    _loadPrompt();
  }

  void _markDirty() {
    if (!_dirty && mounted) setState(() => _dirty = true);
  }

  void _onBodyChanged() {
    if (_isLoading) return;
    final variables =
        PromptCompilerService.extractVariables(_bodyController.text);
    if (listEquals(_detectedVariables, variables)) {
      // Body content changed but variable set is the same: still refresh the
      // live counts / outline / dirty indicator in the footer.
      if (mounted) setState(() => _dirty = true);
      return;
    }

    setState(() {
      _dirty = true;
      _detectedVariables = variables;
      final newForms = <String, _VariableMetadataForm>{};
      for (final v in variables) {
        newForms[v] = _variableForms[v] ??
            _VariableMetadataForm(name: v, isRequired: true);
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
        _lastSavedAt = prompt.updatedAt;
        _dirty = false;
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
            _variableForms[v] =
                _VariableMetadataForm(name: v, isRequired: true);
          }
        }

        final outputDao = ref.read(promptExampleOutputDaoProvider);
        _outputsSubscription?.cancel();
        _outputsSubscription =
            outputDao.watchOutputsForPrompt(prompt.id).listen((data) {
          if (mounted) {
            setState(() {
              _outputs = data;
            });
          }
        });

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
    _outputsSubscription?.cancel();
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
          purpose: _purposeController.text.isNotEmpty
              ? drift.Value(_purposeController.text)
              : const drift.Value.absent(),
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
        final newTagNames = _tagsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        bool titleChanged = _existingPrompt!.title != _titleController.text;
        bool bodyChanged = _existingPrompt!.body != _bodyController.text;
        bool tagsChanged = currentTagNames.join(',') != newTagNames.join(',');

        // For simplicity, consider variables changed if names don't match, or just rely on body changes since variables are tied to body.
        bool varsChanged = existingVars.map((v) => v.name).join(',') !=
            _detectedVariables.join(',');

        if (titleChanged || bodyChanged || tagsChanged || varsChanged) {
          // Create snapshot of the existing state before we overwrite it
          final tagsJson = dart_convert.jsonEncode(currentTagNames);
          final varsJson = dart_convert.jsonEncode(existingVars
              .map((v) => {
                    'name': v.name,
                    'label': v.label,
                    'description': v.description,
                    'defaultValue': v.defaultValue,
                    'exampleValue': v.exampleValue,
                    'isRequired': v.isRequired,
                  })
              .toList());

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
          purpose: _purposeController.text.isNotEmpty
              ? drift.Value(_purposeController.text)
              : const drift.Value.absent(),
          createdAt: _existingPrompt!.createdAt,
          updatedAt: now,
        ));
      }

      // Save tags
      final tagNames = _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
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
          label: form.labelController.text.isNotEmpty
              ? drift.Value(form.labelController.text)
              : const drift.Value.absent(),
          description: form.descriptionController.text.isNotEmpty
              ? drift.Value(form.descriptionController.text)
              : const drift.Value.absent(),
          defaultValue: form.defaultController.text.isNotEmpty
              ? drift.Value(form.defaultController.text)
              : const drift.Value.absent(),
          exampleValue: form.exampleController.text.isNotEmpty
              ? drift.Value(form.exampleController.text)
              : const drift.Value.absent(),
          isRequired: drift.Value(form.isRequired),
          sortOrder: drift.Value(order++),
          createdAt: now,
          updatedAt: now,
        );
        return comp;
      }).toList();
      await pvDao.syncVariablesForPrompt(currentPromptId, varCompanions);

      // Save in place: refresh the loaded prompt and the "Saved ·" indicator
      // instead of leaving the editor, so the right-hand outputs panel stays
      // available for continued work.
      final wasNew = _existingPrompt == null;
      final saved = await promptDao.getPromptById(currentPromptId);
      if (!mounted) return;
      setState(() {
        _existingPrompt = saved;
        _lastSavedAt = saved.updatedAt;
        _dirty = false;
      });
      if (wasNew) {
        final outputDao = ref.read(promptExampleOutputDaoProvider);
        _outputsSubscription?.cancel();
        _outputsSubscription =
            outputDao.watchOutputsForPrompt(currentPromptId).listen((data) {
          if (mounted) setState(() => _outputs = data);
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prompt saved')),
      );
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
        purpose: _existingPrompt!.purpose != null
            ? drift.Value(_existingPrompt!.purpose!)
            : const drift.Value.absent(),
        createdAt: now,
        updatedAt: now,
      ));

// Duplicate tags
      final existingTags = await tagDao.getTagsForPrompt(_existingPrompt!.id);
      final tagNames = existingTags.map((t) => t.name).toList();
      await tagDao.replaceTagsForPrompt(newPromptId, tagNames);

      // Duplicate variable metadata
      final pvDao = ref.read(promptVariableDaoProvider);
      final existingVars =
          await pvDao.getVariablesForPrompt(_existingPrompt!.id);
      final newVarCompanions = existingVars
          .map((v) => PromptVariablesCompanion.insert(
                id: const Uuid().v4(),
                promptId: newPromptId,
                name: v.name,
                label: v.label != null
                    ? drift.Value(v.label!)
                    : const drift.Value.absent(),
                description: v.description != null
                    ? drift.Value(v.description!)
                    : const drift.Value.absent(),
                defaultValue: v.defaultValue != null
                    ? drift.Value(v.defaultValue!)
                    : const drift.Value.absent(),
                exampleValue: v.exampleValue != null
                    ? drift.Value(v.exampleValue!)
                    : const drift.Value.absent(),
                isRequired: drift.Value(v.isRequired),
                sortOrder: drift.Value(v.sortOrder),
                createdAt: now,
                updatedAt: now,
              ))
          .toList();
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
              onPressed: () =>
                  context.push('/library/examples/${_existingPrompt!.id}'),
            ),
            IconButton(
              icon: const Icon(Icons.manage_history),
              tooltip: 'Version History',
              onPressed: () =>
                  context.push('/library/versions/${_existingPrompt!.id}'),
            ),
            IconButton(
              icon: const Icon(Icons.play_arrow),
              tooltip: 'Use Prompt (Compile)',
              onPressed: () =>
                  context.push('/library/compile/${_existingPrompt!.id}'),
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final twoColumn = constraints.maxWidth >= AppDesign.splitBreakpoint;
            if (!twoColumn) {
              // Below the breakpoint: collapse to a single scroll view holding
              // the header band, body editor, then saved outputs. Keeping the
              // header inside this list (rather than as a fixed band) means the
              // list stays the primary scrollable for the whole screen.
              return ListView(
                padding: const EdgeInsets.all(AppDesign.spacingLg),
                children: [
                  _buildHeaderBand(context, banded: false),
                  const SizedBox(height: AppDesign.spacingLg),
                  ..._bodyEditorChildren(context),
                  const SizedBox(height: AppDesign.spacingXl),
                  ..._outputsChildren(context),
                ],
              );
            }
            // Wide: a fixed full-width header band, then two independently
            // scrolling columns — left = body editor (~57%), right = saved
            // outputs (~43%).
            return Column(
              children: [
                _buildHeaderBand(context, banded: true),
                const Divider(height: 1),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 57,
                        child: ListView(
                          padding: const EdgeInsets.all(AppDesign.spacingLg),
                          children: _bodyEditorChildren(context),
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(
                        flex: 43,
                        child: Container(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerLow
                              .withValues(alpha: 0.4),
                          child: ListView(
                            padding: const EdgeInsets.all(AppDesign.spacingLg),
                            children: _outputsChildren(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- Header band (Title / Purpose / Tags), full width and compact ---
  Widget _buildHeaderBand(BuildContext context, {required bool banded}) {
    final titleField = TextFormField(
      controller: _titleController,
      onChanged: (_) => _markDirty(),
      style: Theme.of(context).textTheme.titleMedium,
      decoration: const InputDecoration(
        labelText: 'Title',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a title';
        }
        return null;
      },
    );
    final purposeField = TextFormField(
      controller: _purposeController,
      onChanged: (_) => _markDirty(),
      decoration: const InputDecoration(
        labelText: 'Purpose / Description (Optional)',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      maxLines: 1,
    );
    final tagsField = TextFormField(
      controller: _tagsController,
      onChanged: (_) => _markDirty(),
      decoration: const InputDecoration(
        labelText: 'Tags (comma-separated)',
        hintText: 'e.g. coding, article, translation',
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );

    final inner = LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppDesign.mobileBreakpoint) {
          return Column(
            children: [
              titleField,
              const SizedBox(height: AppDesign.spacingSm),
              purposeField,
              const SizedBox(height: AppDesign.spacingSm),
              tagsField,
            ],
          );
        }
        return Column(
          children: [
            titleField,
            const SizedBox(height: AppDesign.spacingSm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: purposeField),
                const SizedBox(width: AppDesign.spacingMd),
                Expanded(flex: 2, child: tagsField),
              ],
            ),
          ],
        );
      },
    );

    if (!banded) return inner;
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDesign.spacingLg,
        vertical: AppDesign.spacingMd,
      ),
      child: inner,
    );
  }

  // --- Left column: prompt body editor, footer, outline, variables ---
  List<Widget> _bodyEditorChildren(BuildContext context) {
    final theme = Theme.of(context);
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Prompt Body', style: theme.textTheme.titleLarge),
          FilledButton.tonalIcon(
            onPressed: () async {
              FocusScope.of(context).unfocus();
              final newText = await PromptBodyFocusEditor.show(
                context,
                _bodyController.text,
              );
              if (newText != null && newText != _bodyController.text) {
                _bodyController.text = newText;
                // Body listener picks this up to extract variables + counts.
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
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: AppDesign.borderMd,
            color: theme.colorScheme.surfaceContainerLow,
          ),
          clipBehavior: Clip.hardEdge,
          child: IgnorePointer(
            // IgnorePointer so clicks on the preview trigger the InkWell
            // instead of inline edit.
            child: Stack(
              children: [
                _bodyController.text.trim().isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(AppDesign.spacingMd),
                        child: Text(
                          'Tap to open the focus editor and write your prompt…',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : InlineMarkdownEditor(
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
                          theme.colorScheme.surfaceContainerLow
                              .withValues(alpha: 0.0),
                          theme.colorScheme.surfaceContainerLow,
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
      const SizedBox(height: AppDesign.spacingSm),
      _buildBodyFooter(context),
      const SizedBox(height: AppDesign.spacingLg),
      _buildOutline(context),
      if (_detectedVariables.isNotEmpty) ...[
        const SizedBox(height: AppDesign.spacingLg),
        Text('Variable Metadata', style: theme.textTheme.titleLarge),
        const SizedBox(height: AppDesign.spacingSm),
        ..._detectedVariables.map((vName) {
          final form = _variableForms[vName]!;
          return Card(
            margin: const EdgeInsets.only(bottom: AppDesign.spacingMd),
            child: Padding(
              padding: const EdgeInsets.all(AppDesign.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('{{$vName}}',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontFamily: AppDesign.fontMono)),
                      Row(
                        children: [
                          const Text('Required: '),
                          Switch(
                            value: form.isRequired,
                            onChanged: (val) {
                              setState(() {
                                form.isRequired = val;
                                _dirty = true;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDesign.spacingSm),
                  LayoutBuilder(
                    builder: (context, c) {
                      // Two columns when there's room for them, otherwise a
                      // single full-width column — never wider than available.
                      final twoUp = c.maxWidth >= 620;
                      final fieldWidth = twoUp
                          ? (c.maxWidth - AppDesign.spacingMd) / 2
                          : c.maxWidth;
                      return Wrap(
                        spacing: AppDesign.spacingMd,
                        runSpacing: AppDesign.spacingMd,
                        children: [
                          SizedBox(
                            width: fieldWidth,
                            child: TextField(
                              controller: form.labelController,
                              onChanged: (_) => _markDirty(),
                              decoration: const InputDecoration(
                                  labelText: 'Display Label',
                                  border: OutlineInputBorder()),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: TextField(
                              controller: form.descriptionController,
                              onChanged: (_) => _markDirty(),
                              decoration: const InputDecoration(
                                  labelText: 'Description (Helper text)',
                                  border: OutlineInputBorder()),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: TextField(
                              controller: form.defaultController,
                              onChanged: (_) => _markDirty(),
                              decoration: const InputDecoration(
                                  labelText: 'Default Value',
                                  border: OutlineInputBorder()),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: TextField(
                              controller: form.exampleController,
                              onChanged: (_) => _markDirty(),
                              decoration: const InputDecoration(
                                  labelText: 'Example Value (Hint)',
                                  border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    ];
  }

  // Live character + estimated token count, plus a "Saved ·" indicator.
  Widget _buildBodyFooter(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final text = _bodyController.text;
    final chars = text.characters.length;
    // Rough heuristic: ~4 characters per token (English prose / prompts).
    final tokens = text.trim().isEmpty ? 0 : (chars / 4).ceil();

    String savedLabel;
    Color savedColor;
    if (_dirty) {
      savedLabel = 'Unsaved changes';
      savedColor = context.forge.warning;
    } else if (_lastSavedAt != null) {
      savedLabel = 'Saved · ${DateFormat.jm().format(_lastSavedAt!.toLocal())}';
      savedColor = context.forge.success;
    } else {
      savedLabel = 'Not saved yet';
      savedColor = muted;
    }

    return Row(
      children: [
        Icon(Icons.tag, size: 14, color: muted),
        const SizedBox(width: AppDesign.spacingXs),
        Text(
          '$chars chars · ~$tokens tokens',
          style: theme.textTheme.labelMedium
              ?.copyWith(color: muted, fontFamily: AppDesign.fontMono),
        ),
        const Spacer(),
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: savedColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppDesign.spacingSm),
        Text(savedLabel,
            style: theme.textTheme.labelMedium?.copyWith(color: savedColor)),
      ],
    );
  }

  // Contents outline derived from Markdown headings in the body.
  Widget _buildOutline(BuildContext context) {
    final theme = Theme.of(context);
    final headings = _extractHeadings(_bodyController.text);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDesign.spacingMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: AppDesign.borderMd,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: AppDesign.spacingSm),
              Text('Contents', style: theme.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: AppDesign.spacingSm),
          if (headings.isEmpty)
            Text(
              'No headings yet — add Markdown headings (#, ##) to outline your prompt.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            )
          else
            ...headings.map((h) => Padding(
                  padding: EdgeInsets.only(
                    left: (h.level - 1) * AppDesign.spacingMd,
                    bottom: AppDesign.spacingXs,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(Icons.chevron_right,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: AppDesign.spacingXs),
                      Expanded(
                        child: Text(
                          h.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: h.level == 1
                              ? theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)
                              : theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  // --- Right column: saved outputs ---
  List<Widget> _outputsChildren(BuildContext context) {
    final theme = Theme.of(context);
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text('Saved Outputs',
                style: theme.textTheme.titleLarge,
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: AppDesign.spacingSm),
          FilledButton.icon(
            onPressed: _existingPrompt == null
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Please save the prompt first.')));
                  }
                : () async {
                    FocusScope.of(context).unfocus();
                    await showDialog<bool>(
                      context: context,
                      builder: (context) => ManualOutputPasteDialog(
                        promptId: _existingPrompt!.id,
                        compiledPromptSnapshot: _bodyController.text,
                      ),
                    );
                    // Output saved (if any), the stream auto-updates the list.
                  },
            icon: const Icon(Icons.add),
            label: const Text('Paste LLM Output'),
          ),
        ],
      ),
      const SizedBox(height: AppDesign.spacingMd),
      if (_outputs.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDesign.spacingXl),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: AppDesign.borderLg,
            color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.4),
          ),
          child: Column(
            children: [
              Icon(Icons.chat_bubble_outline,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.5)),
              const SizedBox(height: AppDesign.spacingMd),
              Text('No outputs saved yet.',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: AppDesign.spacingSm),
              Text('Run the prompt externally and paste the result here.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        )
      else
        ..._outputs.map((output) => PromptOutputCard(
              output: output,
              onEdit: () async {
                FocusScope.of(context).unfocus();
                await showDialog<bool>(
                  context: context,
                  builder: (context) => ManualOutputPasteDialog(
                    promptId: _existingPrompt!.id,
                    compiledPromptSnapshot: _bodyController.text,
                    existingOutput: output,
                  ),
                );
              },
              onDelete: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete output?'),
                    content: const Text(
                        'Are you sure you want to delete this output?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.error),
                          child: const Text('Delete')),
                    ],
                  ),
                );
                if (confirm == true && mounted) {
                  await ref
                      .read(promptExampleOutputDaoProvider)
                      .deleteOutput(output.id);
                }
              },
            )),
    ];
  }
}

class _Heading {
  final int level;
  final String text;
  const _Heading(this.level, this.text);
}

List<_Heading> _extractHeadings(String body) {
  final result = <_Heading>[];
  final headingRe = RegExp(r'^(#{1,6})\s+(.*\S)\s*$');
  var inFence = false;
  for (final raw in body.split('\n')) {
    final line = raw.trimRight();
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('```') || trimmed.startsWith('~~~')) {
      inFence = !inFence;
      continue;
    }
    if (inFence) continue;
    final m = headingRe.firstMatch(line);
    if (m != null) {
      result.add(_Heading(m.group(1)!.length, m.group(2)!.trim()));
    }
  }
  return result;
}
