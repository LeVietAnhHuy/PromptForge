import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/import_export_codec.dart';
import '../application/import_export_service.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  final _textController = TextEditingController();
  ImportPreview? _preview;
  String? _error;
  bool _isImporting = false;

  void _previewImport() {
    setState(() {
      _error = null;
      _preview = null;
    });
    final jsonText = _textController.text.trim();
    if (jsonText.isEmpty) {
      setState(() {
        _error = 'Please paste JSON data first.';
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
      await service.importData(_preview!);
      
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
  void dispose() {
    _textController.dispose();
    super.dispose();
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
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Paste JSON Data',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 10,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _previewImport,
              child: const Text('Preview Import'),
            ),
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
