import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/prompt_providers.dart';

class PromptLibraryScreen extends ConsumerWidget {
  const PromptLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promptsAsync = ref.watch(filteredPromptsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prompt Library'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search prompts...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
              ),
              onChanged: (value) =>
                  ref.read(promptSearchQueryProvider.notifier).state = value,
            ),
          ),
        ),
      ),
      body: promptsAsync.when(
        data: (prompts) {
          if (prompts.isEmpty) {
            return const Center(
              child: Text('No prompts found. Create one!'),
            );
          }

          return ListView.builder(
            itemCount: prompts.length,
            itemBuilder: (context, index) {
              final prompt = prompts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(prompt.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    prompt.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    '${prompt.updatedAt.year}-${prompt.updatedAt.month.toString().padLeft(2, '0')}-${prompt.updatedAt.day.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () => context.go('/library/editor/${prompt.id}'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/library/editor'),
        tooltip: 'New Prompt',
        child: const Icon(Icons.add),
      ),
    );
  }
}
