import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


import '../../features/prompt_library/presentation/prompt_library_screen.dart';
import '../../features/prompt_library/presentation/prompt_editor_screen.dart';
import '../../features/prompt_compiler/presentation/prompt_compiler_screen.dart';
import '../../features/prompt_examples/presentation/prompt_examples_screen.dart';
import '../../features/prompt_examples/presentation/example_comparison_screen.dart';
import '../../features/context_packs/presentation/context_packs_screen.dart';
import '../../features/context_packs/presentation/context_pack_editor_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/import_export/presentation/export_preview_screen.dart';
import '../../features/import_export/presentation/import_screen.dart';
import '../../features/inbox/presentation/inbox_screen.dart';
import '../../features/inbox/presentation/inbox_editor_screen.dart';
import '../layout/responsive_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/inbox',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ResponsiveShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inbox',
                builder: (context, state) => const InboxScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const InboxEditorScreen(),
                  ),
                  GoRoute(
                    path: 'edit/:id',
                    builder: (context, state) => InboxEditorScreen(
                      itemId: state.pathParameters['id'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const PromptLibraryScreen(),
                routes: [
                  GoRoute(
                    path: 'editor',
                    builder: (context, state) => const PromptEditorScreen(),
                  ),
                  GoRoute(
                    path: 'editor/:id',
                    builder: (context, state) => PromptEditorScreen(
                      promptId: state.pathParameters['id'],
                    ),
                  ),
                  GoRoute(
                    path: 'compile/:id',
                    builder: (context, state) => PromptCompilerScreen(
                      promptId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'examples/:id',
                    builder: (context, state) => PromptExamplesScreen(
                      promptId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'compare/:exampleId',
                        builder: (context, state) => ExampleComparisonScreen(
                          exampleId: state.pathParameters['exampleId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/context-packs',
                builder: (context, state) => const ContextPacksScreen(),
                routes: [
                  GoRoute(
                    path: 'editor',
                    builder: (context, state) => const ContextPackEditorScreen(),
                  ),
                  GoRoute(
                    path: 'editor/:id',
                    builder: (context, state) => ContextPackEditorScreen(
                      packId: state.pathParameters['id'],
                    ),
                  ),
                ],
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'export',
                    builder: (context, state) => const ExportPreviewScreen(),
                  ),
                  GoRoute(
                    path: 'import',
                    builder: (context, state) => const ImportScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
