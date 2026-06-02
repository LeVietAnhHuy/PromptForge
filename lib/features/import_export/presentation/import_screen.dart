import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_selector/file_selector.dart';
import '../domain/import_export_codec.dart';
import '../application/import_export_service.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  String? _selectedFilePath;
  ImportPreview? _preview;
  String? _error;
  bool _isImporting = false;
  MergeStrategy _strategy = MergeStrategy.skip;

  Future<void> _pickFile() async {
    try {
      final XFile? file = await openFile(
        acceptedTypeGroups: [
          const XTypeGroup(label: 'JSON Files', extensions: ['json']),
        ],
      );
      
      if (file != null) {
        final content = await file.readAsString();
        setState(() {
          _selectedFilePath = file.path;
          _error = null;
          _preview = null;
        });
        _previewImport(content);
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to read file: $e';
      });
    }
  }

  void _previewImport(String jsonText) {
    if (jsonText.isEmpty) {
      setState(() {
        _error = 'File is empty.';
      });
      return;
    }

    try {
      final preview = ImportExportCodec.decodeImport(jsonText);
      setState(() {
        _preview = preview;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _confirmImport() async {
    if (_preview == null) return;
    setState(() {
      _isImporting = true;
    });

    try {
      final service = ref.read(importExportServiceProvider);
      await service.importData(_preview!, strategy: _strategy);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Import successful!')),
        );
        context.pop();
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to import: $e';
        _isImporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Data'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.file_open),
              label: const Text('Select JSON File'),
              onPressed: _pickFile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16.0),
              ),
            ),
            if (_selectedFilePath != null) ...[
              const SizedBox(height: 8),
              Text('Selected: $_selectedFilePath', style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 24),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (_preview != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Import Summary', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('Valid Prompts: ${_preview!.promptCount}'),
                      Text('Valid Context Packs: ${_preview!.contextPackCount}'),
                      Text(
                        'Invalid Records Skipped: ${_preview!.invalidRecordsCount}',
                        style: TextStyle(
                          color: _preview!.invalidRecordsCount > 0 
                              ? Theme.of(context).colorScheme.error 
                              : null,
                        ),
                      ),
                      const Divider(height: 32),
                      Text('Merge Strategy (if IDs conflict):', style: Theme.of(context).textTheme.titleMedium),
                      RadioListTile<MergeStrategy>(
                        title: const Text('Skip Duplicate (Keep Existing)'),
                        value: MergeStrategy.skip,
                        groupValue: _strategy,
                        onChanged: (val) => setState(() => _strategy = val!),
                      ),
                      RadioListTile<MergeStrategy>(
                        title: const Text('Overwrite Existing'),
                        value: MergeStrategy.overwrite,
                        groupValue: _strategy,
                        onChanged: (val) => setState(() => _strategy = val!),
                      ),
                      RadioListTile<MergeStrategy>(
                        title: const Text('Duplicate (Generate New ID)'),
                        value: MergeStrategy.duplicate,
                        groupValue: _strategy,
                        onChanged: (val) => setState(() => _strategy = val!),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isImporting ? null : _confirmImport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                          child: _isImporting 
                              ? const CircularProgressIndicator() 
                              : const Text('Confirm Import'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
