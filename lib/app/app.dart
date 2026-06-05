import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/router.dart';
import 'theme/theme.dart';

class PromptForgeApp extends ConsumerWidget {
  const PromptForgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'PromptForge',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      // Forge is a dark-first design system; pin dark as the primary theme.
      themeMode: ThemeMode.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
