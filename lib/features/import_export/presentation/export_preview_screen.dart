import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_selector/file_selector.dart';
import '../application/import_export_service.dart';
import '../domain/import_export_codec.dart';

class ExportPreviewScreen extends ConsumerStatefulWidget {
  const ExportPreviewScreen({super.key});

  @override
  ConsumerState<ExportPreviewScreen> createState() => _ExportPreviewScreenState();
}

class _ExportPreviewScreenState extends ConsumerState<ExportPreviewScreen> {
  List<int>? _zipBytes;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateExport();
  }

  Future<void> _generateExport() async {
    try {
      final service = ref.read(importExportServiceProvider);
      final json = await service.exportActiveData();
      final zip = ImportExportCodec.encodeBackupBundle(json);
      setState(() {
        _zipBytes = zip;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveToFile() async {
    if (_zipBytes == null) return;
    try {
      final FileSaveLocation? result = await getSaveLocation(
        suggestedName: 'promptforge_backup_${DateTime.now().millisecondsSinceEpoch}.promptforge',
        acceptedTypeGroups: [
          const XTypeGroup(label: 'PromptForge Backup', extensions: ['promptforge']),
        ],
      );

      if (result != null) {
        final file = XFile.fromData(
          Uint8List.fromList(_zipBytes!),
          mimeType: 'application/zip',
        );
        await file.saveTo(result.path);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved to ${result.path}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save file: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup Data'),
        actions: [
          if (_zipBytes != null)
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Save Backup',
              onPressed: _saveToFile,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.backup, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'Backup bundle is ready.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Size: ${(_zipBytes!.length / 1024).toStringAsFixed(2)} KB',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text('Save Backup to Disk'),
                          onPressed: _saveToFile,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
