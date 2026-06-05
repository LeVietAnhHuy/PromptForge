import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/database.dart';

/// The contents of a decoded backup bundle: the workspace JSON plus any
/// embedded attachment files, keyed by their in-bundle path (`attachments/<id>`).
class BundleContents {
  final String json;
  final Map<String, List<int>> files;
  const BundleContents(this.json, this.files);
}

class ImportedPrompt {
  final Prompt prompt;
  final List<String> tags;
  final List<PromptVariable> variables;
  final List<PromptVersion> versions;
  final List<PromptExample> examples;
  final Map<String, List<PromptExampleOutput>>
      exampleOutputs; // exampleId -> outputs
  final Map<String, List<LLMOutputAttachment>>
      outputAttachments; // outputId -> attachments

  ImportedPrompt(
    this.prompt,
    this.tags, [
    this.variables = const [],
    this.versions = const [],
    this.examples = const [],
    this.exampleOutputs = const {},
    this.outputAttachments = const {},
  ]);
}

class ImportedContextPack {
  final ContextPack pack;
  final List<ContextPackVersion> versions;

  ImportedContextPack(this.pack, [this.versions = const []]);
}

class ImportPreview {
  final int promptCount;
  final int contextPackCount;
  final int invalidRecordsCount;
  final int versionCount;
  final int exampleCount;
  final int comparisonCount;
  final int inboxCount;

  final List<ImportedPrompt> validPrompts;
  final List<ImportedContextPack> validContextPacks;
  final List<InboxItem> validInboxItems;

  ImportPreview({
    required this.promptCount,
    required this.contextPackCount,
    required this.invalidRecordsCount,
    this.versionCount = 0,
    this.exampleCount = 0,
    this.comparisonCount = 0,
    this.inboxCount = 0,
    required this.validPrompts,
    required this.validContextPacks,
    this.validInboxItems = const [],
  });
}

class ImportExportCodec {
  // v4 adds Stage 25 output scalars (token usage, latency, run params) so a
  // round-trip preserves them. Note: an output's `promptVersionId` is NOT
  // exported — import regenerates version row IDs, so that cross-reference can't
  // survive a round-trip; model/params/token usage still do.
  static const int currentSchemaVersion = 4;
  static const String expectedAppId = 'PromptForge';

