import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';

class PromptWithTags {
  final Prompt prompt;
  final List<Tag> tags;

  PromptWithTags({required this.prompt, required this.tags});
}

enum PromptSortOption {
  recentlyUpdated,
  recentlyCreated,
  titleAZ,
  mostUsed,
}

final promptSearchQueryProvider = StateProvider<String>((ref) => '');
final promptFilterTagProvider = StateProvider<String?>((ref) => null);
final promptFavoriteFilterProvider = StateProvider<bool>((ref) => false);
final promptSortProvider = StateProvider<PromptSortOption>((ref) => PromptSortOption.recentlyUpdated);

final allPromptsProvider = StreamProvider<List<Prompt>>((ref) {
  return ref.watch(promptDaoProvider).watchAllPrompts();
});

final allTagsProvider = StreamProvider<List<Tag>>((ref) {
  return ref.watch(tagDaoProvider).watchAllTags();
});

final allPromptTagsProvider = StreamProvider<List<PromptTag>>((ref) {
  return ref.watch(tagDaoProvider).watchAllPromptTags();
});

final promptsWithTagsProvider = Provider<AsyncValue<List<PromptWithTags>>>((ref) {
  final promptsAsync = ref.watch(allPromptsProvider);
  final tagsAsync = ref.watch(allTagsProvider);
  final promptTagsAsync = ref.watch(allPromptTagsProvider);

  if (promptsAsync.isLoading || tagsAsync.isLoading || promptTagsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (promptsAsync.hasError) return AsyncValue.error(promptsAsync.error!, promptsAsync.stackTrace!);
  if (tagsAsync.hasError) return AsyncValue.error(tagsAsync.error!, tagsAsync.stackTrace!);
  if (promptTagsAsync.hasError) return AsyncValue.error(promptTagsAsync.error!, promptTagsAsync.stackTrace!);

  final prompts = promptsAsync.value ?? [];
  final tags = tagsAsync.value ?? [];
  final promptTags = promptTagsAsync.value ?? [];

  final tagMap = {for (var tag in tags) tag.id: tag};
  final promptIdToTags = <String, List<Tag>>{};

  for (final pt in promptTags) {
    final tag = tagMap[pt.tagId];
    if (tag != null) {
      promptIdToTags.putIfAbsent(pt.promptId, () => []).add(tag);
    }
  }

  final combined = prompts.map((p) {
    return PromptWithTags(
      prompt: p,
      tags: promptIdToTags[p.id] ?? [],
    );
  }).toList();

  return AsyncValue.data(combined);
});

final filteredPromptsProvider = Provider<AsyncValue<List<PromptWithTags>>>((ref) {
  final promptsWithTagsAsync = ref.watch(promptsWithTagsProvider);

  if (promptsWithTagsAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (promptsWithTagsAsync.hasError) {
    return AsyncValue.error(promptsWithTagsAsync.error!, promptsWithTagsAsync.stackTrace!);
  }

  final promptsWithTags = promptsWithTagsAsync.value ?? [];
  final searchQuery = ref.watch(promptSearchQueryProvider).toLowerCase().trim();
  final filterTagId = ref.watch(promptFilterTagProvider);
  final filterFavorites = ref.watch(promptFavoriteFilterProvider);
  final sortOption = ref.watch(promptSortProvider);

  var filtered = promptsWithTags.where((pwt) {
    if (filterFavorites && !pwt.prompt.isFavorite) {
      return false;
    }

    if (filterTagId != null && filterTagId.isNotEmpty) {
      if (!pwt.tags.any((t) => t.id == filterTagId)) {
        return false;
      }
    }

    if (searchQuery.isNotEmpty) {
      final titleMatch = pwt.prompt.title.toLowerCase().contains(searchQuery);
      final bodyMatch = pwt.prompt.body.toLowerCase().contains(searchQuery);
      final tagMatch = pwt.tags.any((t) => t.name.toLowerCase().contains(searchQuery));
      return titleMatch || bodyMatch || tagMatch;
    }

    return true;
  }).toList();

  filtered.sort((a, b) {
    switch (sortOption) {
      case PromptSortOption.recentlyUpdated:
        return b.prompt.updatedAt.compareTo(a.prompt.updatedAt);
      case PromptSortOption.recentlyCreated:
        return b.prompt.createdAt.compareTo(a.prompt.createdAt);
      case PromptSortOption.titleAZ:
        return a.prompt.title.compareTo(b.prompt.title);
      case PromptSortOption.mostUsed:
        return b.prompt.usageCount.compareTo(a.prompt.usageCount);
    }
  });

  return AsyncValue.data(filtered);
});
