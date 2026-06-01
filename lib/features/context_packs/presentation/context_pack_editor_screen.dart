import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:drift/drift.dart' as drift;
import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';

class ContextPackEditorScreen extends ConsumerStatefulWidget {
  final String? packId;

  const ContextPackEditorScreen({super.key, this.packId});

  @override
  ConsumerState<ContextPackEditorScreen> createState() => _ContextPackEditorScreenState();
}

class _ContextPackEditorScreenState extends ConsumerState<ContextPackEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  
  ContextPack? _existingPack;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPack();
  }

  Future<void> _loadPack() async {
    if (widget.packId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final db = ref.read(databaseProvider);
      final pack = await (db.select(db.contextPacks)..where((t) => t.id.equals(widget.packId!))).getSingle();
      
      setState(() {
        _existingPack = pack;
        _titleController.text = pack.name;
        _descriptionController.text = pack.description ?? '';
        _contentController.text = pack.content;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load context pack: $e')),
        );
        context.pop();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _savePack() async {
    if (!_formKey.currentState!.validate()) return;

    final dao = ref.read(contextPackDaoProvider);
    final now = DateTime.now();

    try {
      if (_existingPack == null) {
        // Create new
        await dao.createContextPack(ContextPacksCompanion.insert(
          id: const Uuid().v4(),
          name: _titleController.text,
          description: _descriptionController.text.isNotEmpty ? drift.Value(_descriptionController.text) : const drift.Value.absent(),
          content: _contentController.text,
          createdAt: now,
          updatedAt: now,
        ));
      } else {
        // Update existing
        await dao.updateContextPack(ContextPacksCompanion.insert(
          id: _existingPack!.id,
          name: _titleController.text,
          description: _descriptionController.text.isNotEmpty ? drift.Value(_descriptionController.text) : const drift.Value.absent(),
          content: _contentController.text,
          createdAt: _existingPack!.createdAt,
          updatedAt: now,
        ));
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save context pack: $e')),
        );
      }
    }
  }

  Future<void> _deletePack() async {
    if (_existingPack == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Context Pack'),
        content: const Text('Are you sure you want to delete this context pack?'),
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
      final dao = ref.read(contextPackDaoProvider);
      await dao.archiveContextPack(_existingPack!.id);
      
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

    final isEditing = _existingPack != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Context Pack' : 'New Context Pack'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete',
              onPressed: _deletePack,
            ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: _savePack,
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
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Context Content',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 15,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter context content';
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
