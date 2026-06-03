import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

enum MarkdownReaderStyle {
  promptForge,
  github,
  docs,
  paper,
  terminal;

  String get displayName {
    switch (this) {
      case MarkdownReaderStyle.promptForge: return 'PromptForge';
      case MarkdownReaderStyle.github: return 'GitHub';
      case MarkdownReaderStyle.docs: return 'Docs';
      case MarkdownReaderStyle.paper: return 'Paper';
      case MarkdownReaderStyle.terminal: return 'Terminal';
    }
  }

  MarkdownStyleSheet buildStyleSheet(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    switch (this) {
      case MarkdownReaderStyle.promptForge:
        return MarkdownStyleSheet(
          h1: theme.textTheme.headlineMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
          h2: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.secondary,
            fontWeight: FontWeight.w600,
          ),
          h3: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          p: theme.textTheme.bodyMedium?.copyWith(
            height: 1.5,
          ),
          code: theme.textTheme.bodyMedium?.copyWith(
            backgroundColor: colorScheme.surfaceContainerHighest,
            fontFamily: 'monospace',
          ),
          codeblockDecoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          codeblockPadding: const EdgeInsets.all(12),
          blockquoteDecoration: BoxDecoration(
            border: Border(left: BorderSide(color: colorScheme.primary, width: 4)),
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ),
          blockquotePadding: const EdgeInsets.all(12),
          horizontalRuleDecoration: BoxDecoration(
            border: Border(top: BorderSide(color: colorScheme.outlineVariant, width: 2)),
          ),
        );

      case MarkdownReaderStyle.github:
        return MarkdownStyleSheet(
          h1: theme.textTheme.headlineMedium?.copyWith(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
          ),
          h2: theme.textTheme.titleLarge?.copyWith(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
          h3: theme.textTheme.titleMedium?.copyWith(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
          p: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.grey[300] : Colors.grey[800],
            height: 1.6,
          ),
          code: theme.textTheme.bodyMedium?.copyWith(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF6F8FA),
            color: isDark ? Colors.grey[300] : Colors.grey[800],
            fontFamily: 'monospace',
          ),
          codeblockDecoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : const Color(0xFFF6F8FA),
            borderRadius: BorderRadius.circular(6),
          ),
          codeblockPadding: const EdgeInsets.all(16),
          blockquoteDecoration: BoxDecoration(
            border: Border(left: BorderSide(color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE), width: 4)),
          ),
          blockquotePadding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
          horizontalRuleDecoration: BoxDecoration(
            border: Border(top: BorderSide(color: isDark ? const Color(0xFF21262D) : const Color(0xFFD8DEE4), width: 2)),
          ),
        );

      case MarkdownReaderStyle.docs:
        return MarkdownStyleSheet(
          h1: theme.textTheme.displaySmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          h2: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
          h3: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          p: theme.textTheme.bodyLarge?.copyWith(
            height: 1.7,
            color: colorScheme.onSurface,
          ),
          code: theme.textTheme.bodyMedium?.copyWith(
            backgroundColor: colorScheme.surfaceContainer,
            color: colorScheme.primary,
            fontFamily: 'monospace',
          ),
          codeblockDecoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          codeblockPadding: const EdgeInsets.all(20),
          blockquoteDecoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border(left: BorderSide(color: colorScheme.primary, width: 4)),
          ),
          blockquotePadding: const EdgeInsets.all(16),
          horizontalRuleDecoration: BoxDecoration(
            border: Border(top: BorderSide(color: colorScheme.outlineVariant, width: 1)),
          ),
        );

      case MarkdownReaderStyle.paper:
        final paperText = isDark ? const Color(0xFFE0E0E0) : const Color(0xFF2C2C2C);
        return MarkdownStyleSheet(
          h1: theme.textTheme.headlineMedium?.copyWith(
            color: paperText,
            fontWeight: FontWeight.w800,
            fontFamily: 'serif',
          ),
          h2: theme.textTheme.titleLarge?.copyWith(
            color: paperText,
            fontWeight: FontWeight.w700,
            fontFamily: 'serif',
          ),
          h3: theme.textTheme.titleMedium?.copyWith(
            color: paperText,
            fontWeight: FontWeight.w600,
            fontFamily: 'serif',
          ),
          p: theme.textTheme.bodyMedium?.copyWith(
            color: paperText,
            height: 1.8,
            fontFamily: 'serif',
          ),
          code: theme.textTheme.bodyMedium?.copyWith(
            backgroundColor: Colors.transparent,
            color: paperText,
            fontFamily: 'monospace',
          ),
          codeblockDecoration: BoxDecoration(
            border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[400]!),
            borderRadius: BorderRadius.circular(2),
          ),
          codeblockPadding: const EdgeInsets.all(12),
          blockquoteDecoration: BoxDecoration(
            border: Border(left: BorderSide(color: isDark ? Colors.grey[500]! : Colors.grey[600]!, width: 2)),
          ),
          blockquotePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          horizontalRuleDecoration: BoxDecoration(
            border: Border(top: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[400]!, width: 1)),
          ),
        );

      case MarkdownReaderStyle.terminal:
        final termGreen = isDark ? const Color(0xFF4AF626) : const Color(0xFF006400);
        final termText = isDark ? const Color(0xFF00FF00) : const Color(0xFF000000);
        return MarkdownStyleSheet(
          h1: theme.textTheme.headlineMedium?.copyWith(
            color: termGreen,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
          h2: theme.textTheme.titleLarge?.copyWith(
            color: termGreen,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
          h3: theme.textTheme.titleMedium?.copyWith(
            color: termGreen,
            fontWeight: FontWeight.w500,
            fontFamily: 'monospace',
          ),
          p: theme.textTheme.bodyMedium?.copyWith(
            color: termText,
            height: 1.4,
            fontFamily: 'monospace',
          ),
          code: theme.textTheme.bodyMedium?.copyWith(
            color: termGreen,
            backgroundColor: Colors.transparent,
            fontFamily: 'monospace',
          ),
          codeblockDecoration: BoxDecoration(
            color: isDark ? Colors.black : const Color(0xFFE8F5E9),
            border: Border.all(color: termGreen),
            borderRadius: BorderRadius.zero,
          ),
          codeblockPadding: const EdgeInsets.all(12),
          blockquoteDecoration: BoxDecoration(
            border: Border(left: BorderSide(color: termGreen, width: 4)),
          ),
          blockquotePadding: const EdgeInsets.all(8),
          horizontalRuleDecoration: BoxDecoration(
            border: Border(top: BorderSide(color: termGreen, width: 1)),
          ),
        );
    }
  }
}
