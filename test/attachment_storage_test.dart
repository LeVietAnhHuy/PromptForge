import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/features/prompt_examples/application/attachment_picker_service.dart';
import 'package:promptforge/features/prompt_examples/application/attachment_storage_service.dart';

void main() {
  late AppDatabase db;
  late Directory root;
  late AttachmentStorageService storage;

  setUp(() async {
    db = AppDatabase(e: NativeDatabase.memory());
    root = await Directory.systemTemp.createTemp('pf_storage_test');
    storage = AttachmentStorageService(db.lLMOutputAttachmentDao,
        storageRoot: root);
  });

  tearDown(() async {
    await db.close();
    await root.delete(recursive: true);
  });

  OutputAttachmentDraft draftFor(File f, String type, String mime) =>
      OutputAttachmentDraft(
          fileName: f.uri.pathSegments.last,
          path: f.path,
          mimeType: mime,
          sizeBytes: f.lengthSync(),
          attachmentType: type);

  Future<List<OutputAttachmentDraft>> threeDrafts() async {
    final pdf = File('${root.path}/doc.pdf')..writeAsStringSync('%PDF-1.4');
    final png = File('${root.path}/img.png')..writeAsBytesSync([1, 2, 3]);
    final jpg = File('${root.path}/img.jpg')..writeAsBytesSync([4, 5, 6]);
    return [
      draftFor(pdf, 'pdf', 'application/pdf'),
      draftFor(png, 'image', 'image/png'),
      draftFor(jpg, 'image', 'image/jpeg'),
    ];
  }

  test('persists all 3 attachments of different types (create flow)', () async {
    final res = await storage.persistDrafts('out-1', await threeDrafts());
    expect(res.saved, 3);
    expect(res.failed, 0);

    final rows = await db.lLMOutputAttachmentDao.getAttachmentsForOutput('out-1');
    expect(rows.length, 3);
    // All stored files exist and original display names are preserved.
    for (final r in rows) {
      expect(File(r.localPath).existsSync(), isTrue, reason: r.fileName);
    }
    expect(rows.map((r) => r.fileName).toSet(),
        {'doc.pdf', 'img.png', 'img.jpg'});
  });

  test('adding a 3rd attachment to an existing output keeps all 3 (edit flow)',
      () async {
    // Existing output already has 2 attachments.
    final pdf = File('${root.path}/a.pdf')..writeAsStringSync('%PDF');
    final png = File('${root.path}/a.png')..writeAsBytesSync([1]);
    await storage.persistDrafts('out-2', [
      draftFor(pdf, 'pdf', 'application/pdf'),
      draftFor(png, 'image', 'image/png'),
    ]);
    // Edit: add a 3rd.
    final jpg = File('${root.path}/a.jpg')..writeAsBytesSync([2]);
    final res =
        await storage.persistDrafts('out-2', [draftFor(jpg, 'image', 'image/jpeg')]);
    expect(res.saved, 1);

    final rows = await db.lLMOutputAttachmentDao.getAttachmentsForOutput('out-2');
    expect(rows.length, 3);
  });

  test('same base filename does not overwrite — both persist distinctly',
      () async {
    final sub = Directory('${root.path}/sub')..createSync();
    final a = File('${root.path}/photo.png')..writeAsBytesSync([1, 1, 1]);
    final b = File('${sub.path}/photo.png')..writeAsBytesSync([9, 9, 9, 9]);
    final res = await storage.persistDrafts('out-3', [
      draftFor(a, 'image', 'image/png'),
      draftFor(b, 'image', 'image/png'),
    ]);
    expect(res.saved, 2);

    final rows = await db.lLMOutputAttachmentDao.getAttachmentsForOutput('out-3');
    expect(rows.length, 2);
    final paths = rows.map((r) => r.localPath).toSet();
    expect(paths.length, 2, reason: 'destination paths must be unique');
    // Contents preserved separately (no overwrite).
    final sizes = rows.map((r) => File(r.localPath).lengthSync()).toSet();
    expect(sizes, {3, 4});
  });

  test('a draft with no source path is counted as failed, not silently lost',
      () async {
    final ok = File('${root.path}/ok.txt')..writeAsStringSync('hi');
    final res = await storage.persistDrafts('out-4', [
      draftFor(ok, 'text', 'text/plain'),
      const OutputAttachmentDraft(
          fileName: 'ghost.bin', path: null, attachmentType: 'other'),
    ]);
    expect(res.saved, 1);
    expect(res.failed, 1);
    expect(res.ok, isFalse);
    final rows = await db.lLMOutputAttachmentDao.getAttachmentsForOutput('out-4');
    expect(rows.length, 1);
  });
}
