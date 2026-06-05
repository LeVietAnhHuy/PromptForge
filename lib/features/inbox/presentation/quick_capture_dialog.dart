import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/app_design.dart';
import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';
import '../../../shared/shortcuts/keyboard_shortcuts.dart';

/// Fast "jot it down" capture into the Inbox, opened with Ctrl/Cmd+Shift+N from
/// anywhere in the shell. Prefills the body from the clipboard so a copied
/// snippet lands one keystroke away, then saves an open inbox item to triage
/// later. Kept deliberately minimal — title is optional, body is the point.
class QuickCaptureDialog extends ConsumerStatefulWidget {
  const QuickCaptureDialog({super.key});

  /// Opens the dialog. Guards against stacking duplicates if the chord repeats.
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const QuickCaptureDialog(),
    );
  }

  @override
  ConsumerState<QuickCaptureDialog> createState() => _QuickCaptureDialogState();
}

class _QuickCaptureDialogState extends ConsumerState<QuickCaptureDialog> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _bodyFocus = FocusNode();
  bool _prefilled = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _prefillFromClipboard();
  }

  Future<void> _prefillFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (!mounted) return;
    setState(() {
      if (text.isNotEmpty) {
        _bodyController.text = text;
        _bodyController.selection =
            TextSelection.collapsed(offset: _bodyController.text.length);
      }
      _prefilled = true;
    });
    // Focus the body so the user can keep typing or hit save immediately.
    _bodyFocus.requestFocus();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _bodyFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final body = _bodyController.text.trim();
    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing to capture — add some text.')),
      );
      return;
    }
    setState(() => _saving = true);
    final now = DateTime.now();
    final title = _titleController.text.trim();
    await ref.read(inboxItemDaoProvider).createInboxItem(
          InboxItemsCompanion.insert(
            id: const Uuid().v4(),
            title: Value(title.isEmpty ? null : title),
            rawText: body,
            source: const Value('quick-capture'),
            createdAt: now,
            updatedAt: now,
          ),
        );
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Captured to Inbox.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Ctrl/Cmd+Enter saves without reaching for the mouse.
    return CallbackShortcuts(
      bindings: {
        cmdOrCtrl(LogicalKeyboardKey.enter): _save,
      },
      child: AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.bolt, color: AppDesign.emberBright),
            const SizedBox(width: AppDesign.spacingSm),
            const Text('Quick Capture'),
            const Spacer(),
            Text('Inbox',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Title (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppDesign.spacingMd),
              TextField(
                controller: _bodyController,
                focusNode: _bodyFocus,
                maxLines: 8,
                minLines: 4,
                decoration: InputDecoration(
                  labelText: 'Capture',
                  alignLabelWithHint: true,
                  helperText: _prefilled
                      ? 'Prefilled from clipboard · Ctrl/Cmd+Enter to save'
                      : 'Ctrl/Cmd+Enter to save',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save),
            label: const Text('Capture'),
          ),
        ],
      ),
    );
  }
}
