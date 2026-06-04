import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';
import '../application/llm_model_catalog.dart';

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
  final _customModelController = TextEditingController();
  final _outputController = TextEditingController();
  final _notesController = TextEditingController();
  
  List<LLMProvider> _providers = [];
  bool _isLoading = true;
  bool _isSaving = false;

  String? _selectedProviderId;
  String? _selectedModelId;
  String _outputType = 'markdown';
  List<PlatformFile> _attachments = [];

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    final providerDao = ref.read(lLMProviderDaoProvider);
    var providers = await providerDao.getAllProviders();
    
    if (providers.isEmpty) {
      final now = DateTime.now();
      providers = [
        LLMProvider(id: 'openai', name: 'OpenAI', createdAt: now),
        LLMProvider(id: 'anthropic', name: 'Anthropic', createdAt: now),
        LLMProvider(id: 'google', name: 'Google', createdAt: now),
        LLMProvider(id: 'deepseek', name: 'DeepSeek', createdAt: now),
        LLMProvider(id: 'other', name: 'Other', createdAt: now),
      ];
    }
    
    if (mounted) {
      setState(() {
        _providers = providers;
        if (_providers.isNotEmpty) {
          _selectedProviderId = _providers.first.id;
          _selectedModelId = _getModelsForProvider(_selectedProviderId!).first.id;
        }
        _isLoading = false;
      });
    }
  }

  List<LlmModelOption> _getModelsForProvider(String providerId) {
    final catalog = defaultModelCatalog[providerId];
    if (catalog != null) {
      return [...catalog.models, const LlmModelOption(id: 'custom', displayName: 'Custom model...', family: '', approximateReleaseOrder: 9999)];
    }
    return const [LlmModelOption(id: 'custom', displayName: 'Custom model...', family: '', approximateReleaseOrder: 9999)];
  }

  @override
  void dispose() {
    _customModelController.dispose();
    _outputController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
      );
      if (result != null) {
        setState(() {
          _attachments.addAll(result.files);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick files: $e')));
      }
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_outputController.text.trim().isEmpty && _attachments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide output text or attach at least one file.')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final exampleDao = ref.read(promptExampleDaoProvider);
      final outputDao = ref.read(promptExampleOutputDaoProvider);
      final attachmentDao = ref.read(lLMOutputAttachmentDaoProvider);
      
      final exampleId = const Uuid().v4();
      final outputId = const Uuid().v4();

      await exampleDao.createExample(PromptExamplesCompanion.insert(
        id: exampleId,
        promptId: drift.Value(widget.promptId),
        title: 'Manual Output',
        compiledPrompt: widget.compiledPromptSnapshot,
        notes: const drift.Value('Manual output capture'),
        createdAt: now,
        updatedAt: now,
      ));

      final matchedProvider = _providers.where((p) => p.id == _selectedProviderId).firstOrNull;
      
      String modelName = '';
      if (_selectedModelId == 'custom') {
        modelName = _customModelController.text.trim();
      } else if (_selectedProviderId != null && _selectedModelId != null) {
        final models = _getModelsForProvider(_selectedProviderId!);
        final matched = models.where((m) => m.id == _selectedModelId).firstOrNull;
        modelName = matched?.displayName ?? _selectedModelId!;
      }

      await outputDao.addOutput(PromptExampleOutputsCompanion.insert(
        id: outputId,
        exampleId: exampleId,
        providerId: _selectedProviderId != null ? drift.Value(_selectedProviderId!) : const drift.Value.absent(),
        providerName: matchedProvider?.name ?? 'Unknown',
        modelId: _selectedModelId != null && _selectedModelId != 'custom' ? drift.Value(_selectedModelId!) : const drift.Value.absent(),
        modelName: modelName.isNotEmpty ? drift.Value(modelName) : const drift.Value.absent(),
        outputType: drift.Value(_outputType),
        outputText: _outputController.text,
        notes: _notesController.text.isNotEmpty ? drift.Value(_notesController.text) : const drift.Value.absent(),
        createdAt: now,
        updatedAt: now,
      ));

      if (_attachments.isNotEmpty) {
        final appDir = await getApplicationDocumentsDirectory();
        final attachmentsDir = Directory(p.join(appDir.path, 'promptforge', 'attachments', outputId));
        await attachmentsDir.create(recursive: true);

        for (final file in _attachments) {
          if (file.path != null) {
            final targetPath = p.join(attachmentsDir.path, file.name);
            await File(file.path!).copy(targetPath);
            
            String mimeType = 'application/octet-stream';
            final ext = p.extension(file.name).toLowerCase();
            if (ext == '.png') mimeType = 'image/png';
            else if (ext == '.jpg' || ext == '.jpeg') mimeType = 'image/jpeg';
            else if (ext == '.pdf') mimeType = 'application/pdf';
            else if (ext == '.json') mimeType = 'application/json';
            else if (ext == '.mp4') mimeType = 'video/mp4';

            await attachmentDao.createAttachment(LLMOutputAttachmentsCompanion.insert(
              id: const Uuid().v4(),
              outputId: outputId,
              fileName: file.name,
              mimeType: mimeType,
              sizeBytes: drift.Value(file.size),
              localPath: targetPath,
              attachmentType: drift.Value(_outputType),
              createdAt: now,
            ));
          }
        }
      }

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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedProviderId,
                        decoration: const InputDecoration(
                          labelText: 'Provider',
                          border: OutlineInputBorder(),
                        ),
                        items: _providers.map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(p.name, overflow: TextOverflow.ellipsis),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedProviderId = val;
                              _selectedModelId = _getModelsForProvider(val).first.id;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedModelId,
                        decoration: const InputDecoration(
                          labelText: 'Model',
                          border: OutlineInputBorder(),
                        ),
                        items: _selectedProviderId != null ? _getModelsForProvider(_selectedProviderId!).map((m) => DropdownMenuItem(
                          value: m.id,
                          child: Text(m.displayName, overflow: TextOverflow.ellipsis),
                        )).toList() : [],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedModelId = val);
                        },
                      ),
                    ),
                  ],
                ),
                if (_selectedModelId == 'custom') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _customModelController,
                    decoration: const InputDecoration(
                      labelText: 'Custom Model Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                  ),
                ],
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _outputType,
                  decoration: const InputDecoration(
                    labelText: 'Output Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'markdown', child: Text('Markdown')),
                    DropdownMenuItem(value: 'text', child: Text('Plain Text')),
                    DropdownMenuItem(value: 'code', child: Text('Code')),
                    DropdownMenuItem(value: 'json', child: Text('JSON')),
                    DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                    DropdownMenuItem(value: 'image', child: Text('Image')),
                    DropdownMenuItem(value: 'video', child: Text('Video')),
                    DropdownMenuItem(value: 'audio', child: Text('Audio')),
                    DropdownMenuItem(value: 'dataset', child: Text('Dataset / CSV')),
                    DropdownMenuItem(value: 'archive', child: Text('Archive / ZIP')),
                    DropdownMenuItem(value: 'mixed', child: Text('Mixed')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _outputType = val);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _outputController,
                  decoration: InputDecoration(
                    labelText: _outputType == 'image' || _outputType == 'pdf' || _outputType == 'video' || _outputType == 'audio' ? 'Text Notes (Optional)' : 'Pasted Output',
                    alignLabelWithHint: true,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 8,
                  minLines: 3,
                ),
                const SizedBox(height: 16),
                if (_attachments.isNotEmpty) ...[
                  Text('Attachments', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _attachments.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final file = entry.value;
                      return Chip(
                        label: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                        onDeleted: () => _removeAttachment(idx),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                ],
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: _pickFiles,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Attach Files'),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'e.g. temperature, prompt variant',
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
