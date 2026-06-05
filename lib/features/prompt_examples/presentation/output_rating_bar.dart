import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_design.dart';
import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';

/// The one rating + "Best" control shared by every surface that shows an
/// output (the library card and the comparison columns). It writes ratings and
/// the best-pin straight through [PromptExampleOutputDao], so the two surfaces
/// can never hold divergent state — they both read `score`/`isBest` from the
/// row and mutate it the same way.
///
/// Ratings (1-5 ember stars) are per-output. The best-pin is scoped per-prompt
/// when [promptId] is given (the library aggregates many one-output examples),
/// otherwise per-example (a single comparison run with several outputs).
class OutputRatingBar extends ConsumerWidget {
  final PromptExampleOutput output;
  final String? promptId;

  /// Compact layout drops the "Best" text label and tightens spacing for dense
  /// rows; the affordances and behaviour are identical.
  final bool compact;

  const OutputRatingBar({
    super.key,
    required this.output,
    this.promptId,
    this.compact = false,
  });

  Future<void> _setScore(WidgetRef ref, int star) async {
    final dao = ref.read(promptExampleOutputDaoProvider);
    // Tapping the current rating clears it (toggle off); otherwise set it.
    final next = output.score == star ? null : star;
    await dao.setOutputScore(output.id, next);
  }

  Future<void> _toggleBest(WidgetRef ref) async {
    final dao = ref.read(promptExampleOutputDaoProvider);
    if (output.isBest) {
      await dao.setOutputBest(output.id, false);
    } else if (promptId != null) {
      await dao.markOutputAsBestForPrompt(promptId!, output.id);
    } else {
      await dao.markOutputAsBest(output.exampleId, output.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final score = output.score ?? 0;
    final starSize = compact ? 18.0 : 22.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          final filled = i < score;
          return IconButton(
            iconSize: starSize,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(
                width: starSize + 8, height: starSize + 8),
            tooltip: '${i + 1} star${i == 0 ? '' : 's'}',
            icon: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              color: filled
                  ? AppDesign.emberBright
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            onPressed: () => _setScore(ref, i + 1),
          );
        }),
        const SizedBox(width: AppDesign.spacingSm),
        // Best pin — ember filled when active.
        InkWell(
          borderRadius: AppDesign.borderSm,
          onTap: () => _toggleBest(ref),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDesign.spacingSm, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  output.isBest
                      ? Icons.workspace_premium
                      : Icons.workspace_premium_outlined,
                  size: starSize - 2,
                  color: output.isBest
                      ? AppDesign.emberPrimary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                if (!compact) ...[
                  const SizedBox(width: AppDesign.spacingXs),
                  Text(
                    'Best',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: output.isBest
                          ? AppDesign.emberPrimary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight:
                          output.isBest ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
