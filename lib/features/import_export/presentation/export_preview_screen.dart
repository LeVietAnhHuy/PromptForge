import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/import_export_service.dart';

class ExportPreviewScreen extends ConsumerStatefulWidget {
  const ExportPreviewScreen({super.key});

  @override
  ConsumerState<ExportPreviewScreen> createState() => _ExportPreviewScreenState();
}

class _ExportPreviewScreenState extends ConsumerState<ExportPreviewScreen> {
  String? _jsonOutput;
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
      setState(() {
        _jsonOutput = json;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _copyToClipboard() async {
    if (_jsonOutput != null) {
      await Clipboard.setData(ClipboardData(text: _jsonOutput!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export JSON copied to clipboard!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Preview'),
        actions: [
          if (_jsonOutput != null)
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Copy JSON',
              onPressed: _copyToClipboard,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        _jsonOutput!,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                  ),
                ),
    );
  }
}
