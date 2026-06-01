import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/inbox_providers.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxItemsAsync = ref.watch(openInboxItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prompt Inbox'),
      ),
      body: inboxItemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('Your inbox is empty. Capture a new idea!'),
            );
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(
                  item.title?.isNotEmpty == true ? item.title! : 'Untitled Idea',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  item.rawText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  item.updatedAt.toString().split(' ')[0], // simple date
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () {
                  context.go('/inbox/edit/${item.id}');
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/inbox/new');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
