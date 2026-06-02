import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:drift/drift.dart' as drift;

class PromptVersionHistoryScreen extends ConsumerWidget {
  final String promptId;

  const PromptVersionHistoryScreen({super.key, required this.promptId});

  Future<void> _restoreVersion(BuildContext context, WidgetRef ref, PromptVersion version) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Version'),
        content: const Text('This will overwrite the current prompt with this older version. A snapshot of the current state will be created first. Are you sure?'),
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
      final promptDao = ref.read(promptDaoProvider);
      final tagDao = ref.read(tagDaoProvider);
      final pvDao = ref.read(promptVariableDaoProvider);

      await db.transaction(() async {
        // 1. Fetch current live state
        final livePrompt = await promptDao.getPromptById(promptId);
        final liveTags = await tagDao.getTagsForPrompt(promptId);
        final liveVars = await pvDao.getVariablesForPrompt(promptId);
        
        final liveTagNames = liveTags.map((t) => t.name).toList();
        
        // 2. Snapshot current live state
        final tagsJsonStr = jsonEncode(liveTagNames);
        final varsJsonStr = jsonEncode(liveVars.map((v) => {
          'name': v.name,
          'label': v.label,
          'description': v.description,
          'defaultValue': v.defaultValue,
          'exampleValue': v.exampleValue,
          'isRequired': v.isRequired,
        }).toList());

        await promptDao.createPromptVersion(PromptVersionsCompanion.insert(
          id: const Uuid().v4(),
          promptId: promptId,
          title: livePrompt.title,
          body: livePrompt.body,
          tagsJson: drift.Value(tagsJsonStr),
          variableMetadataJson: drift.Value(varsJsonStr),
          createdAt: DateTime.now(),
        ));

        // 3. Overwrite current state with version data
        await promptDao.updatePrompt(PromptsCompanion.insert(
          id: promptId,
          title: version.title,
          body: version.body,
          createdAt: livePrompt.createdAt,
          updatedAt: DateTime.now(),
        ));

        if (version.tagsJson != null) {
          final List<dynamic> decodedTags = jsonDecode(version.tagsJson!);
          final tagNames = decodedTags.map((e) => e.toString()).toList();
          await tagDao.replaceTagsForPrompt(promptId, tagNames);
        }

        if (version.variableMetadataJson != null) {
          final List<dynamic> decodedVars = jsonDecode(version.variableMetadataJson!);
          int order = 0;
          final varCompanions = decodedVars.map((vMap) {
            return PromptVariablesCompanion.insert(
              id: const Uuid().v4(),
              promptId: promptId,
              name: vMap['name'] as String,
              label: vMap['label'] != null ? drift.Value(vMap['label'] as String) : const drift.Value.absent(),
              description: vMap['description'] != null ? drift.Value(vMap['description'] as String) : const drift.Value.absent(),
              defaultValue: vMap['defaultValue'] != null ? drift.Value(vMap['defaultValue'] as String) : const drift.Value.absent(),
              exampleValue: vMap['exampleValue'] != null ? drift.Value(vMap['exampleValue'] as String) : const drift.Value.absent(),
              isRequired: drift.Value(vMap['isRequired'] as bool? ?? true),
              sortOrder: drift.Value(order++),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }).toList();
          await pvDao.syncVariablesForPrompt(promptId, varCompanions);
        }
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

  void _showVersionDetails(BuildContext context, WidgetRef ref, PromptVersion version) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(version.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Created: ${version.createdAt.toLocal().toString().split('.')[0]}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Body:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(version.body),
              if (version.tagsJson != null) ...[
                const SizedBox(height: 16),
                const Text('Tags:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(version.tagsJson!),
              ],
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
    final promptDao = ref.watch(promptDaoProvider);
    final versionStream = promptDao.watchPromptVersions(promptId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prompt Version History'),
      ),
      body: StreamBuilder<List<PromptVersion>>(
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
                title: Text(version.title),
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
