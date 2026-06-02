import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/security/secure_storage_service.dart';

class ApiKeysScreen extends ConsumerStatefulWidget {
  const ApiKeysScreen({super.key});

  @override
  ConsumerState<ApiKeysScreen> createState() => _ApiKeysScreenState();
}

class _ApiKeysScreenState extends ConsumerState<ApiKeysScreen> {
  final Map<String, TextEditingController> _controllers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKeys();
  }

  Future<void> _loadKeys() async {
    final storage = ref.read(secureStorageProvider);
    final geminiKey = await storage.getApiKey('gemini') ?? '';
    
    _controllers['gemini'] = TextEditingController(text: geminiKey);
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveKey(String providerId) async {
    final storage = ref.read(secureStorageProvider);
    final key = _controllers[providerId]!.text.trim();
    
    if (key.isEmpty) {
      await storage.deleteApiKey(providerId);
    } else {
      await storage.saveApiKey(providerId, key);
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved API Key for $providerId.')),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Keys'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Text(
              'Keys are stored securely on your device. '
              'Prompts are sent to the selected provider only when you explicitly run them.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          _buildKeyInput('gemini', 'Google Gemini API Key'),
        ],
      ),
    );
  }

  Widget _buildKeyInput(String providerId, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controllers[providerId],
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter API Key',
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () => _saveKey(providerId),
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}
