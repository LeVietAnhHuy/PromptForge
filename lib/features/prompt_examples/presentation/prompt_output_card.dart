import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';
import '../../../app/theme/app_design.dart';

class PromptOutputCard extends ConsumerStatefulWidget {
  final PromptExampleOutput output;
  final VoidCallback? onDelete;

  const PromptOutputCard({
    super.key,
    required this.output,
    this.onDelete,
  });

  @override
  ConsumerState<PromptOutputCard> createState() => _PromptOutputCardState();
}

class _PromptOutputCardState extends ConsumerState<PromptOutputCard> {
  bool _expanded = false;
  List<LLMOutputAttachment> _attachments = [];
  bool _loadingAttachments = true;

  @override
  void initState() {
    super.initState();
    _loadAttachments();
  }

  Future<void> _loadAttachments() async {
    final dao = ref.read(lLMOutputAttachmentDaoProvider);
    final attachments = await dao.getAttachmentsForOutput(widget.output.id);
    if (mounted) {
      setState(() {
        _attachments = attachments;
        _loadingAttachments = false;
      });
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.output.outputText));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Output copied to clipboard')));
  }

  String _getFormattedText() {
    final text = widget.output.outputText.trim();
    if (widget.output.outputType == 'code' && !text.startsWith('```')) {
      return '```\n$text\n```';
    }
    if (widget.output.outputType == 'json' && !text.startsWith('```')) {
      return '```json\n$text\n```';
    }
    return widget.output.outputText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final formattedText = _getFormattedText();
    final isLong = formattedText.length > 500 || formattedText.split('\n').length > 10;

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
                Expanded(
                  child: Wrap(
                    spacing: AppDesign.spacingSm,
                    runSpacing: AppDesign.spacingXs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Chip(
                        label: Text(widget.output.providerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        backgroundColor: colorScheme.primaryContainer,
                        side: BorderSide.none,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                      if (widget.output.modelName != null && widget.output.modelName!.isNotEmpty)
                        Text(
                          widget.output.modelName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      _buildBadge(widget.output.outputType.toUpperCase(), colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
                      _buildBadge(widget.output.sourceType.toUpperCase(), colorScheme.tertiaryContainer, colorScheme.onTertiaryContainer),
                    ],
                  ),
                ),
                Text(
                  widget.output.createdAt.toLocal().toString().split('.')[0],
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
          if (widget.output.outputText.isNotEmpty)
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
                      data: formattedText,
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
          if (isLong && widget.output.outputText.isNotEmpty)
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
            
          // Attachments
          if (!_loadingAttachments && _attachments.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(AppDesign.spacingMd),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Attachments', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _attachments.map((att) {
                      bool isImage = att.mimeType.startsWith('image/');
                      return InkWell(
                        onTap: () {
                          // Try to open file locally or show full screen preview
                        },
                        child: Container(
                          width: isImage ? 120 : 150,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: colorScheme.outlineVariant),
                            borderRadius: BorderRadius.circular(8),
                            color: colorScheme.surfaceContainerLowest,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isImage)
                                Container(
                                  height: 80,
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: Image.file(
                                    File(att.localPath),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
                                  ),
                                )
                              else
                                const Icon(Icons.insert_drive_file, size: 32),
                              const SizedBox(height: 4),
                              Text(att.fileName, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
                              if (att.sizeBytes != null)
                                Text('${(att.sizeBytes! / 1024).toStringAsFixed(1)} KB', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
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

  Widget _buildBadge(String text, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: foreground, fontWeight: FontWeight.bold),
      ),
    );
  }
}
