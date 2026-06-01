import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/context_pack_providers.dart';

class ContextPacksScreen extends ConsumerWidget {
  const ContextPacksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packsAsync = ref.watch(contextPacksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Context Packs'),
      ),
      body: packsAsync.when(
        data: (packs) {
          if (packs.isEmpty) {
            return const Center(
              child: Text('No context packs found. Create one!'),
            );
          }

          return ListView.builder(
            itemCount: packs.length,
            itemBuilder: (context, index) {
              final pack = packs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(pack.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    pack.description ?? pack.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    '${pack.updatedAt.year}-${pack.updatedAt.month.toString().padLeft(2, '0')}-${pack.updatedAt.day.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () => context.go('/context-packs/editor/${pack.id}'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/context-packs/editor'),
        tooltip: 'New Context Pack',
        child: const Icon(Icons.add),
      ),
    );
  }
}
