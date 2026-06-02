import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';
import '../domain/inbox_processing_service.dart';

class InboxToWorkspaceRunDialog extends ConsumerStatefulWidget {
  final InboxItem item;

  const InboxToWorkspaceRunDialog({super.key, required this.item});

  @override
  ConsumerState<InboxToWorkspaceRunDialog> createState() => _InboxToWorkspaceRunDialogState();
}

class _InboxToWorkspaceRunDialogState extends ConsumerState<InboxToWorkspaceRunDialog> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  String? _selectedProjectId;
  List<Project> _projects = [];
  bool _isLoadingProjects = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: _deriveTitle());
    _bodyController = TextEditingController(text: widget.item.rawText);
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final projectDao = ref.read(projectDaoProvider);
      final projects = await projectDao.getActiveProjects();
      if (mounted) {
        setState(() {
          _projects = projects;
          if (_projects.isNotEmpty) {
            _selectedProjectId = _projects.first.id;
          }
          _isLoadingProjects = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingProjects = false);
    }
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
    return 'Untitled Inbox Run';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
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
    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a project')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final service = ref.read(inboxProcessingServiceProvider);
      final newRunId = await service.convertToWorkspaceRun(
        inboxId: widget.item.id,
        projectId: _selectedProjectId!,
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Converted to Workspace Run!'),
            action: SnackBarAction(
              label: 'Open Workspace',
              onPressed: () => context.go('/workspace/project/$_selectedProjectId/run/$newRunId'),
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

    final content = _isLoadingProjects
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Target Project',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _selectedProjectId,
                  items: _projects.map((p) {
                    return DropdownMenuItem(
                      value: p.id,
                      child: Text(p.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedProjectId = val);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Run Title', border: OutlineInputBorder()),
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
        title: const Text('Convert to Workspace Run'),
        content: SizedBox(width: 500, child: content),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isSaving || _selectedProjectId == null ? null : _convert,
            child: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save to Workspace'),
          ),
        ],
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Convert to Workspace Run'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          ),
          actions: [
            TextButton(
              onPressed: _isSaving || _selectedProjectId == null ? null : _convert,
              child: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
            ),
          ],
        ),
        body: content,
      );
    }
  }
}
