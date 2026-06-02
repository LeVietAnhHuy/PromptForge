import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/database_providers.dart';

class PromptExamplesScreen extends ConsumerWidget {
  final String promptId;

  const PromptExamplesScreen({super.key, required this.promptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examplesStream = ref.watch(promptExampleDaoProvider).watchExamplesForPrompt(promptId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prompt Examples & Comparisons'),
      ),
      body: StreamBuilder(
        stream: examplesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final examples = snapshot.data ?? [];
          if (examples.isEmpty) {
            return const Center(
              child: Text('No examples found. Compile this prompt to save one!'),
            );
          }

          return ListView.builder(
            itemCount: examples.length,
            itemBuilder: (context, index) {
              final example = examples[index];
              return ListTile(
                title: Text(example.title),
                subtitle: Text('Created: ${example.createdAt.toLocal().toString().split('.')[0]}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.go('/library/examples/$promptId/compare/${example.id}');
                },
              );
            },
          );
        },
      ),
    );
  }
}
