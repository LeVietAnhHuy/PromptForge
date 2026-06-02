import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';
import '../application/inbox_providers.dart';

class InboxEditorScreen extends ConsumerStatefulWidget {
  final String? itemId; // null means creating a new item

  const InboxEditorScreen({super.key, this.itemId});

  @override
  ConsumerState<InboxEditorScreen> createState() => _InboxEditorScreenState();
}

class _InboxEditorScreenState extends ConsumerState<InboxEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _sourceController = TextEditingController();

  InboxItem? _existingItem;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  Future<void> _loadItem() async {
    if (widget.itemId == null) {
      setState(() => _isLoading = false);
      return;
    }
    
    try {
      final dao = ref.read(inboxItemDaoProvider);
      final item = await dao.getInboxItemById(widget.itemId!);
      setState(() {
        _existingItem = item;
        if (item.title != null) _titleController.text = item.title!;
        _contentController.text = item.rawText;
        if (item.source != null) _sourceController.text = item.source!;
        _isLoading = false;
      });
    } catch (e) {
      // Error loading or not found
      setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    final dao = ref.read(inboxItemDaoProvider);
    final now = DateTime.now();
    final titleStr = _titleController.text.trim();
    final contentStr = _contentController.text.trim();
    final sourceStr = _sourceController.text.trim();

    if (contentStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content cannot be empty')),
      );
      return;
    }

    try {
      if (_existingItem == null) {
        await dao.createInboxItem(InboxItemsCompanion.insert(
          id: const Uuid().v4(),
          title: titleStr.isNotEmpty ? drift.Value(titleStr) : const drift.Value.absent(),
          rawText: contentStr,
          source: sourceStr.isNotEmpty ? drift.Value(sourceStr) : const drift.Value.absent(),
          createdAt: now,
          updatedAt: now,
        ));
      } else {
        await dao.updateInboxItem(InboxItemsCompanion(
          id: drift.Value(_existingItem!.id),
          title: drift.Value(titleStr.isNotEmpty ? titleStr : null),
          rawText: drift.Value(contentStr),
          source: drift.Value(sourceStr.isNotEmpty ? sourceStr : null),
          updatedAt: drift.Value(now),
          status: drift.Value(_existingItem!.status),
          createdAt: drift.Value(_existingItem!.createdAt),
        ));
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  Future<void> _archive() async {
    if (_existingItem != null) {
      final dao = ref.read(inboxItemDaoProvider);
      await dao.archiveInboxItem(_existingItem!.id);
    }
    if (mounted) context.pop();
  }

  Future<void> _convertToPrompt() async {
    if (_existingItem == null) return;
    
    // Ensure changes are saved to memory before converting if user edited without saving
    final updatedItem = _existingItem!.copyWith(
      title: drift.Value(_titleController.text.trim().isNotEmpty ? _titleController.text.trim() : null),
      rawText: _contentController.text.trim(),
      source: drift.Value(_sourceController.text.trim().isNotEmpty ? _sourceController.text.trim() : null),
    );

    final service = ref.read(inboxServiceProvider);
    try {
      await service.convertToPrompt(updatedItem);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully converted to Prompt Library!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to convert: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isNew = _existingItem == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'Capture Idea' : 'Edit Inbox Item'),
        actions: [
          if (!isNew)
            IconButton(
              icon: const Icon(Icons.archive),
              onPressed: _archive,
              tooltip: 'Archive',
            ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
            tooltip: 'Save',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Raw Content',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: null,
                expands: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _sourceController,
              decoration: const InputDecoration(
                labelText: 'Source/Note (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (!isNew)
              ElevatedButton.icon(
                onPressed: _convertToPrompt,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Convert to Prompt Library'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
