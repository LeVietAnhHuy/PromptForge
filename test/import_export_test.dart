import 'package:flutter_test/flutter_test.dart';
import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/features/import_export/domain/import_export_codec.dart';

void main() {
  group('ImportExportCodec Domain Tests', () {
    final now = DateTime.now();
    final testPrompts = [
      Prompt(
        id: 'p1',
        title: 'Test Prompt',
        body: 'Body text',
        createdAt: now,
        updatedAt: now,
        isArchived: false,
        isFavorite: false,
        usageCount: 0,
      )
    ];

    final testContextPacks = [
      ContextPack(
        id: 'c1',
        name: 'Test Pack',
        content: 'Pack content',
        createdAt: now,
        updatedAt: now,
        isArchived: false,
        isBuiltin: false,
        sortOrder: 0,
      )
    ];

    test('encodeExport returns valid JSON with correct structure', () {
      final jsonStr = ImportExportCodec.encodeExport(testPrompts, testContextPacks);
      expect(jsonStr, contains('"schemaVersion": 1'));
      expect(jsonStr, contains('"app": "PromptForge"'));
      expect(jsonStr, contains('"title": "Test Prompt"'));
      expect(jsonStr, contains('"name": "Test Pack"'));
    });

    test('decodeImport parses valid JSON correctly', () {
      final jsonStr = ImportExportCodec.encodeExport(testPrompts, testContextPacks);
      final preview = ImportExportCodec.decodeImport(jsonStr);

      expect(preview.invalidRecordsCount, 0);
      expect(preview.promptCount, 1);
      expect(preview.contextPackCount, 1);
      expect(preview.validPrompts.first.title, 'Test Prompt');
      expect(preview.validContextPacks.first.name, 'Test Pack');
    });

    test('decodeImport throws on invalid JSON string', () {
      expect(
        () => ImportExportCodec.decodeImport('not json'),
        throwsA(isA<FormatException>()),
      );
    });

    test('decodeImport throws if app is incorrect', () {
      const jsonStr = '{"app": "WrongApp", "schemaVersion": 1}';
      expect(
        () => ImportExportCodec.decodeImport(jsonStr),
        throwsA(isA<FormatException>()),
      );
    });

    test('decodeImport handles malformed records by skipping them', () {
      const jsonStr = '''
      {
        "app": "PromptForge",
        "schemaVersion": 1,
        "prompts": [
          { "id": "valid", "title": "A", "body": "B", "createdAt": "2026-06-01T00:00:00Z", "updatedAt": "2026-06-01T00:00:00Z" },
          { "id": "invalid_missing_title" }
        ],
        "contextPacks": []
      }
      ''';

      final preview = ImportExportCodec.decodeImport(jsonStr);
      expect(preview.promptCount, 1);
      expect(preview.invalidRecordsCount, 1);
      expect(preview.validPrompts.first.id, 'valid');
    });
  });
}
