import 'package:flutter/material.dart';
import '../../../shared/widgets/placeholder_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Search',
      description: 'Search your prompts by title, content, or tags.',
    );
  }
}
