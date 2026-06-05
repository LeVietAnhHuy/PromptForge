import 'package:flutter/material.dart';

import '../../app/theme/app_design.dart';

enum FeedbackKind { info, success, warning, error }

/// Consistent, forge-styled user feedback: toasts (snackbars) and a confirm
/// dialog for destructive actions. Use these instead of bespoke SnackBars /
/// AlertDialogs so styling and button order stay uniform.
class AppFeedback {
  AppFeedback._();

  static void show(BuildContext context, String message,
      {FeedbackKind kind = FeedbackKind.info}) {
    final forge = context.forge;
    final scheme = Theme.of(context).colorScheme;
    final (Color accent, IconData icon) = switch (kind) {
      FeedbackKind.success => (forge.success, Icons.check_circle_outline),
      FeedbackKind.warning => (forge.warning, Icons.warning_amber_outlined),
      FeedbackKind.error => (scheme.error, Icons.error_outline),
      FeedbackKind.info => (scheme.primary, Icons.info_outline),
    };
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Row(
          children: [
            Icon(icon, size: 18, color: accent),
            const SizedBox(width: AppDesign.spacingSm),
            Expanded(child: Text(message)),
          ],
        ),
      ));
  }

  /// A styled confirm dialog. Returns true if confirmed. Secondary action on the
  /// left, primary on the right; Esc / barrier cancels.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool destructive = false,
  }) async {
    final scheme = Theme.of(context).colorScheme;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError)
                : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

/// A simple shimmer-less skeleton block for async list placeholders.
class SkeletonBox extends StatelessWidget {
  final double height;
  final double? width;
  final EdgeInsetsGeometry margin;
  const SkeletonBox({
    super.key,
    this.height = 16,
    this.width,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: height,
      width: width,
      margin: margin,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: AppDesign.borderSm,
      ),
    );
  }
}

/// A list of skeleton cards for loading states.
class SkeletonList extends StatelessWidget {
  final int count;
  const SkeletonList({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.all(AppDesign.spacingLg),
      itemCount: count,
      itemBuilder: (context, _) => Container(
        margin: const EdgeInsets.only(bottom: AppDesign.spacingMd),
        padding: const EdgeInsets.all(AppDesign.spacingMd),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: AppDesign.borderLg,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(height: 18, width: 180),
            SizedBox(height: AppDesign.spacingSm),
            SkeletonBox(height: 12, width: double.infinity),
            SizedBox(height: AppDesign.spacingXs),
            SkeletonBox(height: 12, width: 240),
          ],
        ),
      ),
    );
  }
}
