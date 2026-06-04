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
      // PromptForge — Inspired by Tailwind Typography prose plugin.
      // Calm dark surface, clean block rhythm, subtle headings, soft backgrounds.
      case MarkdownReaderStyle.promptForge:
        return MarkdownStyleSheet(
          h1: theme.textTheme.headlineMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
          h1Padding: const EdgeInsets.only(bottom: 8, top: 4),
          h2: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.secondary,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
          h2Padding: const EdgeInsets.only(bottom: 6, top: 16),
          h3: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.85),
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
          h3Padding: const EdgeInsets.only(bottom: 4, top: 12),
          p: theme.textTheme.bodyMedium?.copyWith(
            height: 1.65,
            color: colorScheme.onSurface.withValues(alpha: 0.9),
          ),
          pPadding: const EdgeInsets.only(bottom: 8),
          code: theme.textTheme.bodySmall?.copyWith(
            backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
            color: colorScheme.primary,
            fontFamily: 'monospace',
            fontSize: 13,
          ),
          codeblockDecoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          codeblockPadding: const EdgeInsets.all(14),
          blockquoteDecoration: BoxDecoration(
            border: Border(left: BorderSide(color: colorScheme.primary.withValues(alpha: 0.7), width: 4)),
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
          ),
          blockquotePadding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
          horizontalRuleDecoration: BoxDecoration(
            border: Border(top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 1)),
          ),
          listBullet: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.primary.withValues(alpha: 0.7),
          ),
          listBulletPadding: const EdgeInsets.only(right: 8),
          a: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
        );

      // GitHub — Inspired by sindresorhus/github-markdown-css.
      // Familiar developer docs, crisp code blocks, strong borders.
      case MarkdownReaderStyle.github:
        final textColor = isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1F2328);
        final mutedText = isDark ? const Color(0xFF9198A1) : const Color(0xFF636C76);
        final codeBg = isDark ? const Color(0xFF161B22) : const Color(0xFFF6F8FA);
        final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE);
        final headingBorder = isDark ? const Color(0xFF21262D) : const Color(0xFFD8DEE4);
        return MarkdownStyleSheet(
          h1: theme.textTheme.headlineMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
          h1Padding: EdgeInsets.only(bottom: 10, top: 4),
          h2: theme.textTheme.titleLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
          h2Padding: EdgeInsets.only(bottom: 8, top: 16),
          h3: theme.textTheme.titleMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
          h3Padding: EdgeInsets.only(bottom: 4, top: 12),
          p: theme.textTheme.bodyMedium?.copyWith(
            color: textColor,
            height: 1.6,
          ),
          pPadding: const EdgeInsets.only(bottom: 10),
          code: theme.textTheme.bodySmall?.copyWith(
            backgroundColor: codeBg,
            color: textColor,
            fontFamily: 'monospace',
            fontSize: 13,
          ),
          codeblockDecoration: BoxDecoration(
            color: codeBg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor),
          ),
          codeblockPadding: const EdgeInsets.all(16),
          blockquoteDecoration: BoxDecoration(
            border: Border(left: BorderSide(color: borderColor, width: 4)),
          ),
          blockquotePadding: const EdgeInsets.fromLTRB(16, 4, 0, 4),
          horizontalRuleDecoration: BoxDecoration(
            border: Border(top: BorderSide(color: headingBorder, width: 2)),
          ),
          listBullet: theme.textTheme.bodyMedium?.copyWith(
            color: mutedText,
          ),
          listBulletPadding: const EdgeInsets.only(right: 8),
          a: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA),
            decoration: TextDecoration.underline,
          ),
        );

      // Docs — Inspired by VitePress / mdBook / Rust docs.
      // Strong H1-H3 hierarchy, generous spacing, TOC-friendly.
      case MarkdownReaderStyle.docs:
        final accentColor = isDark ? const Color(0xFF42B883) : const Color(0xFF3C8772);
        return MarkdownStyleSheet(
          h1: theme.textTheme.displaySmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            height: 1.2,
          ),
          h1Padding: const EdgeInsets.only(bottom: 12, top: 4),
          h2: theme.textTheme.headlineSmall?.copyWith(
            color: accentColor,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            height: 1.3,
          ),
          h2Padding: const EdgeInsets.only(bottom: 8, top: 20),
          h3: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            height: 1.35,
          ),
          h3Padding: const EdgeInsets.only(bottom: 4, top: 14),
          p: theme.textTheme.bodyLarge?.copyWith(
            height: 1.75,
            color: colorScheme.onSurface,
          ),
          pPadding: const EdgeInsets.only(bottom: 10),
          code: theme.textTheme.bodySmall?.copyWith(
            backgroundColor: colorScheme.surfaceContainer,
            color: accentColor,
            fontFamily: 'monospace',
            fontSize: 13,
          ),
          codeblockDecoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
          ),
          codeblockPadding: const EdgeInsets.all(20),
          blockquoteDecoration: BoxDecoration(
            color: (isDark ? accentColor : colorScheme.primaryContainer).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border(left: BorderSide(color: accentColor, width: 4)),
          ),
          blockquotePadding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          horizontalRuleDecoration: BoxDecoration(
            border: Border(top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4), width: 1)),
          ),
          listBullet: theme.textTheme.bodyMedium?.copyWith(
            color: accentColor,
          ),
          listBulletPadding: const EdgeInsets.only(right: 8),
          a: theme.textTheme.bodyMedium?.copyWith(
            color: accentColor,
            decoration: TextDecoration.underline,
          ),
        );

      // Paper — Inspired by Tufte CSS / LaTeX.css.
      // Academic calm, serif feel, strong separators, comfortable reading.
      case MarkdownReaderStyle.paper:
        final paperText = isDark ? const Color(0xFFD4D4D4) : const Color(0xFF333333);
        final paperMuted = isDark ? const Color(0xFF888888) : const Color(0xFF666666);
        final paperBorder = isDark ? const Color(0xFF444444) : const Color(0xFFBBBBBB);
        return MarkdownStyleSheet(
          h1: theme.textTheme.headlineMedium?.copyWith(
            color: paperText,
            fontWeight: FontWeight.w700,
            fontFamily: 'serif',
            height: 1.3,
            letterSpacing: -0.3,
          ),
          h1Padding: const EdgeInsets.only(bottom: 10, top: 4),
          h2: theme.textTheme.titleLarge?.copyWith(
            color: paperText,
            fontWeight: FontWeight.w600,
            fontFamily: 'serif',
            fontStyle: FontStyle.italic,
            height: 1.35,
          ),
          h2Padding: const EdgeInsets.only(bottom: 6, top: 18),
          h3: theme.textTheme.titleMedium?.copyWith(
            color: paperMuted,
            fontWeight: FontWeight.w600,
            fontFamily: 'serif',
            height: 1.4,
          ),
          h3Padding: const EdgeInsets.only(bottom: 4, top: 14),
          p: theme.textTheme.bodyMedium?.copyWith(
            color: paperText,
            height: 1.8,
            fontFamily: 'serif',
          ),
          pPadding: const EdgeInsets.only(bottom: 10),
          code: theme.textTheme.bodySmall?.copyWith(
            backgroundColor: Colors.transparent,
            color: paperText,
            fontFamily: 'monospace',
            fontSize: 13,
          ),
          codeblockDecoration: BoxDecoration(
            border: Border(left: BorderSide(color: paperBorder, width: 3)),
          ),
          codeblockPadding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          blockquoteDecoration: BoxDecoration(
            border: Border(left: BorderSide(color: paperMuted, width: 2)),
          ),
          blockquotePadding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
          horizontalRuleDecoration: BoxDecoration(
            border: Border(top: BorderSide(color: paperBorder.withValues(alpha: 0.6), width: 1)),
          ),
          listBullet: theme.textTheme.bodyMedium?.copyWith(
            color: paperMuted,
            fontFamily: 'serif',
          ),
          listBulletPadding: const EdgeInsets.only(right: 8),
          a: theme.textTheme.bodyMedium?.copyWith(
            color: paperText,
            decoration: TextDecoration.underline,
            fontFamily: 'serif',
          ),
        );

      // Terminal — Inspired by Terminal.css / terminalcss.xyz.
      // Monospace, low saturation green/cyan, dark, command-line feel.
      case MarkdownReaderStyle.terminal:
        final termGreen = isDark ? const Color(0xFF4AF626) : const Color(0xFF006400);
        final termCyan = isDark ? const Color(0xFF00D4AA) : const Color(0xFF005F5F);
        final termText = isDark ? const Color(0xFFCCCCCC) : const Color(0xFF1A1A1A);
        final termMuted = isDark ? const Color(0xFF666666) : const Color(0xFF888888);
        return MarkdownStyleSheet(
          h1: theme.textTheme.headlineMedium?.copyWith(
            color: termGreen,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            height: 1.3,
          ),
          h1Padding: const EdgeInsets.only(bottom: 6, top: 4),
          h2: theme.textTheme.titleLarge?.copyWith(
            color: termCyan,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
            height: 1.3,
          ),
          h2Padding: const EdgeInsets.only(bottom: 4, top: 14),
          h3: theme.textTheme.titleMedium?.copyWith(
            color: termGreen.withValues(alpha: 0.75),
            fontWeight: FontWeight.w500,
            fontFamily: 'monospace',
            height: 1.35,
          ),
          h3Padding: const EdgeInsets.only(bottom: 4, top: 10),
          p: theme.textTheme.bodyMedium?.copyWith(
            color: termText,
            height: 1.5,
            fontFamily: 'monospace',
          ),
          pPadding: const EdgeInsets.only(bottom: 6),
          code: theme.textTheme.bodySmall?.copyWith(
            color: termGreen,
            backgroundColor: Colors.transparent,
            fontFamily: 'monospace',
            fontSize: 13,
          ),
          codeblockDecoration: BoxDecoration(
            color: isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF0F4F0),
            border: Border.all(color: termGreen.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.zero,
          ),
          codeblockPadding: const EdgeInsets.all(14),
          blockquoteDecoration: BoxDecoration(
            border: Border(left: BorderSide(color: termCyan.withValues(alpha: 0.6), width: 3)),
          ),
          blockquotePadding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
          horizontalRuleDecoration: BoxDecoration(
            border: Border(top: BorderSide(color: termMuted, width: 1)),
          ),
          listBullet: theme.textTheme.bodyMedium?.copyWith(
            color: termGreen.withValues(alpha: 0.7),
            fontFamily: 'monospace',
          ),
          listBulletPadding: const EdgeInsets.only(right: 8),
          a: theme.textTheme.bodyMedium?.copyWith(
            color: termCyan,
            decoration: TextDecoration.underline,
            fontFamily: 'monospace',
          ),
        );
    }
  }
}
