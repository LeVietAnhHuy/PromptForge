import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/app_design.dart';
import '../../core/database/database.dart';

/// Detected rendering category for an attachment.
enum AttachmentKind {
  image,
  svg,
  markdown,
  json,
  code,
  csv,
  html,
  text,
  zip,
  pdf,
  video,
  audio,
  unknown,
}

const _codeExtensions = {
  '.dart',
  '.py',
  '.js',
  '.ts',
  '.tsx',
  '.jsx',
  '.java',
  '.kt',
  '.c',
  '.cpp',
  '.h',
  '.hpp',
  '.cc',
  '.cs',
  '.go',
  '.rs',
  '.rb',
  '.php',
  '.swift',
  '.sh',
  '.bash',
  '.zsh',
  '.yaml',
  '.yml',
  '.xml',
  '.sql',
  '.toml',
  '.ini',
  '.gradle',
  '.scala',
  '.lua',
  '.r',
  '.m',
  '.pl',
};

const _imageExtensions = {
  '.png',
  '.jpg',
  '.jpeg',
  '.webp',
  '.gif',
  '.bmp',
  '.heic',
  '.avif',
};

/// Detects how to render an attachment, preferring MIME type then extension.
AttachmentKind detectAttachmentKind(String fileName, String mimeType) {
  final mime = mimeType.toLowerCase();
  final ext = p.extension(fileName).toLowerCase();

  if (mime.contains('svg') || ext == '.svg') return AttachmentKind.svg;
  if (mime.startsWith('image/')) return AttachmentKind.image;
  if (mime.startsWith('video/')) return AttachmentKind.video;
  if (mime.startsWith('audio/')) return AttachmentKind.audio;
  if (mime == 'application/pdf' || ext == '.pdf') return AttachmentKind.pdf;
  if (mime.contains('zip') ||
      mime.contains('compressed') ||
      mime.contains('x-tar') ||
      const {'.zip', '.jar', '.apk', '.war'}.contains(ext)) {
    return AttachmentKind.zip;
  }
  if (mime == 'text/csv' ||
      mime == 'text/tab-separated-values' ||
      ext == '.csv' ||
      ext == '.tsv') {
    return AttachmentKind.csv;
  }
  if (mime.contains('json') || ext == '.json') return AttachmentKind.json;
  if (mime.contains('html') || ext == '.html' || ext == '.htm') {
    return AttachmentKind.html;
  }
  if (mime == 'text/markdown' || ext == '.md' || ext == '.markdown') {
    return AttachmentKind.markdown;
  }
  if (_codeExtensions.contains(ext)) return AttachmentKind.code;
  if (mime.startsWith('text/') ||
      const {'.txt', '.log', '.text', '.env'}.contains(ext)) {
    return AttachmentKind.text;
  }
  if (_imageExtensions.contains(ext)) return AttachmentKind.image;
  return AttachmentKind.unknown;
}