  static String encodeExport(
    List<Prompt> prompts,
    Map<String, List<String>> promptTags,
    Map<String, List<PromptVariable>> promptVariables,
    Map<String, List<PromptVersion>> promptVersions,
    Map<String, List<PromptExample>> promptExamples,
    Map<String, List<PromptExampleOutput>> exampleOutputs,
    Map<String, List<LLMOutputAttachment>> attachments,
    List<ContextPack> contextPacks,
    Map<String, List<ContextPackVersion>> packVersions,
    List<InboxItem> inboxItems,
  ) {
    final Map<String, dynamic> payload = {
      'schemaVersion': currentSchemaVersion,
      'app': expectedAppId,
      'exportedAt': DateTime.now().toIso8601String(),
      'inboxItems': inboxItems
          .map((i) => {
                'id': i.id,
                'title': i.title,
                'rawText': i.rawText,
                'source': i.source,
                'status': i.status,
                'convertedPromptId': i.convertedPromptId,
                'createdAt': i.createdAt.toIso8601String(),
                'updatedAt': i.updatedAt.toIso8601String(),
              })
          .toList(),
      'prompts': prompts
          .map((p) => {
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
                'variables': (promptVariables[p.id] ?? [])
                    .map((v) => {
                          'name': v.name,
                          'label': v.label,
                          'description': v.description,
                          'defaultValue': v.defaultValue,
                          'exampleValue': v.exampleValue,
                          'isRequired': v.isRequired,
                        })
                    .toList(),
                'versions': (promptVersions[p.id] ?? [])
                    .map((v) => {
                          'title': v.title,
                          'body': v.body,
                          'tagsJson': v.tagsJson,
                          'variableMetadataJson': v.variableMetadataJson,
                          'note': v.note,
                          'versionNumber': v.versionNumber,
                          'createdAt': v.createdAt.toIso8601String(),
                        })
                    .toList(),
                'examples': (promptExamples[p.id] ?? [])
                    .map((e) => {
                          'id': e.id,
                          'projectId': e.projectId,
                          'title': e.title,
                          'compiledPrompt': e.compiledPrompt,
                          'contextPackId': e.contextPackId,
                          'variableValuesJson': e.variableValuesJson,
                          'notes': e.notes,
                          'refinementNote': e.refinementNote,
                          'createdAt': e.createdAt.toIso8601String(),
                          'updatedAt': e.updatedAt.toIso8601String(),
                          'isArchived': e.isArchived,
                          'outputs': (exampleOutputs[e.id] ?? [])
                              .map((o) => {
                                    'providerId': o.providerId,
                                    'modelId': o.modelId,
                                    'providerName': o.providerName,
                                    'modelName': o.modelName,
                                    'outputType': o.outputType,
                                    'sourceType': o.sourceType,
                                    'outputText': o.outputText,
                                    'score': o.score,
                                    'notes': o.notes,
                                    'isBest': o.isBest,
                                    'runParamsJson': o.runParamsJson,
                                    'inputTokens': o.inputTokens,
                                    'outputTokens': o.outputTokens,
                                    'latencyMs': o.latencyMs,
                                    'createdAt': o.createdAt.toIso8601String(),
                                    'updatedAt': o.updatedAt.toIso8601String(),
                                    'attachments': (attachments[o.id] ?? [])
                                        .map((a) => {
                                              'id': a.id,
                                              'fileName': a.fileName,
                                              'mimeType': a.mimeType,
                                              'sizeBytes': a.sizeBytes,
                                              'attachmentType':
                                                  a.attachmentType,
                                              // Where the file bytes live inside
                                              // the bundle zip (see exportBundle).
                                              'bundlePath': 'attachments/${a.id}',
                                            })
                                        .toList(),
                                  })
                              .toList(),
                        })
                    .toList(),
              })
          .toList(),
      'contextPacks': contextPacks
          .map((c) => {
                'id': c.id,
                'name': c.name,
                'description': c.description,
                'content': c.content,
                'createdAt': c.createdAt.toIso8601String(),
                'updatedAt': c.updatedAt.toIso8601String(),
                'isArchived': c.isArchived,
                'versions': (packVersions[c.id] ?? [])
                    .map((v) => {
                          'name': v.name,
                          'description': v.description,
                          'content': v.content,
                          'note': v.note,
                          'createdAt': v.createdAt.toIso8601String(),
                        })
                    .toList(),
              })
          .toList(),
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
      throw const FormatException(
          'Unsupported schema version. Please update the app.');
    }

    int invalidRecordsCount = 0;
    final List<ImportedPrompt> validPrompts = [];
    final List<ImportedContextPack> validContextPacks = [];

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

        final versionsRaw = raw['versions'] as List<dynamic>? ?? [];
        final versions = <PromptVersion>[];
        for (final v in versionsRaw) {
          if (v is Map<String, dynamic>) {
            versions.add(PromptVersion(
              id: '',
              promptId: id,
              title: v['title'] as String,
              body: v['body'] as String,
              tagsJson: v['tagsJson'] as String?,
              variableMetadataJson: v['variableMetadataJson'] as String?,
              note: v['note'] as String?,
              versionNumber: v['versionNumber'] as int? ?? 0,
              createdAt: DateTime.parse(v['createdAt'] as String),
            ));
          }
        }

        final examplesRaw = raw['examples'] as List<dynamic>? ?? [];
        final examples = <PromptExample>[];
        final exampleOutputs = <String, List<PromptExampleOutput>>{};
        final outputAttachments = <String, List<LLMOutputAttachment>>{};

        for (final e in examplesRaw) {
          if (e is Map<String, dynamic>) {
            final exampleId = e['id'] as String;
            examples.add(PromptExample(
              // Keep the original id so importData can map this example's
              // outputs (which are keyed by it). A fresh id is assigned at
              // insert time; this value is only used for that lookup.
              id: exampleId,
              projectId: e['projectId'] as String?,
              promptId: id,
              title: e['title'] as String,
              compiledPrompt: e['compiledPrompt'] as String,
              contextPackId: e['contextPackId'] as String?,
              variableValuesJson: e['variableValuesJson'] as String?,
              notes: e['notes'] as String?,
              refinementNote: e['refinementNote'] as String?,
              createdAt: DateTime.parse(e['createdAt'] as String),
              updatedAt: DateTime.parse(e['updatedAt'] as String),
              isArchived: e['isArchived'] as bool? ?? false,
            ));

            final outputsRaw = e['outputs'] as List<dynamic>? ?? [];
            final outputs = <PromptExampleOutput>[];
            for (final o in outputsRaw) {
              if (o is Map<String, dynamic>) {
                final oId = const Uuid().v4();
                outputs.add(PromptExampleOutput(
                  id: oId, // Use the real original ID? Wait, we generate new one during import, but we need the link.
                  // For codec, just store what we parse and let ImportService handle it
                  exampleId: '',
                  providerId: o['providerId'] as String?,
                  modelId: o['modelId'] as String?,
                  providerName: o['providerName'] as String? ?? 'Unknown',
                  modelName: o['modelName'] as String?,
                  outputType: o['outputType'] as String? ?? 'text',
                  sourceType: o['sourceType'] as String? ?? 'manual',
                  outputText: o['outputText'] as String? ?? '',
                  score: o['score'] as int?,
                  notes: o['notes'] as String?,
                  isBest: o['isBest'] as bool? ?? false,
                  runParamsJson: o['runParamsJson'] as String?,
                  inputTokens: o['inputTokens'] as int?,
                  outputTokens: o['outputTokens'] as int?,
                  latencyMs: o['latencyMs'] as int?,
                  createdAt: DateTime.parse(o['createdAt'] as String),
                  updatedAt: DateTime.parse(o['updatedAt'] as String),
                ));

                final attsRaw = o['attachments'] as List<dynamic>? ?? [];
                final atts = <LLMOutputAttachment>[];
                for (final a in attsRaw) {
                  if (a is Map<String, dynamic>) {
                    atts.add(LLMOutputAttachment(
                      id: a['id'] as String? ?? '',
                      outputId: oId, // Will link temporarily here
                      fileName: a['fileName'] as String,
                      mimeType: a['mimeType'] as String,
                      // localPath carries the in-bundle path until the import
                      // service resolves it to a real on-disk file (or '' when
                      // the bundle has no bytes, e.g. a metadata-only export).
                      localPath: a['bundlePath'] as String? ?? '',
                      sizeBytes: a['sizeBytes'] as int?,
                      attachmentType: a['attachmentType'] as String?,
                      createdAt: DateTime.parse(o['createdAt'] as String),
                    ));
                  }
                }
                if (atts.isNotEmpty) {
                  outputAttachments[oId] = atts;
                }
              }
            }
            exampleOutputs[exampleId] = outputs;
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
          versions,
          examples,
          exampleOutputs,
          outputAttachments,
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

        final versionsRaw = raw['versions'] as List<dynamic>? ?? [];
        final versions = <ContextPackVersion>[];
        for (final v in versionsRaw) {
          if (v is Map<String, dynamic>) {
            versions.add(ContextPackVersion(
              id: '', // Will be assigned
              contextPackId: id,
              name: v['name'] as String,
              description: v['description'] as String?,
              content: v['content'] as String,
              note: v['note'] as String?,
              createdAt: DateTime.parse(v['createdAt'] as String),
            ));
          }
        }

        validContextPacks.add(ImportedContextPack(
          ContextPack(
            id: id,
            name: name,
            description: description,
            content: content,
            createdAt: DateTime.parse(createdAtStr),
            updatedAt: DateTime.parse(updatedAtStr),
            isArchived: isArchived,
            isBuiltin: false,
            sortOrder: 0,
          ),
          versions,
        ));
      } catch (e) {
        invalidRecordsCount++;
      }
    }

    int totalVersions = 0;
    int totalExamples = 0;
    int totalComparisons = 0;

    for (final p in validPrompts) {
      totalVersions += p.versions.length;
      totalExamples += p.examples.length;
      for (final outputs in p.exampleOutputs.values) {
        totalComparisons += outputs.length;
      }
    }

    for (final c in validContextPacks) {
      totalVersions += c.versions.length;
    }

    final validInboxItems = <InboxItem>[];
    final inboxRaw = payload['inboxItems'] as List<dynamic>? ?? [];
    for (final raw in inboxRaw) {
      if (raw is! Map<String, dynamic>) {
        invalidRecordsCount++;
        continue;
      }
      try {
        final id = raw['id'] as String;
        final rawText = raw['rawText'] as String;
        final createdAtStr = raw['createdAt'] as String;
        final updatedAtStr = raw['updatedAt'] as String;
        validInboxItems.add(InboxItem(
          id: id,
          title: raw['title'] as String?,
          rawText: rawText,
          source: raw['source'] as String?,
          status: raw['status'] as String? ?? 'open',
          convertedPromptId: raw['convertedPromptId'] as String?,
          createdAt: DateTime.parse(createdAtStr),
          updatedAt: DateTime.parse(updatedAtStr),
        ));
      } catch (e) {
        invalidRecordsCount++;
      }
    }

    return ImportPreview(
      promptCount: validPrompts.length,
      contextPackCount: validContextPacks.length,
      invalidRecordsCount: invalidRecordsCount,
      versionCount: totalVersions,
      exampleCount: totalExamples,
      comparisonCount: totalComparisons,
      inboxCount: validInboxItems.length,
      validPrompts: validPrompts,
      validContextPacks: validContextPacks,
      validInboxItems: validInboxItems,
    );
  }

