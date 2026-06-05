import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/database/daos/daos.dart';
import '../../prompt_examples/application/attachment_storage_service.dart';
import '../domain/import_export_codec.dart';

enum MergeStrategy {
  duplicate,
  overwrite,
  skip,
}

final importExportServiceProvider = Provider<ImportExportService>((ref) {
  return ImportExportService(
    db: ref.watch(databaseProvider),
    promptDao: ref.watch(promptDaoProvider),
    contextPackDao: ref.watch(contextPackDaoProvider),
    tagDao: ref.watch(tagDaoProvider),
    pvDao: ref.watch(promptVariableDaoProvider),
    exampleDao: ref.watch(promptExampleDaoProvider),
    outputDao: ref.watch(promptExampleOutputDaoProvider),
    attachmentDao: ref.watch(lLMOutputAttachmentDaoProvider),
    attachmentStorage: ref.watch(attachmentStorageServiceProvider),
  );
});

class ImportExportService {
  final AppDatabase db;
  final PromptDao promptDao;
  final ContextPackDao contextPackDao;
  final TagDao tagDao;
  final PromptVariableDao pvDao;
  final PromptExampleDao exampleDao;
  final PromptExampleOutputDao outputDao;
  final LLMOutputAttachmentDao attachmentDao;

  /// Optional — when present, a bundle import restores attachment file bytes to
  /// disk. Null callers fall back to inserting attachment rows with no file.
  final AttachmentStorageService? attachmentStorage;

  ImportExportService({
    required this.db,
    required this.promptDao,
    required this.contextPackDao,
    required this.tagDao,
    required this.pvDao,
    required this.exampleDao,
    required this.outputDao,
    required this.attachmentDao,
    this.attachmentStorage,
  });

  Future<String> exportActiveData() async {
    final activePrompts = await (promptDao.select(promptDao.prompts)..where((t) => t.isArchived.not())).get();
    final activeContextPacks = await contextPackDao.getAllContextPacks();
    
    // Fetch related entities for active prompts
    final promptTags = <String, List<String>>{};
    final promptVariables = <String, List<PromptVariable>>{};
    final promptVersions = <String, List<PromptVersion>>{};
    final promptExamples = <String, List<PromptExample>>{};
    final exampleOutputs = <String, List<PromptExampleOutput>>{};
    final outputAttachments = <String, List<LLMOutputAttachment>>{};
    
    for (final prompt in activePrompts) {
      final tags = await tagDao.getTagsForPrompt(prompt.id);
      promptTags[prompt.id] = tags.map((t) => t.name).toList();
      
      final vars = await pvDao.getVariablesForPrompt(prompt.id);
      promptVariables[prompt.id] = vars;
      
      final versions = await promptDao.getPromptVersions(prompt.id);
      promptVersions[prompt.id] = versions;
      
      final examples = await exampleDao.getExamplesForPrompt(prompt.id);
      promptExamples[prompt.id] = examples;
      
      for (final example in examples) {
        final outputs = await outputDao.getOutputsForExample(example.id);
        exampleOutputs[example.id] = outputs;

        for (final o in outputs) {
          final atts = await attachmentDao.getAttachmentsForOutput(o.id);
          if (atts.isNotEmpty) {
            outputAttachments[o.id] = atts;
          }
        }
      }
    }
    
    final packVersions = <String, List<ContextPackVersion>>{};
    for (final pack in activeContextPacks) {
      final versions = await contextPackDao.getContextPackVersions(pack.id);
      packVersions[pack.id] = versions;
    }

    final inboxDao = InboxItemDao(db);
    final inboxItems = await inboxDao.select(inboxDao.inboxItems).get();

    final jsonStr = ImportExportCodec.encodeExport(
      activePrompts, 
      promptTags, 
      promptVariables, 
      promptVersions,
      promptExamples,
      exampleOutputs,
      outputAttachments,
      activeContextPacks,
      packVersions,
      inboxItems,
    );
    return jsonStr;
  }

