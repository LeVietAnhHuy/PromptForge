import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/database.dart';
import '../domain/prompt_run_converter_service.dart';

class PromptCardConversionDialog extends ConsumerStatefulWidget {
  final PromptExample run;
  final String initialPurpose;
  final String initialTargetNotes;

  const PromptCardConversionDialog({
    super.key,
    required this.run,
    required this.initialPurpose,
    required this.initialTargetNotes,
  });

  @override
  ConsumerState<PromptCardConversionDialog> createState() => _PromptCardConversionDialogState();
}

class _PromptCardConversionDialogState extends ConsumerState<PromptCardConversionDialog> {
  late TextEditingController _titleController;
  late TextEditingController _purposeController;
  late TextEditingController _notesController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: _deriveTitle());
    _purposeController = TextEditingController(text: widget.initialPurpose);
    _notesController = TextEditingController(text: widget.initialTargetNotes);
  }

  String _deriveTitle() {
    if (widget.run.title.isNotEmpty && widget.run.title != 'Untitled Run') {
      return widget.run.title;
    }
    final lines = widget.run.compiledPrompt.split('\n');
    for (final line in lines) {
      if (line.startsWith('# ')) {
        return line.substring(2).trim();
      }
    }
    return 'Untitled Workspace Prompt';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _purposeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _convert() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title cannot be empty')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final service = ref.read(promptRunConverterServiceProvider);
      final newPromptId = await service.convertRunToPromptCard(
        runId: widget.run.id,
        title: _titleController.text.trim(),
        purpose: _purposeController.text.trim(),
        targetNotes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Saved to Library!'),
            action: SnackBarAction(
              label: 'View Card',
              onPressed: () {
                context.go('/library/$newPromptId');
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
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
            decoration: const InputDecoration(
              labelText: 'Prompt Card Title',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _purposeController,
            decoration: const InputDecoration(
              labelText: 'Purpose',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Target Notes (e.g. Models used)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Prompt Body Preview:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            width: double.infinity,
            child: Text(
              widget.run.compiledPrompt,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (isDesktop) {
      return AlertDialog(
        title: const Text('Save as Prompt Card'),
        content: SizedBox(
          width: 500,
          child: content,
        ),
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
          title: const Text('Save as Prompt Card'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          ),
          actions: [
            TextButton(
              onPressed: _isSaving ? null : _convert,
              child: _isSaving 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Text('Save'),
            ),
          ],
        ),
        body: content,
      );
    }
  }
}