  /// Renders a single prompt as a human-readable Markdown document with a YAML
  /// front-matter header (title, purpose, tags, timestamps, and variable
  /// metadata) followed by the prompt body. This is a one-way, shareable export
  /// — not part of the round-trippable bundle — and, like every export, contains
  /// no API key material.
  static String encodePromptMarkdown(
    Prompt prompt,
    List<String> tags,
    List<PromptVariable> variables,
  ) {
    final buf = StringBuffer();
    buf.writeln('---');
    buf.writeln('id: ${_yaml(prompt.id)}');
    buf.writeln('title: ${_yaml(prompt.title)}');
    if (prompt.purpose != null && prompt.purpose!.isNotEmpty) {
      buf.writeln('purpose: ${_yaml(prompt.purpose!)}');
    }
    if (tags.isNotEmpty) {
      buf.writeln('tags:');
      for (final t in tags) {
        buf.writeln('  - ${_yaml(t)}');
      }
    }
    buf.writeln('created: ${_yaml(prompt.createdAt.toIso8601String())}');
    buf.writeln('updated: ${_yaml(prompt.updatedAt.toIso8601String())}');
    if (variables.isNotEmpty) {
      buf.writeln('variables:');
      for (final v in variables) {
        buf.writeln('  - name: ${_yaml(v.name)}');
        buf.writeln('    required: ${v.isRequired}');
        if (v.defaultValue != null && v.defaultValue!.isNotEmpty) {
          buf.writeln('    default: ${_yaml(v.defaultValue!)}');
        }
        if (v.description != null && v.description!.isNotEmpty) {
          buf.writeln('    description: ${_yaml(v.description!)}');
        }
      }
    }
    buf.writeln('---');
    buf.writeln();
    buf.write(prompt.body);
    if (!prompt.body.endsWith('\n')) buf.writeln();
    return buf.toString();
  }

