import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';
import '../application/inbox_providers.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class InboxEditorScreen extends ConsumerStatefulWidget {
  final String? itemId; // null means creating a new item

  const InboxEditorScreen({super.key, this.itemId});

  @override
  ConsumerState<InboxEditorScreen> createState() => _InboxEditorScreenState();
}

enum _ViewMode { edit, preview, split }

class _InboxEditorScreenState extends ConsumerState<InboxEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _sourceController = TextEditingController();

  InboxItem? _existingItem;
  bool _isLoading = true;
  _ViewMode _viewMode = _ViewMode.edit;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Raw Content', style: Theme.of(context).textTheme.titleSmall),
                SegmentedButton<_ViewMode>(
                  segments: [
                    const ButtonSegment(value: _ViewMode.edit, label: Text('Edit')),
                    const ButtonSegment(value: _ViewMode.preview, label: Text('Preview')),
                    if (MediaQuery.of(context).size.width >= 600)
                      const ButtonSegment(value: _ViewMode.split, label: Text('Split')),
                  ],
                  selected: {_viewMode},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _viewMode = newSelection.first;
                      // Keep state in sync if content was edited in split or edit modes
                      if (_viewMode == _ViewMode.preview) {
                        FocusScope.of(context).unfocus();
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: _buildContentView(MediaQuery.of(context).size.width >= 600),
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

  Widget _buildContentView(bool isDesktop) {
    // If mobile and somehow ended up in split view, force edit mode.
    if (!isDesktop && _viewMode == _ViewMode.split) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _viewMode = _ViewMode.edit);
      });
    }
    
    final mode = (!isDesktop && _viewMode == _ViewMode.split) ? _ViewMode.edit : _viewMode;

    switch (mode) {
      case _ViewMode.edit:
        return _buildEditor();
      case _ViewMode.preview:
        return _buildPreview();
      case _ViewMode.split:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildEditor()),
            VerticalDivider(width: 1, color: Theme.of(context).colorScheme.outline),
            Expanded(child: _buildPreview()),
          ],
        );
    }
  }

  Widget _buildEditor() {
    return TextField(
      controller: _contentController,
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(12),
        hintText: 'Enter raw markdown content...',
      ),
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      onChanged: (_) {
        if (_viewMode == _ViewMode.split) {
          setState(() {}); // Rebuild to update preview
        }
      },
    );
  }

  Widget _buildPreview() {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: _contentController.text.trim().isEmpty
          ? const Center(
              child: Text(
                'Nothing to preview yet.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : Markdown(
              data: _contentController.text,
              selectable: true,
              padding: const EdgeInsets.all(16),
            ),
    );
  }
}
