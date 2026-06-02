import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

class ContextPackVersionHistoryScreen extends ConsumerWidget {
  final String packId;

  const ContextPackVersionHistoryScreen({super.key, required this.packId});

  Future<void> _restoreVersion(BuildContext context, WidgetRef ref, ContextPackVersion version) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Version'),
        content: const Text('This will overwrite the current context pack with this older version. A snapshot of the current state will be created first. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final db = ref.read(databaseProvider);
      final cpDao = ref.read(contextPackDaoProvider);

      await db.transaction(() async {
        // 1. Fetch current live state
        final livePacks = await cpDao.getAllContextPacks();
        final livePack = livePacks.firstWhere((p) => p.id == packId);
        
        // 2. Snapshot current live state
        await cpDao.createContextPackVersion(ContextPackVersionsCompanion.insert(
          id: const Uuid().v4(),
          contextPackId: packId,
          name: livePack.name,
          description: livePack.description != null ? drift.Value(livePack.description!) : const drift.Value.absent(),
          content: livePack.content,
          createdAt: DateTime.now(),
        ));

        // 3. Overwrite current state with version data
        await cpDao.updateContextPack(ContextPacksCompanion.insert(
          id: packId,
          name: version.name,
          description: version.description != null ? drift.Value(version.description!) : const drift.Value.absent(),
          content: version.content,
          createdAt: livePack.createdAt,
          updatedAt: DateTime.now(),
        ));
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Version restored successfully')));
        context.pop(); // Go back to editor
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to restore: $e')));
      }
    }
  }

  void _showVersionDetails(BuildContext context, WidgetRef ref, ContextPackVersion version) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(version.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Created: ${version.createdAt.toLocal().toString().split('.')[0]}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(version.description ?? 'None'),
              const SizedBox(height: 16),
              const Text('Content:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(version.content),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              _restoreVersion(context, ref, version);
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cpDao = ref.watch(contextPackDaoProvider);
    final versionStream = cpDao.watchContextPackVersions(packId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Context Pack Version History'),
      ),
      body: StreamBuilder<List<ContextPackVersion>>(
        stream: versionStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final versions = snapshot.data ?? [];

          if (versions.isEmpty) {
            return const Center(child: Text('No previous versions available.'));
          }

          return ListView.builder(
            itemCount: versions.length,
            itemBuilder: (context, index) {
              final version = versions[index];
              return ListTile(
                title: Text(version.name),
                subtitle: Text(version.createdAt.toLocal().toString().split('.')[0]),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showVersionDetails(context, ref, version),
              );
            },
          );
        },
      ),
    );
  }
}
