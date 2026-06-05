import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:intl/intl.dart';

import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';
import '../../../app/theme/app_design.dart';
import '../../../shared/providers/provider_identity.dart';
import '../../../shared/attachments/attachment_viewer.dart';

class PromptOutputCard extends ConsumerStatefulWidget {
  final PromptExampleOutput output;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const PromptOutputCard({
    super.key,
    required this.output,
    this.onDelete,
    this.onEdit,
  });

  @override
  ConsumerState<PromptOutputCard> createState() => _PromptOutputCardState();
}

class _PromptOutputCardState extends ConsumerState<PromptOutputCard> {
  bool _expanded = false;
  bool _hovering = false;
  List<LLMOutputAttachment> _attachments = [];
  bool _loadingAttachments = true;

  @override
  void initState() {
    super.initState();
    _loadAttachments();
  }

  @override
  void didUpdateWidget(covariant PromptOutputCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload attachments if the underlying output changed (e.g. after an edit).
    if (oldWidget.output.id != widget.output.id ||
        oldWidget.output.updatedAt != widget.output.updatedAt) {
      _loadAttachments();
    }
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
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Output copied to clipboard')));
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
    final identity = ProviderRegistry.resolve(
      providerId: widget.output.providerId,
      providerName: widget.output.providerName,
    );

    final formattedText = _getFormattedText();
    final isLong =
        formattedText.length > 500 || formattedText.split('\n').length > 10;
    final edited =
        widget.output.updatedAt.difference(widget.output.createdAt).inSeconds >
            2;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: AppDesign.motion(context, AppDesign.durationFast),
        curve: AppDesign.easeStandard,
        margin: const EdgeInsets.only(bottom: AppDesign.spacingMd),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: AppDesign.borderLg,
          border: Border.all(
            color: _hovering
                ? identity.accent.withValues(alpha: 0.55)
                : colorScheme.outlineVariant,
          ),
          boxShadow: _hovering
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : const [],
        ),
        child: ClipRRect(
          borderRadius: AppDesign.borderLg,
          child: Stack(
            children: [
              // Provider accent left border (3-4px), full height.
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 4,
                child: ColoredBox(color: identity.accent),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(theme, colorScheme, identity, edited),
                    if (widget.output.outputText.isNotEmpty)
                      _buildBody(theme, colorScheme, formattedText, isLong),
                    if (isLong && widget.output.outputText.isNotEmpty)
                      _buildExpandToggle(theme, colorScheme),
                    if (!_loadingAttachments && _attachments.isNotEmpty)
                      _buildAttachments(theme, colorScheme),
                    if (widget.output.notes != null &&
                        widget.output.notes!.isNotEmpty)
                      _buildNotes(theme, colorScheme, isLong),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme,
      ProviderIdentity identity, bool edited) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDesign.spacingMd, vertical: AppDesign.spacingSm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          ProviderLogo(identity: identity, size: 22),
          const SizedBox(width: AppDesign.spacingSm),
          Expanded(
            child: Wrap(
              spacing: AppDesign.spacingSm,
              runSpacing: AppDesign.spacingXs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  identity.displayName,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontFamily: AppDesign.fontDisplay),
                ),
                if (widget.output.modelName != null &&
                    widget.output.modelName!.isNotEmpty)
                  _tintedBadge(widget.output.modelName!, identity.accent),
                _buildBadge(
                    widget.output.outputType.toUpperCase(),
                    colorScheme.secondaryContainer,
                    colorScheme.onSecondaryContainer),
                _buildBadge(
                    widget.output.sourceType.toUpperCase(),
                    colorScheme.tertiaryContainer,
                    colorScheme.onTertiaryContainer),
                if (edited)
                  Text(
                    '· edited ${DateFormat.MMMd().add_jm().format(widget.output.updatedAt.toLocal())}',
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
          Text(
            DateFormat.MMMd()
                .add_jm()
                .format(widget.output.createdAt.toLocal()),
            style: theme.textTheme.labelSmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          // Pencil edit affordance on hover (pointer devices).
          if (widget.onEdit != null)
            AnimatedOpacity(
              opacity: _hovering ? 1.0 : 0.0,
              duration: AppDesign.motion(context, AppDesign.durationFast),
              child: IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                tooltip: 'Edit output',
                visualDensity: VisualDensity.compact,
                onPressed: _hovering ? widget.onEdit : null,
              ),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            tooltip: 'More options',
            onSelected: (val) {
              if (val == 'edit') {
                widget.onEdit?.call();
              } else if (val == 'copy') {
                _copyToClipboard();
              } else if (val == 'delete') {
                widget.onDelete?.call();
              }
            },
            itemBuilder: (context) => [
              if (widget.onEdit != null)
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Edit'),
                  ),
                ),
              const PopupMenuItem(
                value: 'copy',
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.copy),
                  title: Text('Copy Text'),
                ),
              ),
              if (widget.onDelete != null)
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading:
                        Icon(Icons.delete_outline, color: colorScheme.error),
                    title: Text('Delete',
                        style: TextStyle(color: colorScheme.error)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme, ColorScheme colorScheme,
      String formattedText, bool isLong) {
    return Container(
      padding: const EdgeInsets.all(AppDesign.spacingMd),
      constraints: _expanded ? null : const BoxConstraints(maxHeight: 250),
      clipBehavior: _expanded ? Clip.none : Clip.hardEdge,
      decoration: BoxDecoration(color: colorScheme.surface),
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            child: MarkdownBody(
              data: formattedText,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                p: theme.textTheme.bodyMedium,
                code: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: AppDesign.fontMono,
                    backgroundColor: colorScheme.surfaceContainerHighest),
                codeblockDecoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: AppDesign.borderMd,
                ),
              ),
            ),
          ),
          if (!_expanded && isLong)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colorScheme.surface.withValues(alpha: 0.0),
                        colorScheme.surface,
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandToggle(ThemeData theme, ColorScheme colorScheme) {
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppDesign.spacingSm),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_expanded ? 'Show Less' : 'Show More',
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: colorScheme.primary)),
            const SizedBox(width: AppDesign.spacingXs),
            Icon(
                _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 16,
                color: colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachments(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(AppDesign.spacingMd),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Attachments', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppDesign.spacingSm),
          Wrap(
            spacing: AppDesign.spacingSm,
            runSpacing: AppDesign.spacingSm,
            children: List.generate(_attachments.length, (index) {
              final att = _attachments[index];
              final isImage = att.mimeType.startsWith('image/') &&
                  !att.mimeType.contains('svg');
              return InkWell(
                // Wired to the full attachment viewer in Part D.
                onTap: () => _onAttachmentTap(index),
                borderRadius: AppDesign.borderMd,
                child: Container(
                  width: isImage ? 120 : 150,
                  padding: const EdgeInsets.all(AppDesign.spacingSm),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outlineVariant),
                    borderRadius: AppDesign.borderMd,
                    color: colorScheme.surfaceContainerLowest,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isImage)
                        Container(
                          height: 80,
                          width: double.infinity,
                          margin: const EdgeInsets.only(
                              bottom: AppDesign.spacingSm),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: AppDesign.borderSm,
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Image.file(
                            File(att.localPath),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Center(child: Icon(Icons.broken_image)),
                          ),
                        )
                      else
                        Row(
                          children: [
                            Icon(_iconForAttachment(att),
                                size: 28, color: colorScheme.onSurfaceVariant),
                            const SizedBox(width: AppDesign.spacingSm),
                            const Icon(Icons.open_in_full, size: 14),
                          ],
                        ),
                      const SizedBox(height: AppDesign.spacingXs),
                      Text(att.fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall),
                      if (att.sizeBytes != null)
                        Text(_formatBytes(att.sizeBytes!),
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNotes(ThemeData theme, ColorScheme colorScheme, bool isLong) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDesign.spacingMd),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline,
              size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: AppDesign.spacingSm),
          Expanded(
            child: Text(
              widget.output.notes!,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tintedBadge(String text, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.16),
        borderRadius: AppDesign.borderSm,
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontFamily: AppDesign.fontMono,
          color: accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppDesign.borderSm,
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 10, color: foreground, fontWeight: FontWeight.bold),
      ),
    );
  }

  IconData _iconForAttachment(LLMOutputAttachment att) {
    final type = att.attachmentType ?? '';
    final mime = att.mimeType;
    if (mime.startsWith('video/') || type == 'video') {
      return Icons.movie_outlined;
    }
    if (mime.startsWith('audio/') || type == 'audio') {
      return Icons.audiotrack_outlined;
    }
    if (mime == 'application/pdf' || type == 'pdf') {
      return Icons.picture_as_pdf_outlined;
    }
    if (type == 'archive' || mime.contains('zip')) {
      return Icons.folder_zip_outlined;
    }
    if (type == 'dataset' || mime.contains('csv')) {
      return Icons.table_chart_outlined;
    }
    if (type == 'json' || mime.contains('json')) return Icons.data_object;
    return Icons.insert_drive_file_outlined;
  }

  void _onAttachmentTap(int index) {
    AttachmentViewer.open(
      context,
      sources: _attachments.map(ViewerSource.fromAttachment).toList(),
      initialIndex: index,
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
