import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectDao = ref.watch(projectDaoProvider);
    final exampleDao = ref.watch(promptExampleDaoProvider);

    return FutureBuilder<Project>(
      future: projectDao.getProjectById(projectId),
      builder: (context, projectSnapshot) {
        if (projectSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (projectSnapshot.hasError || !projectSnapshot.hasData) {
          return const Scaffold(body: Center(child: Text('Project not found')));
        }

        final project = projectSnapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(project.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // TODO: Project Settings
                },
              ),
            ],
          ),
          body: StreamBuilder<List<PromptExample>>(
            stream: exampleDao.watchExamplesForProject(projectId),
            builder: (context, runSnapshot) {
              if (runSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final runs = runSnapshot.data ?? [];
              if (runs.isEmpty) {
                return const Center(child: Text('No prompt runs yet.'));
              }

              return ListView.builder(
                itemCount: runs.length,
                itemBuilder: (context, index) {
                  final run = runs[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(run.title.isNotEmpty ? run.title : 'Untitled Run'),
                      subtitle: Text('Created: ${run.createdAt.toString().split('.')[0]}'),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        context.go('/projects/$projectId/runs/${run.id}');
                      },
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              context.go('/projects/$projectId/runs/new');
            },
            icon: const Icon(Icons.add),
            label: const Text('New Run'),
          ),
        );
      },
    );
  }
}
