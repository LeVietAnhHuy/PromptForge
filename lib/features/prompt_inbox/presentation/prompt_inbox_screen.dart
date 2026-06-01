import 'package:flutter/material.dart';
import '../../../shared/widgets/placeholder_screen.dart';

class PromptInboxScreen extends StatelessWidget {
  const PromptInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Inbox',
      description: 'Quickly capture raw ideas and prompt snippets.',
    );
  }
}
