import 'package:flutter/material.dart';

import '../../app/theme/app_design.dart';

/// A consistent, forge-styled empty state: an ember-tinted icon mark, a short
/// title, an explanatory line, and an optional primary action. Replaces ad-hoc
/// "blank dark void" centers across list screens.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;

  const EmptyState({
    super.key,
    this.icon = Icons.local_fire_department_outlined,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(AppDesign.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ember "anvil spark" mark: a soft radial ember glow behind the icon.
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    scheme.primary.withValues(alpha: 0.22),
                    scheme.primary.withValues(alpha: 0.04),
                  ]),
                  border:
                      Border.all(color: scheme.primary.withValues(alpha: 0.30)),
                ),
                child: Icon(icon, size: 38, color: scheme.primary),
              ),
              const SizedBox(height: AppDesign.spacingLg),
              Text(title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: AppDesign.spacingSm),
              Text(message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant)),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppDesign.spacingLg),
                FilledButton.icon(
                  onPressed: onAction,
                  icon: Icon(actionIcon ?? Icons.add),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