  /// Double-quoted YAML scalar with the characters that would break a scalar
  /// (backslash, quote, newline) escaped — keeps front-matter valid for any
  /// title/tag/value.
  static String _yaml(String value) {
    final escaped = value
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n');
    return '"$escaped"';
  }

  static List<int> encodeBackupBundle(String jsonString) {
    final archive = Archive();
    final bytes = utf8.encode(jsonString);
    final file = ArchiveFile('backup.json', bytes.length, bytes);
    archive.addFile(file);
    return ZipEncoder().encode(archive);
  }

  /// Like [encodeBackupBundle] but also embeds attachment file bytes under their
  /// `attachments/<id>` paths (keyed by the `bundlePath` the JSON references).
  static List<int> encodeBackupBundleWithFiles(
      String jsonString, Map<String, List<int>> files) {
    final archive = Archive();
    final bytes = utf8.encode(jsonString);
    archive.addFile(ArchiveFile('backup.json', bytes.length, bytes));
    files.forEach((path, data) {
      archive.addFile(ArchiveFile(path, data.length, data));
    });
    return ZipEncoder().encode(archive);
  }

  /// Decodes a bundle into its JSON plus any embedded attachment files (by
  /// in-bundle path). Falls back to treating raw bytes as a legacy JSON export.
  static BundleContents decodeBundleWithFiles(List<int> zipBytes) {
    try {
      final archive = ZipDecoder().decodeBytes(zipBytes);
      String? json;
      final files = <String, List<int>>{};
      for (final f in archive) {
        if (!f.isFile) continue;
        if (f.name == 'backup.json') {
          json = utf8.decode(f.content as List<int>);
        } else if (f.name.startsWith('attachments/')) {
          files[f.name] = List<int>.from(f.content as List<int>);
        }
      }
      if (json != null) return BundleContents(json, files);
    } catch (_) {
      // Not a zip — fall through to the legacy raw-JSON path below.
    }
    try {
      return BundleContents(utf8.decode(zipBytes), const {});
    } catch (_) {
      throw const FormatException('Not a valid PromptForge backup bundle.');
    }
  }

  static String decodeBackupBundle(List<int> zipBytes) {
    // try-catch parsing zip
    try {
      final archive = ZipDecoder().decodeBytes(zipBytes);
      for (final file in archive) {
        if (file.isFile && file.name == 'backup.json') {
          return utf8.decode(file.content as List<int>);
        }
      }
      throw const FormatException('Missing backup.json inside archive.');
    } catch (e) {
      // If it fails to parse as zip, it might be a raw JSON file (legacy export).
      // Let's try to just return it as UTF-8 string.
      try {
        return utf8.decode(zipBytes);
      } catch (_) {
        throw const FormatException('Not a valid PromptForge backup bundle.');
      }
    }
  }
}
