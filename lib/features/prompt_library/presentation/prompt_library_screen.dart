import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/database_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../application/prompt_providers.dart';

class PromptLibraryScreen extends ConsumerWidget {
  const PromptLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promptsAsync = ref.watch(filteredPromptsProvider);
    final allTagsAsync = ref.watch(allTagsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prompt Library'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search prompts...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) => ref
                      .read(promptSearchQueryProvider.notifier)
                      .state = value,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16.0,
                  runSpacing: 8.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Sort Dropdown
                    DropdownButton<PromptSortOption>(
                      value: ref.watch(promptSortProvider),
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(promptSortProvider.notifier).state = val;
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                            value: PromptSortOption.recentlyUpdated,
                            child: Text('Recently Updated')),
                        DropdownMenuItem(
                            value: PromptSortOption.recentlyCreated,
                            child: Text('Recently Created')),
                        DropdownMenuItem(
                            value: PromptSortOption.titleAZ,
                            child: Text('Title A-Z')),
                        DropdownMenuItem(
                            value: PromptSortOption.mostUsed,
                            child: Text('Most Used')),
                      ],
                    ),
                    // Tag Filter Dropdown
                    allTagsAsync.when(
                      data: (tags) {
                        final currentTagId = ref.watch(promptFilterTagProvider);
                        return DropdownButton<String?>(
                          value: currentTagId,
                          hint: const Text('Filter by Tag'),
                          onChanged: (val) {
                            ref.read(promptFilterTagProvider.notifier).state =
                                val;
                          },
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('All Tags'),
                            ),
                            ...tags.map((t) => DropdownMenuItem(
                                  value: t.id,
                                  child: Text(t.name),
                                )),
                          ],
                        );
                      },
                      loading: () => const SizedBox(
                          width: 100, child: LinearProgressIndicator()),
                      error: (_, __) => const Text('Error loading tags'),
                    ),
                    // Favorite Filter Toggle
                    FilterChip(
                      label: const Text('Favorites'),
                      selected: ref.watch(promptFavoriteFilterProvider),
                      onSelected: (val) {
                        ref.read(promptFavoriteFilterProvider.notifier).state =
                            val;
                      },
                      avatar: const Icon(Icons.star, size: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: promptsAsync.when(
              data: (promptsWithTags) {
                if (promptsWithTags.isEmpty) {
                  return EmptyState(
                    icon: Icons.auto_awesome_outlined,
                    title: 'Your prompt library is empty',
                    message: 'No prompts found. Create one!',
                    actionLabel: 'New Prompt',
                    onAction: () => context.go('/library/editor'),
                  );
                }

                return ListView.builder(
                  itemCount: promptsWithTags.length,
                  itemBuilder: (context, index) {
                    final pwt = promptsWithTags[index];
                    final prompt = pwt.prompt;
                    final tags = pwt.tags;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: InkWell(
                        onTap: () => context.go('/library/editor/${prompt.id}'),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      prompt.title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      prompt.isFavorite
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: prompt.isFavorite
                                          ? Colors.amber
                                          : null,
                                    ),
                                    onPressed: () {
                                      ref
                                          .read(promptDaoProvider)
                                          .toggleFavorite(
                                              prompt.id, !prompt.isFavorite);
                                    },
                                  ),
                                ],
                              ),
                              if (tags.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Wrap(
                                    spacing: 4.0,
                                    runSpacing: 4.0,
                                    children: tags
                                        .map((t) => Chip(
                                              label: Text(t.name),
                                              padding: EdgeInsets.zero,
                                              labelStyle:
                                                  const TextStyle(fontSize: 12),
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ))
                                        .toList(),
                                  ),
                                ),
                              Text(
                                prompt.body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Updated: ${prompt.updatedAt.year}-${prompt.updatedAt.month.toString().padLeft(2, '0')}-${prompt.updatedAt.day.toString().padLeft(2, '0')}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/library/editor'),
        tooltip: 'New Prompt',
        child: const Icon(Icons.add),
      ),
    );
  }
}