String _formatBytes(int? bytes) {
  if (bytes == null) return '';
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

/// Minimal RFC-4180-style delimited parser: handles quoted fields, embedded
/// delimiters and newlines, and "" escapes. Stops once [maxRows] rows are
/// collected. Used for CSV/TSV previews; treats all input as plain data.
List<List<String>> parseDelimited(String text, String delimiter, int maxRows) {
  final rows = <List<String>>[];
  final field = StringBuffer();
  var row = <String>[];
  var inQuotes = false;

  void endField() {
    row.add(field.toString());
    field.clear();
  }

  void endRow() {
    endField();
    rows.add(row);
    row = [];
  }

  for (var i = 0; i < text.length; i++) {
    final ch = text[i];
    if (inQuotes) {
      if (ch == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        field.write(ch);
      }
    } else if (ch == '"') {
      inQuotes = true;
    } else if (ch == delimiter) {
      endField();
    } else if (ch == '\n') {
      endRow();
      if (rows.length >= maxRows) return rows;
    } else if (ch == '\r') {
      // Swallow; a following \n ends the row.
    } else {
      field.write(ch);
    }
  }
  if (field.isNotEmpty || row.isNotEmpty) endRow();
  return rows;
}

/// A modal viewer overlay for output attachments. Renders supported types
/// inline and offers prev/next navigation plus an "open externally" action for
/// every attachment. All attachment bytes are treated as untrusted data and are
/// only ever rendered — never executed.
class AttachmentViewer extends StatefulWidget {
  final List<LLMOutputAttachment> attachments;
  final int initialIndex;

  const AttachmentViewer({
    super.key,
    required this.attachments,
    this.initialIndex = 0,
  });

  static Future<void> open(
    BuildContext context, {
    required List<LLMOutputAttachment> attachments,
    int initialIndex = 0,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => AttachmentViewer(
          attachments: attachments, initialIndex: initialIndex),
    );
  }

  @override
  State<AttachmentViewer> createState() => _AttachmentViewerState();
}

class _AttachmentViewerState extends State<AttachmentViewer> {
  late int _index;
  final TransformationController _imageTransform = TransformationController();
  bool _markdownRaw = false;
  final FocusNode _focusNode = FocusNode();

  // Max bytes to read for text-based previews.
  static const int _maxTextBytes = 2 * 1024 * 1024;
  static const int _maxCsvRows = 500;

  // Loaders are memoized per attachment so they run once — never re-created on
  // every rebuild (which would re-read the file each frame and never settle).
  Future<_TextLoad>? _textFuture;
  Future<_CsvLoad>? _csvFuture;
  Future<List<_ZipEntry>?>? _zipFuture;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.attachments.length - 1);
    _prepareLoaders();
  }

  @override
  void dispose() {
    _imageTransform.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  LLMOutputAttachment get _current => widget.attachments[_index];

  void _prepareLoaders() {
    _textFuture = null;
    _csvFuture = null;
    _zipFuture = null;
    final att = _current;
    final file = File(att.localPath);
    if (!file.existsSync()) return;
    final kind = detectAttachmentKind(att.fileName, att.mimeType);
    switch (kind) {
      case AttachmentKind.markdown:
      case AttachmentKind.json:
      case AttachmentKind.code:
      case AttachmentKind.html:
      case AttachmentKind.text:
        _textFuture = _loadText(file);
      case AttachmentKind.csv:
        final isTsv = att.mimeType.contains('tab') ||
            p.extension(att.fileName).toLowerCase() == '.tsv';
        _csvFuture = _loadCsv(file, isTsv);
      case AttachmentKind.zip:
        _zipFuture = _loadZip(file);
      default:
        break;
    }
  }

  void _go(int delta) {
    final next = _index + delta;
    if (next < 0 || next >= widget.attachments.length) return;
    setState(() {
      _index = next;
      _imageTransform.value = Matrix4.identity();
      _markdownRaw = false;
      _prepareLoaders();
    });
  }

  Future<void> _openExternally() async {
    try {
      final ok = await launchUrl(Uri.file(_current.localPath));
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('No app available to open this file.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not open file: $e')));
      }
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).maybePop();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _go(-1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _go(1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final att = _current;
    final kind = detectAttachmentKind(att.fileName, att.mimeType);
    final hasMultiple = widget.attachments.length > 1;

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _onKey,
      child: Dialog(
        insetPadding: const EdgeInsets.all(AppDesign.spacingXl),
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppDesign.borderModal,
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 760),
          child: Column(
            children: [
              _buildHeader(theme, att, kind),
              const Divider(height: 1),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: KeyedSubtree(
                        key: ValueKey(att.id),
                        child: _buildRenderer(theme, att, kind),
                      ),
                    ),
                    if (hasMultiple) ..._buildNavArrows(theme),
                  ],
                ),
              ),
              if (hasMultiple) _buildFooter(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      ThemeData theme, LLMOutputAttachment att, AttachmentKind kind) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDesign.spacingMd,
          AppDesign.spacingSm, AppDesign.spacingSm, AppDesign.spacingSm),
      child: Row(
        children: [
          Icon(_iconFor(kind), color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: AppDesign.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(att.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall),
                Text(
                  [
                    _kindLabel(kind),
                    if (att.sizeBytes != null) _formatBytes(att.sizeBytes),
                  ].join(' · '),
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (kind == AttachmentKind.markdown)
            TextButton.icon(
              onPressed: () => setState(() => _markdownRaw = !_markdownRaw),
              icon: Icon(_markdownRaw ? Icons.article : Icons.code, size: 18),
              label: Text(_markdownRaw ? 'Rendered' : 'Raw'),
            ),
          if (kind == AttachmentKind.image)
            IconButton(
              tooltip: 'Reset zoom',
              icon: const Icon(Icons.zoom_out_map),
              onPressed: () =>
                  setState(() => _imageTransform.value = Matrix4.identity()),
            ),
          IconButton(
            tooltip: 'Open externally / download',
            icon: const Icon(Icons.open_in_new),
            onPressed: _openExternally,
          ),
          IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNavArrows(ThemeData theme) {
    Widget arrow(IconData icon, int delta, Alignment alignment, bool enabled) {
      return Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(AppDesign.spacingSm),
          child: Material(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.85),
            shape: const CircleBorder(),
            child: IconButton(
              icon: Icon(icon),
              onPressed: enabled ? () => _go(delta) : null,
            ),
          ),
        ),
      );
    }

    return [
      arrow(Icons.chevron_left, -1, Alignment.centerLeft, _index > 0),
      arrow(Icons.chevron_right, 1, Alignment.centerRight,
          _index < widget.attachments.length - 1),
    ];
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppDesign.spacingSm),
      decoration: BoxDecoration(
        border:
            Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Text(
        '${_index + 1} of ${widget.attachments.length}',
        textAlign: TextAlign.center,
        style: theme.textTheme.labelMedium
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildRenderer(
      ThemeData theme, LLMOutputAttachment att, AttachmentKind kind) {
    final file = File(att.localPath);
    if (!file.existsSync()) {
      return _fallback(theme, kind,
          message: 'The original file is no longer available on disk.');
    }

    switch (kind) {
      case AttachmentKind.image:
        return _buildImage(theme, file);
      case AttachmentKind.svg:
        return _buildSvg(theme, file);
      case AttachmentKind.markdown:
        return _buildTextLike(theme, file.path, kind);
      case AttachmentKind.json:
      case AttachmentKind.code:
      case AttachmentKind.html:
      case AttachmentKind.text:
        return _buildTextLike(theme, file.path, kind);
      case AttachmentKind.csv:
        return _buildCsv(theme);
      case AttachmentKind.zip:
        return _buildZip(theme);
      case AttachmentKind.pdf:
      case AttachmentKind.video:
      case AttachmentKind.audio:
      case AttachmentKind.unknown:
        return _fallback(theme, kind);
    }
  }

  Widget _buildImage(ThemeData theme, File file) {
    return ColoredBox(
      color: Colors.black,
      child: InteractiveViewer(
        transformationController: _imageTransform,
        minScale: 0.5,
        maxScale: 6,
        child: Center(
          child: Image.file(
            file,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _fallback(theme, AttachmentKind.image,
                message: 'Could not decode this image.'),
          ),
        ),
      ),
    );
  }

  Widget _buildSvg(ThemeData theme, File file) {
    return ColoredBox(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(AppDesign.spacingLg),
        child: SvgPicture.file(
          file,
          fit: BoxFit.contain,
          placeholderBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildTextLike(ThemeData theme, String filePath, AttachmentKind kind) {
    return FutureBuilder<_TextLoad>(
      future: _textFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final load = snap.data;
        if (load == null || load.error != null) {
          return _fallback(theme, kind,
              message: load?.error ?? 'Could not read file.');
        }
        if (kind == AttachmentKind.markdown && !_markdownRaw) {
          return Markdown(
            data: load.content,
            selectable: true,
            padding: const EdgeInsets.all(AppDesign.spacingLg),
          );
        }
        final lang = _highlightLanguage(filePath, kind);
        return Column(
          children: [
            if (load.truncated) _truncatedBanner(theme),
            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  child: HighlightView(
                    load.content,
                    language: lang,
                    theme: atomOneDarkTheme,
                    padding: const EdgeInsets.all(AppDesign.spacingLg),
                    textStyle: const TextStyle(
                        fontFamily: AppDesign.fontMono, fontSize: 13),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCsv(ThemeData theme) {
    return FutureBuilder<_CsvLoad>(
      future: _csvFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final load = snap.data;
        if (load == null || load.error != null || load.rows.isEmpty) {
          return _fallback(theme, AttachmentKind.csv,
              message: load?.error ?? 'No rows to display.');
        }
        final header = load.rows.first;
        final body = load.rows.skip(1).toList();
        return Column(
          children: [
            if (load.truncated)
              _truncatedBanner(theme,
                  text: 'Showing the first $_maxCsvRows rows.'),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStatePropertyAll(
                        theme.colorScheme.surfaceContainerHighest),
                    columns: [
                      for (final c in header)
                        DataColumn(
                            label: Text(c.toString(),
                                style: theme.textTheme.labelMedium)),
                    ],
                    rows: [
                      for (final row in body)
                        DataRow(cells: [
                          for (var i = 0; i < header.length; i++)
                            DataCell(Text(
                                i < row.length ? row[i].toString() : '',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    fontFamily: AppDesign.fontMono))),
                        ]),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildZip(ThemeData theme) {
    return FutureBuilder<List<_ZipEntry>?>(
      future: _zipFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final entries = snap.data;
        if (entries == null) {
          return _fallback(theme, AttachmentKind.zip,
              message: 'Could not read archive.');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDesign.spacingMd),
              child: Text('${entries.length} entries (not extracted)',
                  style: theme.textTheme.titleSmall),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: entries.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: theme.colorScheme.outlineVariant),
                itemBuilder: (context, i) {
                  final e = entries[i];
                  return ListTile(
                    dense: true,
                    leading: Icon(
                        e.isDir
                            ? Icons.folder_outlined
                            : Icons.insert_drive_file_outlined,
                        size: 18),
                    title: Text(e.name,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(fontFamily: AppDesign.fontMono)),
                    trailing: e.isDir
                        ? null
                        : Text(_formatBytes(e.size),
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _truncatedBanner(ThemeData theme, {String? text}) {
    return Container(
      width: double.infinity,
      color: context.forge.warningContainer,
      padding: const EdgeInsets.symmetric(
          horizontal: AppDesign.spacingMd, vertical: AppDesign.spacingSm),
      child: Text(
          text ?? 'Preview truncated — open externally for the full file.',
          style: theme.textTheme.labelSmall
              ?.copyWith(color: context.forge.warning)),
    );
  }

  Widget _fallback(ThemeData theme, AttachmentKind kind, {String? message}) {
    final needsExternal = kind == AttachmentKind.pdf ||
        kind == AttachmentKind.video ||
        kind == AttachmentKind.audio;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDesign.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_iconFor(kind),
                size: 64, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: AppDesign.spacingMd),
            Text(_current.fileName,
                style: theme.textTheme.titleSmall, textAlign: TextAlign.center),
            const SizedBox(height: AppDesign.spacingXs),
            Text(
              message ??
                  (needsExternal
                      ? 'In-app playback of ${_kindLabel(kind)} files needs a system viewer.'
                      : 'No inline preview is available for this file type.'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppDesign.spacingLg),
            FilledButton.icon(
              onPressed: _openExternally,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open externally'),
            ),
          ],
        ),
      ),
    );
  }

  // --- Loaders ---

  Future<_TextLoad> _loadText(File file) async {
    try {
      final length = await file.length();
      final truncated = length > _maxTextBytes;
      String content;
      if (truncated) {
        final raf = await file.open();
        final bytes = await raf.read(_maxTextBytes);
        await raf.close();
        content = String.fromCharCodes(bytes);
      } else {
        content = await file.readAsString();
      }
      return _TextLoad(content: content, truncated: truncated);
    } catch (e) {
      return _TextLoad(
          content: '', truncated: false, error: 'Could not read file: $e');
    }
  }

  Future<_CsvLoad> _loadCsv(File file, bool isTsv) async {
    try {
      // Bound the read so a huge file can't exhaust memory (mirrors _loadText).
      final length = await file.length();
      final byteTruncated = length > _maxTextBytes;
      String text;
      if (byteTruncated) {
        final raf = await file.open();
        final bytes = await raf.read(_maxTextBytes);
        await raf.close();
        text = String.fromCharCodes(bytes);
      } else {
        text = await file.readAsString();
      }
      const cap = _maxCsvRows + 1; // header + rows
      final rows = parseDelimited(text, isTsv ? '\t' : ',', cap + 1);
      final rowTruncated = rows.length > cap;
      return _CsvLoad(
        rows: rowTruncated ? rows.sublist(0, cap) : rows,
        truncated: rowTruncated || byteTruncated,
      );
    } catch (e) {
      return _CsvLoad(
          rows: const [], truncated: false, error: 'Could not parse: $e');
    }
  }

  Future<List<_ZipEntry>?> _loadZip(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      return [
        for (final f in archive.files)
          _ZipEntry(name: f.name, size: f.size, isDir: !f.isFile),
      ]..sort((a, b) => a.name.compareTo(b.name));
    } catch (_) {
      return null;
    }
  }

  // --- Labels / icons ---

  String _kindLabel(AttachmentKind kind) => switch (kind) {
        AttachmentKind.image => 'Image',
        AttachmentKind.svg => 'SVG',
        AttachmentKind.markdown => 'Markdown',
        AttachmentKind.json => 'JSON',
        AttachmentKind.code => 'Code',
        AttachmentKind.csv => 'Table',
        AttachmentKind.html => 'HTML',
        AttachmentKind.text => 'Text',
        AttachmentKind.zip => 'Archive',
        AttachmentKind.pdf => 'PDF',
        AttachmentKind.video => 'Video',
        AttachmentKind.audio => 'Audio',
        AttachmentKind.unknown => 'File',
      };

  IconData _iconFor(AttachmentKind kind) => switch (kind) {
        AttachmentKind.image => Icons.image_outlined,
        AttachmentKind.svg => Icons.image_outlined,
        AttachmentKind.markdown => Icons.notes_outlined,
        AttachmentKind.json => Icons.data_object,
        AttachmentKind.code => Icons.code,
        AttachmentKind.csv => Icons.table_chart_outlined,
        AttachmentKind.html => Icons.html,
        AttachmentKind.text => Icons.description_outlined,
        AttachmentKind.zip => Icons.folder_zip_outlined,
        AttachmentKind.pdf => Icons.picture_as_pdf_outlined,
        AttachmentKind.video => Icons.movie_outlined,
        AttachmentKind.audio => Icons.audiotrack_outlined,
        AttachmentKind.unknown => Icons.insert_drive_file_outlined,
      };

  String _highlightLanguage(String path, AttachmentKind kind) {
    if (kind == AttachmentKind.json) return 'json';
    if (kind == AttachmentKind.html) return 'xml';
    if (kind == AttachmentKind.markdown) return 'markdown';
    switch (p.extension(path).toLowerCase()) {
      case '.dart':
        return 'dart';
      case '.py':
        return 'python';
      case '.js':
      case '.jsx':
        return 'javascript';
      case '.ts':
      case '.tsx':
        return 'typescript';
      case '.java':
        return 'java';
      case '.kt':
        return 'kotlin';
      case '.c':
      case '.h':
        return 'c';
      case '.cpp':
      case '.cc':
      case '.hpp':
        return 'cpp';
      case '.cs':
        return 'cs';
      case '.go':
        return 'go';
      case '.rs':
        return 'rust';
      case '.rb':
        return 'ruby';
      case '.php':
        return 'php';
      case '.swift':
        return 'swift';
      case '.sh':
      case '.bash':
      case '.zsh':
        return 'bash';
      case '.yaml':
      case '.yml':
        return 'yaml';
      case '.xml':
        return 'xml';
      case '.sql':
        return 'sql';
      default:
        return 'plaintext';
    }
  }
}

class _TextLoad {
  final String content;
  final bool truncated;
  final String? error;
  const _TextLoad({required this.content, required this.truncated, this.error});
}

class _CsvLoad {
  final List<List<String>> rows;
  final bool truncated;
  final String? error;
  const _CsvLoad({required this.rows, required this.truncated, this.error});
}

class _ZipEntry {
  final String name;
  final int size;
  final bool isDir;
  const _ZipEntry(
      {required this.name, required this.size, required this.isDir});
}
