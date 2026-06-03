import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../domain/markdown_block_parser.dart';
import '../domain/markdown_reader_style.dart';

class InlineMarkdownEditor extends StatefulWidget {
  final TextEditingController controller;
  final MarkdownReaderStyle readerStyle;

  const InlineMarkdownEditor({
    super.key,
    required this.controller,
    this.readerStyle = MarkdownReaderStyle.promptForge,
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
  final Map<String, String> _blockIdToTocId = {};
  final _scrollController = ScrollController();
  
  String? _activeTocId;
  bool _isProgrammaticScroll = false;

  @override
  void initState() {
    super.initState();
    _blockEditController = TextEditingController();
    _parseBlocks();
    widget.controller.addListener(_onControllerChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _blockEditController.dispose();
    _focusNode.dispose();
    _scrollController.removeListener(_onScroll);
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
      
      _blockIdToTocId.clear();
      for (final item in _tocItems) {
        _blockIdToTocId[item.blockId] = item.id;
      }
      
      // Clean up unused keys by TOC ID (which is stable)
      final currentTocIds = _tocItems.map((t) => t.id).toSet();
      _headingKeys.removeWhere((id, key) => !currentTocIds.contains(id));
      
      // Update active heading initially
      WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isProgrammaticScroll) return;
    
    // Find the heading closest to the top of the viewport
    String? newActiveId;
    double minDistance = double.infinity;
    
    for (final item in _tocItems) {
      final key = _headingKeys[item.id];
      if (key != null && key.currentContext != null) {
        final RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);
        
        // dy is relative to the screen. 
        // We want the heading that is closest to the top (or just above it).
        // 120 is roughly the height of the AppBar + toolbar
        if (position.dy <= 160) {
          newActiveId = item.id;
        } else if (newActiveId == null && position.dy < minDistance) {
          // Fallback to the closest one if none are above the threshold
          minDistance = position.dy;
          newActiveId = item.id;
        }
      }
    }
    
    if (newActiveId != _activeTocId) {
      setState(() {
        _activeTocId = newActiveId;
      });
    }
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

  Future<void> _scrollToHeading(String tocId) async {
    final key = _headingKeys[tocId];
    if (key != null && key.currentContext != null) {
      setState(() {
        _activeTocId = tocId;
        _isProgrammaticScroll = true;
      });
      
      final renderObject = key.currentContext!.findRenderObject();
      if (renderObject != null) {
        final viewport = RenderAbstractViewport.of(renderObject);
        if (viewport != null) {
          final reveal = viewport.getOffsetToReveal(renderObject, 0.0);
          final target = (reveal.offset - 16.0).clamp(0.0, _scrollController.position.maxScrollExtent);
          
          await _scrollController.animateTo(
            target,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
          );
        }
      }
      
      if (mounted) {
        setState(() {
          _isProgrammaticScroll = false;
        });
      }
    }
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
                final isActive = item.id == _activeTocId;
                
                return InkWell(
                  onTap: () => _scrollToHeading(item.id),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    decoration: isActive
                        ? BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                            border: Border(left: BorderSide(color: Theme.of(context).colorScheme.primary, width: 3)),
                          )
                        : const BoxDecoration(
                            border: Border(left: BorderSide(color: Colors.transparent, width: 3)),
                          ),
                    padding: EdgeInsets.only(
                      left: 8.0 + (item.level - 1) * 12.0,
                      top: 8.0,
                      bottom: 8.0,
                      right: 8.0,
                    ),
                    child: Text(
                      item.text,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isActive 
                            ? Theme.of(context).colorScheme.onSurface 
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
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
    final styleSheet = widget.readerStyle.buildStyleSheet(context);

    // Using SingleChildScrollView + Column instead of ListView.builder 
    // ensures all heading blocks are mounted and have valid GlobalKeys.
    // This makes Scrollable.ensureVisible work perfectly for TOC jumps.
    final listView = SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _blocks.map((block) {
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
            final tocId = _blockIdToTocId[block.id];
            if (tocId != null) {
              final key = _headingKeys.putIfAbsent(tocId, () => GlobalKey());
              blockContent = Container(key: key, child: blockContent);
            }
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
        }).toList(),
      ),
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
