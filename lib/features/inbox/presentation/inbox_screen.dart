import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/inbox_providers.dart';
import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';
import 'inbox_to_prompt_card_dialog.dart';
import 'inbox_to_workspace_run_dialog.dart';

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
              return Dismissible(
                key: Key(item.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(Icons.archive, color: Colors.white),
                ),
                onDismissed: (direction) async {
                  final dao = ref.read(inboxItemDaoProvider);
                  await dao.archiveInboxItem(item.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item archived')));
                  }
                },
                child: ListTile(
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.updatedAt.toString().split(' ')[0], // simple date
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'card') {
                            _showPromptCardDialog(context, item);
                          } else if (value == 'run') {
                            _showWorkspaceRunDialog(context, item);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'card',
                            child: Text('Convert to Prompt Card'),
                          ),
                          const PopupMenuItem(
                            value: 'run',
                            child: Text('Convert to Workspace Run'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    context.go('/inbox/edit/${item.id}');
                  },
                ),
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

  void _showPromptCardDialog(BuildContext context, InboxItem item) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    if (isDesktop) {
      showDialog(
        context: context,
        builder: (context) => InboxToPromptCardDialog(item: item),
      );
    } else {
      showGeneralDialog(
        context: context,
        pageBuilder: (context, anim1, anim2) => InboxToPromptCardDialog(item: item),
      );
    }
  }

  void _showWorkspaceRunDialog(BuildContext context, InboxItem item) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    if (isDesktop) {
      showDialog(
        context: context,
        builder: (context) => InboxToWorkspaceRunDialog(item: item),
      );
    } else {
      showGeneralDialog(
        context: context,
        pageBuilder: (context, anim1, anim2) => InboxToWorkspaceRunDialog(item: item),
      );
    }
  }
}
