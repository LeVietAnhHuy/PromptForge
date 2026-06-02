import 'dart:convert';
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

    test('encodeExport returns correctly structured JSON', () {
      final jsonStr = ImportExportCodec.encodeExport(testPrompts, {}, {}, {}, {}, {}, testContextPacks, {});
      final decoded = jsonDecode(jsonStr);

      expect(decoded['schemaVersion'], 3);
      expect(decoded['app'], 'PromptForge');
      expect((decoded['prompts'] as List).length, 1);
      expect((decoded['contextPacks'] as List).length, 1);
    });

    test('decodeImport parses valid JSON', () {
      final jsonStr = ImportExportCodec.encodeExport(testPrompts, {}, {}, {}, {}, {}, testContextPacks, {});
      final preview = ImportExportCodec.decodeImport(jsonStr);

      expect(preview.invalidRecordsCount, 0);
      expect(preview.validPrompts.length, 1);
      expect(preview.validContextPacks.length, 1);
      expect(preview.validPrompts.first.prompt.title, 'Test Prompt');
      expect(preview.validContextPacks.first.pack.name, 'Test Pack');
    });

    test('decodeImport throws on invalid JSON', () {
      expect(
        () => ImportExportCodec.decodeImport('invalid json'),
        throwsA(isA<FormatException>()),
      );
    });

    test('decodeImport throws on wrong app id', () {
      final invalidJson = jsonEncode({'app': 'OtherApp', 'schemaVersion': 3});
      expect(
        () => ImportExportCodec.decodeImport(invalidJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('decodeImport throws on unsupported schema', () {
      final invalidJson = jsonEncode({'app': 'PromptForge', 'schemaVersion': 999});
      expect(
        () => ImportExportCodec.decodeImport(invalidJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('decodeImport counts invalid records', () {
      final jsonStr = jsonEncode({
        'app': 'PromptForge',
        'schemaVersion': 3,
        'prompts': [
          {'id': 'valid', 'title': 'Valid', 'body': 'body', 'createdAt': DateTime.now().toIso8601String(), 'updatedAt': DateTime.now().toIso8601String()},
          {'invalid': 'record'},
        ],
        'contextPacks': [],
      });

      final preview = ImportExportCodec.decodeImport(jsonStr);
      expect(preview.invalidRecordsCount, 1);
      expect(preview.validPrompts.length, 1);
      expect(preview.validPrompts.first.prompt.id, 'valid');
    });

    test('Backup Bundle zip and unzip works', () {
      final jsonStr = ImportExportCodec.encodeExport(testPrompts, {}, {}, {}, {}, {}, testContextPacks, {});
      
      final zipBytes = ImportExportCodec.encodeBackupBundle(jsonStr);
      expect(zipBytes, isNotEmpty);
      
      final extractedJsonStr = ImportExportCodec.decodeBackupBundle(zipBytes);
      expect(extractedJsonStr, equals(jsonStr));
    });

    test('decodeImport safely handles older v3 schema without Stage 16 fields', () {
      // Simulate an older v3 export JSON string that lacks projectId, providerId, etc.
      final jsonStr = jsonEncode({
        'app': 'PromptForge',
        'schemaVersion': 3,
        'prompts': [
          {
            'id': 'p1', 
            'title': 'Test Prompt', 
            'body': 'body', 
            'createdAt': DateTime.now().toIso8601String(), 
            'updatedAt': DateTime.now().toIso8601String(),
            'examples': [
              {
                'id': 'ex1',
                'title': 'Old Example',
                'compiledPrompt': 'Test output',
                'createdAt': DateTime.now().toIso8601String(),
                'updatedAt': DateTime.now().toIso8601String(),
                'outputs': [
                  {
                    'providerName': 'Legacy Provider',
                    'outputText': 'Response text',
                    'createdAt': DateTime.now().toIso8601String(),
                    'updatedAt': DateTime.now().toIso8601String(),
                  }
                ]
              }
            ]
          }
        ],
        'contextPacks': [],
      });

      final preview = ImportExportCodec.decodeImport(jsonStr);
      expect(preview.invalidRecordsCount, 0);
      expect(preview.validPrompts.length, 1);
      
      final ex = preview.validPrompts.first.examples.first;
      expect(ex.title, 'Old Example');
      expect(ex.projectId, null); // missing field parsed as null
      expect(ex.refinementNote, null); // missing field parsed as null
      
      final out = preview.validPrompts.first.exampleOutputs[ex.id]?.first;
      expect(out, isNotNull);
      expect(out!.providerId, null); // missing field parsed as null
      expect(out.modelId, null);
      expect(out.outputType, 'text'); // falls back to default 'text'
    });
  });
}
