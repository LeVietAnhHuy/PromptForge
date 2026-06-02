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

    return ListView.builder(
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
              child: Builder(
                builder: (context) {
                  // For empty lines, render some clickable vertical space
                  if (block.type == MarkdownBlockType.empty) {
                    return const SizedBox(height: 20, width: double.infinity);
                  }
                  return MarkdownBody(
                    data: block.rawText,
                    selectable: false, // Disabling selectability to allow tapping the block
                    fitContent: true,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
