import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database.dart';
import '../../../core/database/daos/daos.dart';
import '../../../core/database/database_providers.dart';
import 'attachment_picker_service.dart';

class PersistResult {
  final int saved;
  final int failed;
  const PersistResult(this.saved, this.failed);
  bool get ok => failed == 0;
}

/// Copies picked attachment drafts into the app's per-output storage and writes
/// their DB rows. Each file is stored under a **unique** destination name
/// (`<uuid>__<originalName>`) so attachments that share a base name never
/// overwrite each other — the root cause of the "3 attached, 2 saved" bug. The
/// original `fileName` is preserved in the column for display.
class AttachmentStorageService {
  AttachmentStorageService(this._attachmentDao, {Directory? storageRoot})
      : _storageRoot = storageRoot;

  final LLMOutputAttachmentDao _attachmentDao;
  final Directory? _storageRoot;
  static const _uuid = Uuid();

  Future<Directory> _attachmentsDirFor(String outputId) async {
    final root = _storageRoot ?? await getApplicationDocumentsDirectory();
    final dir =
        Directory(p.join(root.path, 'promptforge', 'attachments', outputId));
    await dir.create(recursive: true);
    return dir;
  }

  /// Persists [drafts] for [outputId]. Returns how many succeeded/failed so the
  /// caller can warn the user instead of losing attachments silently.
  Future<PersistResult> persistDrafts(
    String outputId,
    List<OutputAttachmentDraft> drafts, {
    DateTime? now,
  }) async {
    if (drafts.isEmpty) return const PersistResult(0, 0);
    final stamp = now ?? DateTime.now();
    final dir = await _attachmentsDirFor(outputId);
    var saved = 0;
    var failed = 0;

    for (final draft in drafts) {
      final id = _uuid.v4();
      try {
        final safeName = '${id}__${_sanitize(draft.fileName)}';
        final targetPath = p.join(dir.path, safeName);
        if (draft.path != null) {
          await File(draft.path!).copy(targetPath);
        } else {
          failed++;
          continue;
        }
        await _attachmentDao
            .createAttachment(LLMOutputAttachmentsCompanion.insert(
          id: id,
          outputId: outputId,
          fileName: draft.fileName,
          mimeType: draft.mimeType ?? 'application/octet-stream',
          sizeBytes: draft.sizeBytes != null
              ? drift.Value(draft.sizeBytes!)
              : const drift.Value.absent(),
          localPath: targetPath,
          attachmentType: drift.Value(draft.attachmentType),
          createdAt: stamp,
        ));
        saved++;
      } catch (_) {
        failed++;
      }
    }
    return PersistResult(saved, failed);
  }

  /// Removes an attachment's DB row and best-effort deletes its stored file.
  Future<void> deleteAttachment(LLMOutputAttachment att) async {
    await _attachmentDao.deleteAttachment(att.id);
    try {
      final f = File(att.localPath);
      if (f.existsSync()) f.deleteSync();
    } catch (_) {
      // Best-effort; ignore filesystem failures.
    }
  }

  String _sanitize(String name) => name.replaceAll(RegExp(r'[/\\\x00]'), '_');
}

final attachmentStorageServiceProvider =
    Provider<AttachmentStorageService>((ref) {
  return AttachmentStorageService(ref.watch(lLMOutputAttachmentDaoProvider));
});
