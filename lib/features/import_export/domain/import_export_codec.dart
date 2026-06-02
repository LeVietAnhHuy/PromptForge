import 'dart:convert';
import '../../../core/database/database.dart';

class ImportedPrompt {
  final Prompt prompt;
  final List<String> tags;
  final List<PromptVariable> variables;
  ImportedPrompt(this.prompt, this.tags, [this.variables = const []]);
}

class ImportPreview {
  final int promptCount;
  final int contextPackCount;
  final int invalidRecordsCount;
  final List<ImportedPrompt> validPrompts;
  final List<ContextPack> validContextPacks;

  ImportPreview({
    required this.promptCount,
    required this.contextPackCount,
    required this.invalidRecordsCount,
    required this.validPrompts,
    required this.validContextPacks,
  });
}

class ImportExportCodec {
  static const int currentSchemaVersion = 2;
  static const String expectedAppId = 'PromptForge';

  static String encodeExport(List<Prompt> prompts, Map<String, List<String>> promptTags, Map<String, List<PromptVariable>> promptVariables, List<ContextPack> contextPacks) {
    final Map<String, dynamic> payload = {
      'schemaVersion': currentSchemaVersion,
      'app': expectedAppId,
      'exportedAt': DateTime.now().toIso8601String(),
      'prompts': prompts.map((p) => {
        'id': p.id,
        'title': p.title,
        'body': p.body,
        'purpose': p.purpose,
        'createdAt': p.createdAt.toIso8601String(),
        'updatedAt': p.updatedAt.toIso8601String(),
        'isArchived': p.isArchived,
        'isFavorite': p.isFavorite,
        'usageCount': p.usageCount,
        'tags': promptTags[p.id] ?? [],
        'variables': (promptVariables[p.id] ?? []).map((v) => {
          'name': v.name,
          'label': v.label,
          'description': v.description,
          'defaultValue': v.defaultValue,
          'exampleValue': v.exampleValue,
          'isRequired': v.isRequired,
        }).toList(),
      }).toList(),
      'contextPacks': contextPacks.map((c) => {
        'id': c.id,
        'name': c.name,
        'description': c.description,
        'content': c.content,
        'createdAt': c.createdAt.toIso8601String(),
        'updatedAt': c.updatedAt.toIso8601String(),
        'isArchived': c.isArchived,
      }).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  static ImportPreview decodeImport(String jsonString) {
    Map<String, dynamic> payload;
    try {
      payload = jsonDecode(jsonString);
    } catch (e) {
      throw const FormatException('Invalid JSON format.');
    }

    if (payload['app'] != expectedAppId) {
      throw const FormatException('Not a valid PromptForge export file.');
    }

    final schemaVersion = payload['schemaVersion'] as int?;
    if (schemaVersion == null) {
      throw const FormatException('Missing schemaVersion.');
    }
    if (schemaVersion > currentSchemaVersion) {
      throw const FormatException('Unsupported schema version. Please update the app.');
    }

    int invalidRecordsCount = 0;
    final List<ImportedPrompt> validPrompts = [];
    final List<ContextPack> validContextPacks = [];

    final promptsRaw = payload['prompts'] as List<dynamic>? ?? [];
    for (final raw in promptsRaw) {
      if (raw is! Map<String, dynamic>) {
        invalidRecordsCount++;
        continue;
      }
      try {
        final id = raw['id'] as String;
        final title = raw['title'] as String;
        final body = raw['body'] as String;
        final purpose = raw['purpose'] as String?;
        final createdAtStr = raw['createdAt'] as String;
        final updatedAtStr = raw['updatedAt'] as String;
        final isArchived = raw['isArchived'] as bool? ?? false;
        final isFavorite = raw['isFavorite'] as bool? ?? false;
        final usageCount = raw['usageCount'] as int? ?? 0;
        final tagsRaw = raw['tags'] as List<dynamic>? ?? [];
        final tags = tagsRaw.map((e) => e.toString()).toList();

        final varsRaw = raw['variables'] as List<dynamic>? ?? [];
        final variables = <PromptVariable>[];
        for (final v in varsRaw) {
          if (v is Map<String, dynamic>) {
            variables.add(PromptVariable(
              id: '', // Will be assigned during import service insertion
              promptId: id,
              name: v['name'] as String,
              label: v['label'] as String?,
              description: v['description'] as String?,
              defaultValue: v['defaultValue'] as String?,
              exampleValue: v['exampleValue'] as String?,
              isRequired: v['isRequired'] as bool? ?? true,
              sortOrder: 0,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ));
          }
        }

        validPrompts.add(ImportedPrompt(
          Prompt(
            id: id,
            title: title,
            body: body,
            purpose: purpose,
            createdAt: DateTime.parse(createdAtStr),
            updatedAt: DateTime.parse(updatedAtStr),
            isArchived: isArchived,
            isFavorite: isFavorite,
            usageCount: usageCount,
          ),
          tags,
          variables,
        ));
      } catch (e) {
        invalidRecordsCount++;
      }
    }

    final contextPacksRaw = payload['contextPacks'] as List<dynamic>? ?? [];
    for (final raw in contextPacksRaw) {
      if (raw is! Map<String, dynamic>) {
        invalidRecordsCount++;
        continue;
      }
      try {
        final id = raw['id'] as String;
        final name = raw['name'] as String;
        final description = raw['description'] as String?;
        final content = raw['content'] as String;
        final createdAtStr = raw['createdAt'] as String;
        final updatedAtStr = raw['updatedAt'] as String;
        final isArchived = raw['isArchived'] as bool? ?? false;

        validContextPacks.add(ContextPack(
          id: id,
          name: name,
          description: description,
          content: content,
          createdAt: DateTime.parse(createdAtStr),
          updatedAt: DateTime.parse(updatedAtStr),
          isArchived: isArchived,
          isBuiltin: false,
          sortOrder: 0,
        ));
      } catch (e) {
        invalidRecordsCount++;
      }
    }

    return ImportPreview(
      promptCount: validPrompts.length,
      contextPackCount: validContextPacks.length,
      invalidRecordsCount: invalidRecordsCount,
      validPrompts: validPrompts,
      validContextPacks: validContextPacks,
    );
  }
}
