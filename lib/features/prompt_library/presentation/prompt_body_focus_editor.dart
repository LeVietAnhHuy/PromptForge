import 'package:flutter/material.dart';
import '../../../shared/markdown/inline_markdown_editor.dart';
import '../../../shared/markdown/markdown_reader_style.dart';
import '../../../app/theme/app_design.dart';

enum _FocusViewMode { preview, edit }

class PromptBodyFocusEditor extends StatefulWidget {
  final String initialText;

  const PromptBodyFocusEditor({
    super.key,
    required this.initialText,
  });

  /// Opens the focus editor as a full-screen or large centered dialog.
  /// Returns the edited text if the user clicked "Save/Apply".
  /// Returns null if the user cancelled.
  static Future<String?> show(BuildContext context, String initialText) {
    return Navigator.of(context).push<String>(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        barrierColor: Colors.black54,
        transitionDuration: AppDesign.durationNormal,
        reverseTransitionDuration: AppDesign.durationFast,
        pageBuilder: (context, animation, secondaryAnimation) {
          return PromptBodyFocusEditor(initialText: initialText);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curve,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1.0).animate(curve),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  State<PromptBodyFocusEditor> createState() => _PromptBodyFocusEditorState();
}

class _PromptBodyFocusEditorState extends State<PromptBodyFocusEditor> {
  late final TextEditingController _controller;
  _FocusViewMode _viewMode = _FocusViewMode.preview;
  MarkdownReaderStyle _readerStyle = MarkdownReaderStyle.promptForge;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSave() {
    Navigator.of(context).pop(_controller.text);
  }

  Future<void> _handleCancel() async {
    if (_controller.text != widget.initialText) {
      final shouldDiscard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text('You have unsaved changes in the focus editor. Do you want to discard them?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep Editing'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
      if (shouldDiscard != true) return;
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDesign.spacingMd),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _handleCancel,
            tooltip: 'Cancel',
          ),
          const SizedBox(width: AppDesign.spacingSm),
          Text(
            'Focus Editor',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppDesign.spacingMd,
              runSpacing: AppDesign.spacingSm,
              children: [
                if (_viewMode == _FocusViewMode.preview)
                  DropdownButton<MarkdownReaderStyle>(
                    value: _readerStyle,
                    underline: const SizedBox(),
                    isDense: true,
                    iconSize: 20,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    items: MarkdownReaderStyle.values.map((style) {
                      return DropdownMenuItem(
                        value: style,
                        child: Text(style.displayName),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _readerStyle = val);
                    },
                  ),
                SegmentedButton<_FocusViewMode>(
                  segments: const [
                    ButtonSegment(value: _FocusViewMode.preview, label: Text('Preview')),
                    ButtonSegment(value: _FocusViewMode.edit, label: Text('Edit')),
                  ],
                  selected: {_viewMode},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _viewMode = newSelection.first;
                      if (_viewMode == _FocusViewMode.preview) {
                        FocusScope.of(context).unfocus();
                      }
                    });
                  },
                ),
                FilledButton.icon(
                  onPressed: _handleSave,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Apply'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < AppDesign.mobileBreakpoint;

    Widget body;
    if (_viewMode == _FocusViewMode.edit) {
      body = Padding(
        padding: const EdgeInsets.all(AppDesign.spacingLg),
        child: TextFormField(
          controller: _controller,
          decoration: const InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            hintText: 'Enter prompt body (Markdown supported)...',
            filled: false,
          ),
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
      );
    } else {
      body = InlineMarkdownEditor(
        controller: _controller,
        readerStyle: _readerStyle,
      );
    }

    Widget content = Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: body),
          ],
        ),
      ),
    );

    if (isMobile) {
      return content;
    }

    // Desktop modal wrapper
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleCancel();
      },
      child: GestureDetector(
        onTap: _handleCancel,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: GestureDetector(
              onTap: () {}, // Block taps from closing modal
              child: Container(
                width: size.width * 0.85,
                height: size.height * 0.90,
                decoration: BoxDecoration(
                  borderRadius: AppDesign.borderModal,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: AppDesign.borderModal,
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
