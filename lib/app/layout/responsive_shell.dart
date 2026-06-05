import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_design.dart';
import '../../features/search/presentation/command_palette.dart';

class ResponsiveShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ResponsiveShell({
    super.key,
    required this.navigationShell,
  });

  void _onNavigate(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Global command palette on Ctrl/Cmd+K. CallbackShortcuts catches the chord
    // when focus is anywhere in the shell subtree (text fields don't consume it).
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () =>
            CommandPalette.show(context),
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () =>
            CommandPalette.show(context),
      },
      child: Focus(
        autofocus: true,
        skipTraversal: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 700) {
              // Mobile layout
              return Scaffold(
                body: navigationShell,
                bottomNavigationBar: NavigationBar(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _onNavigate,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.inbox),
                      label: 'Inbox',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.workspaces),
                      label: 'Workspace',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.library_books),
                      label: 'Library',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.extension),
                      label: 'Context',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.settings),
                      label: 'Settings',
                    ),
                  ],
                ),
              );
            } else {
              // Desktop layout
              return Scaffold(
                body: Row(
                  children: [
                    NavigationRail(
                      selectedIndex: navigationShell.currentIndex,
                      onDestinationSelected: _onNavigate,
                      labelType: NavigationRailLabelType.all,
                      leading: const _BrandMark(),
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.inbox),
                          label: Text('Inbox'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.workspaces),
                          label: Text('Workspace'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.library_books),
                          label: Text('Library'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.extension),
                          label: Text('Context'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.settings),
                          label: Text('Settings'),
                        ),
                      ],
                    ),
                    const VerticalDivider(thickness: 1, width: 1),
                    Expanded(child: navigationShell),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

/// PromptForge brand mark for the navigation rail header — an ember-gradient
/// anvil-spark glyph with a compact wordmark in the display font.
class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
          top: AppDesign.spacingMd, bottom: AppDesign.spacingSm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  AppDesign.emberBright,
                ],
              ),
              borderRadius: AppDesign.borderMd,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.local_fire_department,
                size: 22, color: AppDesign.emberOnPrimary),
          ),
          const SizedBox(height: AppDesign.spacingXs),
          Text('Forge',
              style: theme.textTheme.labelMedium?.copyWith(
                  fontFamily: AppDesign.fontDisplay,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
