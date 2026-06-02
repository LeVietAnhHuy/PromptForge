import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/database/database.dart';
import '../domain/inbox_processing_service.dart';

class InboxToPromptCardDialog extends ConsumerStatefulWidget {
  final InboxItem item;

  const InboxToPromptCardDialog({super.key, required this.item});

  @override
  ConsumerState<InboxToPromptCardDialog> createState() => _InboxToPromptCardDialogState();
}

class _InboxToPromptCardDialogState extends ConsumerState<InboxToPromptCardDialog> {
  late TextEditingController _titleController;
  late TextEditingController _purposeController;
  late TextEditingController _bodyController;
  late TextEditingController _notesController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: _deriveTitle());
    _purposeController = TextEditingController(text: 'Converted from Inbox capture');
    _bodyController = TextEditingController(text: widget.item.rawText);
    
    final dateStr = DateFormat.yMMMd().format(widget.item.createdAt);
    final sourceNote = widget.item.source != null ? ' Source: ${widget.item.source}.' : '';
    _notesController = TextEditingController(text: 'Captured on $dateStr.$sourceNote');
  }

  String _deriveTitle() {
    if (widget.item.title?.isNotEmpty == true && widget.item.title != 'Untitled Idea') {
      return widget.item.title!;
    }
    final lines = widget.item.rawText.split('\n');
    for (final line in lines) {
      if (line.trim().startsWith('# ')) {
        return line.trim().substring(2).trim();
      }
    }
    for (final line in lines) {
      if (line.trim().isNotEmpty) {
        final text = line.trim();
        return text.length > 40 ? '${text.substring(0, 40)}...' : text;
      }
    }
    return 'Untitled Inbox Prompt';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _purposeController.dispose();
    _bodyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _convert() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title cannot be empty')));
      return;
    }
    if (_bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Body cannot be empty')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final service = ref.read(inboxProcessingServiceProvider);
      final newPromptId = await service.convertToPromptCard(
        inboxId: widget.item.id,
        title: _titleController.text.trim(),
        purpose: _purposeController.text.trim(),
        body: _bodyController.text.trim(),
        targetNotes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Converted to Prompt Card!'),
            action: SnackBarAction(
              label: 'View Card',
              onPressed: () => context.go('/library/$newPromptId'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Prompt Card Title', border: OutlineInputBorder()),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _purposeController,
            decoration: const InputDecoration(labelText: 'Purpose', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Target Notes', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          const Text('Prompt Body:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _bodyController,
            maxLines: 8,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
    );

    if (isDesktop) {
      return AlertDialog(
        title: const Text('Convert to Prompt Card'),
        content: SizedBox(width: 500, child: content),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isSaving ? null : _convert,
            child: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save to Library'),
          ),
        ],
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Convert to Prompt Card'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          ),
          actions: [
            TextButton(
              onPressed: _isSaving ? null : _convert,
              child: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
            ),
          ],
        ),
        body: content,
      );
    }
  }
}
