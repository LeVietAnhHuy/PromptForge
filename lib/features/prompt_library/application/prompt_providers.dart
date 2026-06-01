import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';

final promptSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredPromptsProvider = StreamProvider<List<Prompt>>((ref) {
  final promptDao = ref.watch(promptDaoProvider);
  final searchQuery = ref.watch(promptSearchQueryProvider).toLowerCase();

  return promptDao.watchAllPrompts().map((prompts) {
    if (searchQuery.isEmpty) {
      return prompts;
    }
    return prompts.where((prompt) {
      final titleMatch = prompt.title.toLowerCase().contains(searchQuery);
      final bodyMatch = prompt.body.toLowerCase().contains(searchQuery);
      return titleMatch || bodyMatch;
    }).toList();
  });
});
