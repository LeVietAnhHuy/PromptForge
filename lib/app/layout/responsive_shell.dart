import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

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