  /// Reads every active attachment's bytes from disk, keyed by the in-bundle
  /// path (`attachments/<id>`) the JSON references. Missing/unreadable files are
  /// skipped (their row still exports as metadata).
  Future<Map<String, List<int>>> _collectAttachmentFiles() async {
    final files = <String, List<int>>{};
    final activePrompts = await (promptDao.select(promptDao.prompts)
          ..where((t) => t.isArchived.not()))
        .get();
    for (final prompt in activePrompts) {
      final examples = await exampleDao.getExamplesForPrompt(prompt.id);
      for (final ex in examples) {
        final outputs = await outputDao.getOutputsForExample(ex.id);
        for (final o in outputs) {
          final atts = await attachmentDao.getAttachmentsForOutput(o.id);
          for (final a in atts) {
            if (a.localPath.isEmpty) continue;
            try {
              final f = File(a.localPath);
              if (await f.exists()) {
                files['attachments/${a.id}'] = await f.readAsBytes();
              }
            } catch (_) {
              // Best-effort; skip unreadable files.
            }
          }
        }
      }
    }
    return files;
  }

  /// Full workspace backup as a zip bundle: the versioned JSON plus attachment
  /// file bytes. This is the preferred export — never contains key material.
  Future<List<int>> exportBundle() async {
    final json = await exportActiveData();
    final files = await _collectAttachmentFiles();
    return ImportExportCodec.encodeBackupBundleWithFiles(json, files);
  }

  /// Builds a shareable Markdown document (YAML front-matter + body) for one
  /// prompt, pulling its tags and variables. Contains no key material.
  Future<String> exportPromptMarkdown(String promptId) async {
    final prompt = await promptDao.getPromptById(promptId);
    final tags = await tagDao.getTagsForPrompt(promptId);
    final vars = await pvDao.getVariablesForPrompt(promptId);
    return ImportExportCodec.encodePromptMarkdown(
      prompt,
      tags.map((t) => t.name).toList(),
      vars,
    );
  }

