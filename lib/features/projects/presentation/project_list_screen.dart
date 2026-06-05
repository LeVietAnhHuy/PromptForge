import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:drift/drift.dart' as drift;

import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';
import '../../../shared/widgets/empty_state.dart';

class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectDao = ref.watch(projectDaoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Workspace'),
      ),
      body: StreamBuilder<List<Project>>(
        stream: projectDao.watchActiveProjects(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final projects = snapshot.data ?? [];
          if (projects.isEmpty) {
            return const EmptyState(
              icon: Icons.workspaces_outlined,
              title: 'No workspaces yet',
              message: 'No projects yet. Create one!',
            );
          }

          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final p = projects[index];
              return ListTile(
                title: Text(p.name),
                subtitle: p.description != null ? Text(p.description!) : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.go('/projects/${p.id}');
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final titleController = TextEditingController();
          final descController = TextEditingController();
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('New Project'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    autofocus: true,
                  ),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => context.pop(true),
                  child: const Text('Create'),
                ),
              ],
            ),
          );

          if (result == true && titleController.text.isNotEmpty) {
            final id = const Uuid().v4();
            final now = DateTime.now();
            await projectDao.createProject(ProjectsCompanion.insert(
              id: id,
              name: titleController.text,
              description: drift.Value(
                  descController.text.isNotEmpty ? descController.text : null),
              createdAt: now,
              updatedAt: now,
            ));
            if (context.mounted) {
              context.go('/projects/$id');
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
