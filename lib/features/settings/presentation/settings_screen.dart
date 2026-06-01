import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export Data'),
            subtitle: const Text('Export your prompts and context packs to JSON.'),
            onTap: () {
              context.go('/settings/export');
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import Data'),
            subtitle: const Text('Import prompts and context packs from JSON.'),
            onTap: () {
              context.go('/settings/import');
            },
          ),
        ],
      ),
    );
  }
}