  Future<void> importData(ImportPreview preview,
      {MergeStrategy strategy = MergeStrategy.duplicate,
      Map<String, List<int>>? attachmentFiles}) async {
    await db.transaction(() async {
      for (final imported in preview.validPrompts) {
        final prompt = imported.prompt;
        
        final existingPrompt = await (promptDao.select(promptDao.prompts)..where((t) => t.id.equals(prompt.id))).getSingleOrNull();
        
        String targetId = prompt.id;
        
        if (existingPrompt != null) {
          if (strategy == MergeStrategy.skip) {
            continue;
          } else if (strategy == MergeStrategy.duplicate) {
            targetId = const Uuid().v4();
          }
        }
        
        final companion = PromptsCompanion.insert(
          id: targetId,
          title: prompt.title,
          body: prompt.body,
          purpose: prompt.purpose != null ? drift.Value(prompt.purpose) : const drift.Value.absent(),
          createdAt: prompt.createdAt,
          updatedAt: prompt.updatedAt,
          isArchived: drift.Value(prompt.isArchived),
          isFavorite: drift.Value(prompt.isFavorite),
          usageCount: drift.Value(prompt.usageCount),
        );
        
        if (existingPrompt != null && strategy == MergeStrategy.overwrite) {
          await promptDao.updatePrompt(companion);
          // If overwriting, clear existing child records (variables synced by replaceTagsForPrompt/syncVariablesForPrompt anyway)
          // But versions and examples need manual cleanup if we want a true replace. 
          // For safety, let's just delete existing examples and versions for this prompt.
          await (promptDao.delete(promptDao.promptVersions)..where((t) => t.promptId.equals(targetId))).go();
          final oldExamples = await exampleDao.getExamplesForPrompt(targetId);
          for (final ex in oldExamples) {
            await (outputDao.delete(outputDao.promptExampleOutputs)..where((t) => t.exampleId.equals(ex.id))).go();
            await (exampleDao.delete(exampleDao.promptExamples)..where((t) => t.id.equals(ex.id))).go();
          }
        } else {
          await promptDao.createPrompt(companion);
        }

        // Import tags
        if (imported.tags.isNotEmpty) {
          await tagDao.replaceTagsForPrompt(targetId, imported.tags);
        }
        
        // Import variables
        if (imported.variables.isNotEmpty) {
          final varCompanions = imported.variables.map((v) => PromptVariablesCompanion.insert(
            id: const Uuid().v4(),
            promptId: targetId,
            name: v.name,
            label: v.label != null ? drift.Value(v.label) : const drift.Value.absent(),
            description: v.description != null ? drift.Value(v.description) : const drift.Value.absent(),
            defaultValue: v.defaultValue != null ? drift.Value(v.defaultValue) : const drift.Value.absent(),
            exampleValue: v.exampleValue != null ? drift.Value(v.exampleValue) : const drift.Value.absent(),
            isRequired: drift.Value(v.isRequired),
            sortOrder: drift.Value(v.sortOrder),
            createdAt: v.createdAt,
            updatedAt: v.updatedAt,
          )).toList();
          await pvDao.syncVariablesForPrompt(targetId, varCompanions);
        }
        
        // Import versions
        for (final v in imported.versions) {
          // We want to retain createdAt, let's insert raw row.
          await promptDao.into(promptDao.promptVersions).insert(PromptVersionsCompanion.insert(
            id: const Uuid().v4(),
            promptId: targetId,
            title: v.title,
            body: v.body,
            tagsJson: v.tagsJson != null ? drift.Value(v.tagsJson) : const drift.Value.absent(),
            variableMetadataJson: v.variableMetadataJson != null ? drift.Value(v.variableMetadataJson) : const drift.Value.absent(),
            note: v.note != null ? drift.Value(v.note) : const drift.Value.absent(),
            versionNumber: drift.Value(v.versionNumber),
            createdAt: v.createdAt,
          ));
        }

        // Import examples
        for (final ex in imported.examples) {
          final newExampleId = const Uuid().v4();
          await exampleDao.into(exampleDao.promptExamples).insert(PromptExamplesCompanion.insert(
            id: newExampleId,
            promptId: drift.Value(targetId),
            title: ex.title,
            compiledPrompt: ex.compiledPrompt,
            contextPackId: ex.contextPackId != null ? drift.Value(ex.contextPackId) : const drift.Value.absent(),
            variableValuesJson: ex.variableValuesJson != null ? drift.Value(ex.variableValuesJson) : const drift.Value.absent(),
            notes: ex.notes != null ? drift.Value(ex.notes) : const drift.Value.absent(),
            createdAt: ex.createdAt,
            updatedAt: ex.updatedAt,
            isArchived: drift.Value(ex.isArchived),
          ));
          
          final outputs = imported.exampleOutputs[ex.id] ?? [];
          for (final o in outputs) {
            // Hoisted so attachments link to the NEW output row (previously they
            // were inserted against the original/decoded id and were orphaned).
            final newOutputId = const Uuid().v4();
            await outputDao.into(outputDao.promptExampleOutputs).insert(PromptExampleOutputsCompanion.insert(
              id: newOutputId,
              exampleId: newExampleId,
              providerId: o.providerId != null ? drift.Value(o.providerId) : const drift.Value.absent(),
              modelId: o.modelId != null ? drift.Value(o.modelId) : const drift.Value.absent(),
              providerName: o.providerName,
              modelName: o.modelName != null ? drift.Value(o.modelName) : const drift.Value.absent(),
              outputType: drift.Value(o.outputType),
              sourceType: drift.Value(o.sourceType),
              outputText: o.outputText,
              score: o.score != null ? drift.Value(o.score) : const drift.Value.absent(),
              notes: o.notes != null ? drift.Value(o.notes) : const drift.Value.absent(),
              isBest: drift.Value(o.isBest),
              runParamsJson: o.runParamsJson != null ? drift.Value(o.runParamsJson) : const drift.Value.absent(),
              inputTokens: o.inputTokens != null ? drift.Value(o.inputTokens) : const drift.Value.absent(),
              outputTokens: o.outputTokens != null ? drift.Value(o.outputTokens) : const drift.Value.absent(),
              latencyMs: o.latencyMs != null ? drift.Value(o.latencyMs) : const drift.Value.absent(),
              createdAt: o.createdAt,
              updatedAt: o.updatedAt,
            ));

            final atts = imported.outputAttachments[o.id] ?? [];
            for (final a in atts) {
              // a.localPath carries the in-bundle path (set by decode). If the
              // bundle shipped the bytes and we have storage, restore the file;
              // otherwise insert the row with an empty path (metadata only).
              String localPath = '';
              final bytes = attachmentFiles?[a.localPath];
              if (bytes != null && attachmentStorage != null) {
                localPath = await attachmentStorage!.writeImportedBytes(
                      outputId: newOutputId,
                      fileName: a.fileName,
                      bytes: bytes,
                    ) ??
                    '';
              }
              await attachmentDao.createAttachment(LLMOutputAttachmentsCompanion.insert(
                id: const Uuid().v4(),
                outputId: newOutputId,
                fileName: a.fileName,
                mimeType: a.mimeType,
                sizeBytes: a.sizeBytes != null ? drift.Value(a.sizeBytes!) : const drift.Value.absent(),
                attachmentType: a.attachmentType != null ? drift.Value(a.attachmentType!) : const drift.Value.absent(),
                localPath: localPath,
                createdAt: a.createdAt,
              ));
            }
          }
        }
      }

      for (final importedPack in preview.validContextPacks) {
        final pack = importedPack.pack;
        final existingPack = await (contextPackDao.select(contextPackDao.contextPacks)..where((t) => t.id.equals(pack.id))).getSingleOrNull();
        String targetId = pack.id;
        
        if (existingPack != null) {
          if (strategy == MergeStrategy.skip) {
            continue;
          } else if (strategy == MergeStrategy.duplicate) {
            targetId = const Uuid().v4();
          }
        }
        
        final companion = ContextPacksCompanion.insert(
          id: targetId,
          name: pack.name,
          description: pack.description != null ? drift.Value(pack.description) : const drift.Value.absent(),
          content: pack.content,
          createdAt: pack.createdAt,
          updatedAt: pack.updatedAt,
          isArchived: drift.Value(pack.isArchived),
          isBuiltin: drift.Value(pack.isBuiltin),
          sortOrder: drift.Value(pack.sortOrder),
        );
        
        if (existingPack != null && strategy == MergeStrategy.overwrite) {
          await contextPackDao.updateContextPack(companion);
          await (contextPackDao.delete(contextPackDao.contextPackVersions)..where((t) => t.contextPackId.equals(targetId))).go();
        } else {
          await contextPackDao.createContextPack(companion);
        }
        
        for (final v in importedPack.versions) {
          await contextPackDao.into(contextPackDao.contextPackVersions).insert(ContextPackVersionsCompanion.insert(
            id: const Uuid().v4(),
            contextPackId: targetId,
            name: v.name,
            description: v.description != null ? drift.Value(v.description) : const drift.Value.absent(),
            content: v.content,
            note: v.note != null ? drift.Value(v.note) : const drift.Value.absent(),
            createdAt: v.createdAt,
          ));
        }
      }

      final inboxDao = InboxItemDao(db);
      for (final inboxItem in preview.validInboxItems) {
        final existingItem = await (inboxDao.select(inboxDao.inboxItems)..where((t) => t.id.equals(inboxItem.id))).getSingleOrNull();
        
        String targetId = inboxItem.id;
        
        if (existingItem != null) {
          if (strategy == MergeStrategy.skip) {
            continue;
          } else if (strategy == MergeStrategy.duplicate) {
            targetId = const Uuid().v4();
          }
        }
        
        final companion = InboxItemsCompanion.insert(
          id: targetId,
          title: inboxItem.title != null ? drift.Value(inboxItem.title) : const drift.Value.absent(),
          rawText: inboxItem.rawText,
          source: inboxItem.source != null ? drift.Value(inboxItem.source) : const drift.Value.absent(),
          status: drift.Value(inboxItem.status),
          convertedPromptId: inboxItem.convertedPromptId != null ? drift.Value(inboxItem.convertedPromptId) : const drift.Value.absent(),
          createdAt: inboxItem.createdAt,
          updatedAt: inboxItem.updatedAt,
        );
        
        if (existingItem != null && strategy == MergeStrategy.overwrite) {
          await inboxDao.updateInboxItem(companion);
        } else {
          await inboxDao.createInboxItem(companion);
        }
      }
    });
  }
}
