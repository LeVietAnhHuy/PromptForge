import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../domain/markdown_block_parser.dart';

class InlineMarkdownEditor extends StatefulWidget {
  final TextEditingController controller;

  const InlineMarkdownEditor({
    super.key,
    required this.controller,
  });

  @override
  State<InlineMarkdownEditor> createState() => _InlineMarkdownEditorState();
}

class _InlineMarkdownEditorState extends State<InlineMarkdownEditor> {
  final _parser = MarkdownBlockParser();
  List<MarkdownBlock> _blocks = [];
  String? _editingBlockId;
  late TextEditingController _blockEditController;
  final _focusNode = FocusNode();
  
  List<MarkdownTocItem> _tocItems = [];
  final Map<String, GlobalKey> _headingKeys = {};
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _blockEditController = TextEditingController();
    _parseBlocks();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _blockEditController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (_editingBlockId == null) {
      _parseBlocks();
    }
  }

  void _parseBlocks() {
    setState(() {
      _blocks = _parser.parse(widget.controller.text);
      _tocItems = _parser.extractToc(_blocks);
      
      // Clean up unused keys
      final currentHeadingBlockIds = _blocks.where((b) => b.type == MarkdownBlockType.heading).map((b) => b.id).toSet();
      _headingKeys.removeWhere((id, key) => !currentHeadingBlockIds.contains(id));
    });
  }

  void _startEditing(MarkdownBlock block) {
    setState(() {
      _editingBlockId = block.id;
      _blockEditController.text = block.rawText;
    });
    // Request focus on next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNode.canRequestFocus) {
        _focusNode.requestFocus();
      }
    });
  }

  void _commitEdit(MarkdownBlock block) {
    if (_editingBlockId != block.id) return;
    
    final newText = _blockEditController.text;
    if (newText != block.rawText) {
      final lines = widget.controller.text.split('\n');
      final newLines = newText.split('\n');
      
      // Ensure we don't go out of bounds
      if (block.startLine <= lines.length) {
        final endLine = block.endLine < lines.length ? block.endLine : lines.length - 1;
        lines.replaceRange(block.startLine, endLine + 1, newLines);
        
        final fullText = lines.join('\n');
        
        // Remove listener temporarily to avoid recursive parsing
        widget.controller.removeListener(_onControllerChanged);
        widget.controller.text = fullText;
        widget.controller.addListener(_onControllerChanged);
      }
    }
    
    setState(() {
      _editingBlockId = null;
    });
    _parseBlocks();
  }

  void _cancelEdit() {
    setState(() {
      _editingBlockId = null;
    });
  }

  void _scrollToHeading(String blockId) {
    final key = _headingKeys[blockId];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  MarkdownStyleSheet _buildStyleSheet(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
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
  }

  Widget _buildTocSidebar() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Theme.of(context).dividerColor)),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Contents',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _tocItems.length,
              itemBuilder: (context, index) {
                final item = _tocItems[index];
                return InkWell(
                  onTap: () => _scrollToHeading(item.blockId),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 8.0 + (item.level - 1) * 16.0,
                      top: 8.0,
                      bottom: 8.0,
                      right: 8.0,
                    ),
                    child: Text(
                      item.text,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showMobileToc() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildTocSidebar(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_blocks.isEmpty) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // If empty, just focus the full editor or start an empty block
          _startEditing(MarkdownBlock(
            id: 'empty',
            startLine: 0,
            endLine: 0,
            rawText: '',
            type: MarkdownBlockType.empty,
          ));
        },
        child: const Center(
          child: Text(
            'Click anywhere to start typing',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final showSidebar = isDesktop && _tocItems.length >= 2;
    final showMobileFab = !isDesktop && _tocItems.length >= 2;
    final styleSheet = _buildStyleSheet(context);

    final listView = ListView.builder(
      controller: _scrollController,
      itemCount: _blocks.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        final block = _blocks[index];
        final isEditing = _editingBlockId == block.id;

        if (isEditing) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.primary),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TextField(
                      controller: _blockEditController,
                      focusNode: _focusNode,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(8),
                      ),
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      tooltip: 'Save Block',
                      onPressed: () => _commitEdit(block),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      tooltip: 'Cancel Edit',
                      onPressed: _cancelEdit,
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        Widget blockContent;
        // For empty lines, render some clickable vertical space
        if (block.type == MarkdownBlockType.empty) {
          blockContent = const SizedBox(height: 20, width: double.infinity);
        } else {
          blockContent = MarkdownBody(
            data: block.rawText,
            selectable: false, // Disabling selectability to allow tapping the block
            fitContent: true,
            styleSheet: styleSheet,
          );
        }

        // Attach GlobalKey only to heading blocks
        if (block.type == MarkdownBlockType.heading) {
          final key = _headingKeys.putIfAbsent(block.id, () => GlobalKey());
          blockContent = Container(key: key, child: blockContent);
        }

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => _startEditing(block),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent),
                borderRadius: BorderRadius.circular(4),
              ),
              child: blockContent,
            ),
          ),
        );
      },
    );

    final content = showSidebar
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: listView),
              _buildTocSidebar(),
            ],
          )
        : listView;

    if (showMobileFab) {
      return Stack(
        children: [
          content,
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: () {
                // If in edit mode, tapping this doesn't break anything, but we might want to defocus
                FocusScope.of(context).unfocus();
                _showMobileToc();
              },
              child: const Icon(Icons.list),
              tooltip: 'Contents',
            ),
          ),
        ],
      );
    }

    return content;
  }
}
