import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:drift/drift.dart' as drift;
import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';

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
  
  Prompt? _existingPrompt;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrompt();
  }

  Future<void> _loadPrompt() async {
    if (widget.promptId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final promptDao = ref.read(promptDaoProvider);
      final prompt = await promptDao.getPromptById(widget.promptId!);
      
      setState(() {
        _existingPrompt = prompt;
        _titleController.text = prompt.title;
        _bodyController.text = prompt.body;
        _purposeController.text = prompt.purpose ?? '';
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
    _titleController.dispose();
    _bodyController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _savePrompt() async {
    if (!_formKey.currentState!.validate()) return;

    final promptDao = ref.read(promptDaoProvider);
    final now = DateTime.now();

    try {
      if (_existingPrompt == null) {
        // Create new
        await promptDao.createPrompt(PromptsCompanion.insert(
          id: const Uuid().v4(),
          title: _titleController.text,
          body: _bodyController.text,
          purpose: _purposeController.text.isNotEmpty ? drift.Value(_purposeController.text) : const drift.Value.absent(),
          createdAt: now,
          updatedAt: now,
        ));
      } else {
        // Update existing
        await promptDao.updatePrompt(PromptsCompanion.insert(
          id: _existingPrompt!.id,
          title: _titleController.text,
          body: _bodyController.text,
          purpose: _purposeController.text.isNotEmpty ? drift.Value(_purposeController.text) : const drift.Value.absent(),
          createdAt: _existingPrompt!.createdAt,
          updatedAt: now,
        ));
      }

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
    final now = DateTime.now();

    try {
      await promptDao.createPrompt(PromptsCompanion.insert(
        id: const Uuid().v4(),
        title: '${_existingPrompt!.title} (Copy)',
        body: _existingPrompt!.body,
        purpose: _existingPrompt!.purpose != null ? drift.Value(_existingPrompt!.purpose!) : const drift.Value.absent(),
        createdAt: now,
        updatedAt: now,
      ));

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
              icon: const Icon(Icons.play_arrow),
              tooltip: 'Use Prompt (Compile)',
              onPressed: () => context.go('/library/compile/${_existingPrompt!.id}'),
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
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Prompt Body',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 15,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the prompt body';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
