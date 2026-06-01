import 'package:flutter/material.dart';
import '../../../shared/widgets/placeholder_screen.dart';

class ContextPacksScreen extends StatelessWidget {
  const ContextPacksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Context Packs',
      description: 'Manage reusable context blocks to attach to your prompts.',
    );
  }
}
