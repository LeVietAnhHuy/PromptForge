import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../../core/database/database.dart';
import '../../../app/theme/app_design.dart';

class PromptOutputCard extends StatefulWidget {
  final PromptExampleOutput output;
  final VoidCallback? onDelete;

  const PromptOutputCard({
    super.key,
    required this.output,
    this.onDelete,
  });

  @override
  State<PromptOutputCard> createState() => _PromptOutputCardState();
}

class _PromptOutputCardState extends State<PromptOutputCard> {
  bool _expanded = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.output.outputText));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Output copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Check if it's a very long output
    final isLong = widget.output.outputText.length > 500 || widget.output.outputText.split('\n').length > 10;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppDesign.spacingMd),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colorScheme.outlineVariant),
        borderRadius: AppDesign.borderLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDesign.spacingMd, vertical: AppDesign.spacingSm),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
            ),
            child: Row(
              children: [
                Chip(
                  label: Text(widget.output.providerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  backgroundColor: colorScheme.primaryContainer,
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                if (widget.output.modelName != null && widget.output.modelName!.isNotEmpty) ...[
                  const SizedBox(width: AppDesign.spacingSm),
                  Text(widget.output.modelName!, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
                const SizedBox(width: AppDesign.spacingSm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.output.outputType.toUpperCase(),
                    style: TextStyle(fontSize: 10, color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.output.createdAt.toLocal().toString().split('.')[0]}',
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(width: AppDesign.spacingSm),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (val) {
                    if (val == 'copy') {
                      _copyToClipboard();
                    } else if (val == 'delete' && widget.onDelete != null) {
                      widget.onDelete!();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'copy', child: Text('Copy Text')),
                    if (widget.onDelete != null)
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete', style: TextStyle(color: colorScheme.error)),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // Body
          Container(
            padding: const EdgeInsets.all(AppDesign.spacingMd),
            constraints: _expanded ? null : const BoxConstraints(maxHeight: 250),
            clipBehavior: _expanded ? Clip.none : Clip.hardEdge,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: MarkdownBody(
                    data: widget.output.outputText,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: theme.textTheme.bodyMedium,
                      code: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace', backgroundColor: colorScheme.surfaceContainerHighest),
                      codeblockDecoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                if (!_expanded && isLong)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            colorScheme.surface.withValues(alpha: 0.0),
                            colorScheme.surface.withValues(alpha: 1.0),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Footer (Expand/Collapse)
          if (isLong)
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppDesign.spacingSm),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_expanded ? 'Show Less' : 'Show More', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16, color: colorScheme.primary),
                  ],
                ),
              ),
            ),
            
          // Notes section
          if (widget.output.notes != null && widget.output.notes!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDesign.spacingMd),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
                borderRadius: isLong ? BorderRadius.zero : const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: AppDesign.spacingSm),
                  Expanded(
                    child: Text(
                      widget.output.notes!,
                      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
