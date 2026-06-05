import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database.dart';
import '../tables/tables.dart';

part 'daos.g.dart';

@DriftAccessor(tables: [Prompts, PromptVersions])
class PromptDao extends DatabaseAccessor<AppDatabase> with _$PromptDaoMixin {
  PromptDao(super.db);

  Future<void> createPrompt(PromptsCompanion entry) =>
      into(prompts).insert(entry);
  Future<Prompt> getPromptById(String id) =>
      (select(prompts)..where((t) => t.id.equals(id))).getSingle();
  Stream<List<Prompt>> watchAllPrompts() =>
      (select(prompts)..where((t) => t.isArchived.not())).watch();
  Future<List<Prompt>> getAllPrompts() =>
      (select(prompts)..where((t) => t.isArchived.not())).get();
  Future<bool> updatePrompt(PromptsCompanion entry) =>
      update(prompts).replace(entry);
  Future<int> archivePrompt(String id) =>
      (update(prompts)..where((t) => t.id.equals(id)))
          .write(const PromptsCompanion(isArchived: Value(true)));
  Future<int> deletePromptSoft(String id) =>
      (update(prompts)..where((t) => t.id.equals(id)))
          .write(PromptsCompanion(deletedAt: Value(DateTime.now())));
  Future<int> hardDeletePrompt(String id) =>
      (delete(prompts)..where((t) => t.id.equals(id))).go();
  Future<int> toggleFavorite(String id, bool isFavorite) =>
      (update(prompts)..where((t) => t.id.equals(id)))
          .write(PromptsCompanion(isFavorite: Value(isFavorite)));

  Future<void> incrementUsage(String id) async {
    final prompt = await getPromptById(id);
    await (update(prompts)..where((t) => t.id.equals(id)))
        .write(PromptsCompanion(
      usageCount: Value(prompt.usageCount + 1),
      lastUsedAt: Value(DateTime.now()),
    ));
  }

  // Versions
  Future<void> createPromptVersion(PromptVersionsCompanion entry) =>
      into(promptVersions).insert(entry);
  Stream<List<PromptVersion>> watchPromptVersions(String promptId) =>
      (select(promptVersions)
            ..where((t) => t.promptId.equals(promptId))
            ..orderBy([
              (t) =>
                  OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
            ]))
          .watch();
  Future<List<PromptVersion>> getPromptVersions(String promptId) =>
      (select(promptVersions)
            ..where((t) => t.promptId.equals(promptId))
            ..orderBy([
              (t) =>
                  OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
            ]))
          .get();
}

@DriftAccessor(
    tables: [ContextPacks, ContextPackVersions, PromptContextPackLinks])
class ContextPackDao extends DatabaseAccessor<AppDatabase>
    with _$ContextPackDaoMixin {
  ContextPackDao(super.db);

  Future<void> createContextPack(ContextPacksCompanion entry) =>
      into(contextPacks).insert(entry);
  Stream<List<ContextPack>> watchAllContextPacks() =>
      (select(contextPacks)..where((t) => t.isArchived.not())).watch();
  Future<List<ContextPack>> getAllContextPacks() =>
      (select(contextPacks)..where((t) => t.isArchived.not())).get();
  Future<bool> updateContextPack(ContextPacksCompanion entry) =>
      update(contextPacks).replace(entry);
  Future<int> archiveContextPack(String id) =>
      (update(contextPacks)..where((t) => t.id.equals(id)))
          .write(const ContextPacksCompanion(isArchived: Value(true)));

  // Prompt Links
  Future<void> attachContextPackToPrompt(
          PromptContextPackLinksCompanion entry) =>
      into(promptContextPackLinks)
          .insert(entry, mode: InsertMode.insertOrReplace);
  Future<int> detachContextPackFromPrompt(
          String promptId, String contextPackId) =>
      (delete(promptContextPackLinks)
            ..where((t) =>
                t.promptId.equals(promptId) &
                t.contextPackId.equals(contextPackId)))
          .go();

  Future<List<ContextPack>> getContextPacksForPrompt(String promptId) async {
    final query = select(contextPacks).join([
      innerJoin(
        promptContextPackLinks,
        promptContextPackLinks.contextPackId.equalsExp(contextPacks.id),
      ),
    ])
      ..where(promptContextPackLinks.promptId.equals(promptId))
      ..where(contextPacks.isArchived.not())
      ..orderBy([
        OrderingTerm(
            expression: promptContextPackLinks.sortOrder,
            mode: OrderingMode.asc)
      ]);

    final rows = await query.get();
    return rows.map((row) => row.readTable(contextPacks)).toList();
  }

  // Versions
  Future<void> createContextPackVersion(ContextPackVersionsCompanion entry) =>
      into(contextPackVersions).insert(entry);
  Stream<List<ContextPackVersion>> watchContextPackVersions(String packId) =>
      (select(contextPackVersions)
            ..where((t) => t.contextPackId.equals(packId))
            ..orderBy([
              (t) =>
                  OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
            ]))
          .watch();
  Future<List<ContextPackVersion>> getContextPackVersions(String packId) =>
      (select(contextPackVersions)
            ..where((t) => t.contextPackId.equals(packId))
            ..orderBy([
              (t) =>
                  OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
            ]))
          .get();
}

@DriftAccessor(tables: [InboxItems])
class InboxItemDao extends DatabaseAccessor<AppDatabase>
    with _$InboxItemDaoMixin {
  InboxItemDao(super.db);

  Future<void> createInboxItem(InboxItemsCompanion entry) =>
      into(inboxItems).insert(entry);
  Future<bool> updateInboxItem(InboxItemsCompanion entry) =>
      update(inboxItems).replace(entry);
  Stream<List<InboxItem>> watchOpenInboxItems() =>
      (select(inboxItems)..where((t) => t.status.equals('open'))).watch();
  Future<InboxItem> getInboxItemById(String id) =>
      (select(inboxItems)..where((t) => t.id.equals(id))).getSingle();
  Future<int> markInboxItemConverted(String id, String promptId) =>
      (update(inboxItems)..where((t) => t.id.equals(id))).write(
          InboxItemsCompanion(
              status: const Value('converted'),
              convertedPromptId: Value(promptId)));
  Future<int> markInboxItemConvertedToRun(String id) =>
      (update(inboxItems)..where((t) => t.id.equals(id)))
          .write(const InboxItemsCompanion(status: Value('converted')));
  Future<int> archiveInboxItem(String id) =>
      (update(inboxItems)..where((t) => t.id.equals(id)))
          .write(const InboxItemsCompanion(status: Value('archived')));
  Future<int> deleteInboxItem(String id) =>
      (delete(inboxItems)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [Tags, PromptTags])
class TagDao extends DatabaseAccessor<AppDatabase> with _$TagDaoMixin {
  TagDao(super.db);

  Future<void> createTag(TagsCompanion entry) => into(tags).insert(entry);
  Stream<List<Tag>> watchAllTags() => select(tags).watch();
  Future<List<Tag>> getAllTags() => select(tags).get();
  Stream<List<PromptTag>> watchAllPromptTags() => select(promptTags).watch();
  Future<void> linkTagToPrompt(PromptTagsCompanion entry) =>
      into(promptTags).insert(entry);
  Future<int> unlinkTagFromPrompt(String promptId, String tagId) =>
      (delete(promptTags)
            ..where((t) => t.promptId.equals(promptId) & t.tagId.equals(tagId)))
          .go();

  Future<List<Tag>> getTagsForPrompt(String promptId) async {
    final query = select(promptTags)
        .join([innerJoin(tags, tags.id.equalsExp(promptTags.tagId))])
      ..where(promptTags.promptId.equals(promptId));
    final rows = await query.get();
    return rows.map((row) => row.readTable(tags)).toList();
  }

  Future<void> replaceTagsForPrompt(
      String promptId, List<String> tagNames) async {
    await transaction(() async {
      // 1. Delete existing links
      await (delete(promptTags)..where((t) => t.promptId.equals(promptId)))
          .go();

      // 2. Normalize tags
      final normalizedNames = tagNames
          .map((n) => n.trim().toLowerCase())
          .where((n) => n.isNotEmpty)
          .toSet();

      for (final name in normalizedNames) {
        // 3. Find or create tag
        final existingTag = await (select(tags)
              ..where((t) => t.name.equals(name)))
            .getSingleOrNull();
        String tagId;
        if (existingTag != null) {
          tagId = existingTag.id;
        } else {
          tagId = const Uuid().v4();
          await into(tags).insert(TagsCompanion.insert(
            id: tagId,
            name: name,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
        }

        // 4. Link to prompt
        await into(promptTags).insert(PromptTagsCompanion.insert(
          promptId: promptId,
          tagId: tagId,
          createdAt: DateTime.now(),
        ));
      }
    });
  }
}

@DriftAccessor(tables: [Collections, PromptCollectionLinks])
class CollectionDao extends DatabaseAccessor<AppDatabase>
    with _$CollectionDaoMixin {
  CollectionDao(super.db);

  Future<void> createCollection(CollectionsCompanion entry) =>
      into(collections).insert(entry);
  Stream<List<Collection>> watchAllCollections() => select(collections).watch();
  Future<void> linkPromptToCollection(PromptCollectionLinksCompanion entry) =>
      into(promptCollectionLinks).insert(entry);
  Future<int> unlinkPromptFromCollection(
          String promptId, String collectionId) =>
      (delete(promptCollectionLinks)
            ..where((t) =>
                t.promptId.equals(promptId) &
                t.collectionId.equals(collectionId)))
          .go();
}

@DriftAccessor(tables: [UserSettings])
class UserSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$UserSettingsDaoMixin {
  UserSettingsDao(super.db);

  Future<UserSetting?> getSetting(String key) =>
      (select(userSettings)..where((t) => t.key.equals(key))).getSingleOrNull();
  Future<void> setSetting(UserSettingsCompanion entry) =>
      into(userSettings).insert(entry, mode: InsertMode.insertOrReplace);
}

@DriftAccessor(tables: [PromptVariables])
class PromptVariableDao extends DatabaseAccessor<AppDatabase>
    with _$PromptVariableDaoMixin {
  PromptVariableDao(super.db);

  Future<List<PromptVariable>> getVariablesForPrompt(String promptId) =>
      (select(promptVariables)..where((t) => t.promptId.equals(promptId)))
          .get();

  Future<void> syncVariablesForPrompt(
      String promptId, List<PromptVariablesCompanion> variables) async {
    await transaction(() async {
      // 1. Delete existing variables for this prompt
      await (delete(promptVariables)..where((t) => t.promptId.equals(promptId)))
          .go();

      // 2. Insert the updated list of variables
      for (final variable in variables) {
        await into(promptVariables).insert(variable);
      }
    });
  }
}

@DriftAccessor(tables: [PromptExamples])
class PromptExampleDao extends DatabaseAccessor<AppDatabase>
    with _$PromptExampleDaoMixin {
  PromptExampleDao(super.db);

  Future<void> createExample(PromptExamplesCompanion entry) =>
      into(promptExamples).insert(entry);
  Stream<List<PromptExample>> watchExamplesForProject(String projectId) {
    return (select(promptExamples)
          ..where((t) => t.projectId.equals(projectId))
          ..where((t) => t.isArchived.not())
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  Future<bool> updateExample(PromptExamplesCompanion entry) =>
      update(promptExamples).replace(entry);
  Future<int> archiveExample(String id) =>
      (update(promptExamples)..where((t) => t.id.equals(id)))
          .write(const PromptExamplesCompanion(isArchived: Value(true)));
  Stream<List<PromptExample>> watchExamplesForPrompt(String promptId) =>
      (select(promptExamples)
            ..where((t) => t.promptId.equals(promptId) & t.isArchived.not()))
          .watch();
  Future<List<PromptExample>> getExamplesForPrompt(String promptId) =>
      (select(promptExamples)
            ..where((t) => t.promptId.equals(promptId) & t.isArchived.not()))
          .get();
  Future<PromptExample> getExampleById(String id) =>
      (select(promptExamples)..where((t) => t.id.equals(id))).getSingle();
}

@DriftAccessor(tables: [PromptExampleOutputs, PromptExamples])
class PromptExampleOutputDao extends DatabaseAccessor<AppDatabase>
    with _$PromptExampleOutputDaoMixin {
  PromptExampleOutputDao(super.db);

  Future<void> addOutput(PromptExampleOutputsCompanion entry) =>
      into(promptExampleOutputs).insert(entry);
  Future<bool> updateOutput(PromptExampleOutputsCompanion entry) =>
      update(promptExampleOutputs).replace(entry);
  Future<int> deleteOutput(String id) =>
      (delete(promptExampleOutputs)..where((t) => t.id.equals(id))).go();
  Stream<List<PromptExampleOutput>> watchOutputsForExample(String exampleId) =>
      (select(promptExampleOutputs)
            ..where((t) => t.exampleId.equals(exampleId)))
          .watch();
  Future<List<PromptExampleOutput>> getOutputsForExample(String exampleId) =>
      (select(promptExampleOutputs)
            ..where((t) => t.exampleId.equals(exampleId)))
          .get();

  Stream<List<PromptExampleOutput>> watchOutputsForPrompt(String promptId) {
    final query = select(promptExampleOutputs).join([
      innerJoin(promptExamples,
          promptExamples.id.equalsExp(promptExampleOutputs.exampleId))
    ])
      ..where(promptExamples.promptId.equals(promptId))
      ..orderBy([
        OrderingTerm(
            expression: promptExampleOutputs.createdAt, mode: OrderingMode.desc)
      ]);

    return query.watch().map((rows) {
      return rows.map((row) => row.readTable(promptExampleOutputs)).toList();
    });
  }

  Future<void> markOutputAsBest(String exampleId, String outputId) async {
    await transaction(() async {
      // Clear best flag from all outputs in this example
      await (update(promptExampleOutputs)
            ..where((t) => t.exampleId.equals(exampleId)))
          .write(const PromptExampleOutputsCompanion(isBest: Value(false)));
      // Set best flag on the chosen output
      await (update(promptExampleOutputs)..where((t) => t.id.equals(outputId)))
          .write(const PromptExampleOutputsCompanion(isBest: Value(true)));
    });
  }

  /// Searches outputs by text / provider / model, returning each match with the
  /// owning example's prompt id (when any) for navigation. Value is bound by
  /// drift, so the query is parameterized.
  Future<List<(PromptExampleOutput, String?)>> searchOutputs(String query,
      {int limit = 12}) async {
    final like = '%$query%';
    final rows = await (select(promptExampleOutputs).join([
      leftOuterJoin(promptExamples,
          promptExamples.id.equalsExp(promptExampleOutputs.exampleId)),
    ])
          ..where(promptExampleOutputs.outputText.like(like) |
              promptExampleOutputs.providerName.like(like) |
              promptExampleOutputs.modelName.like(like))
          ..orderBy([
            OrderingTerm(
                expression: promptExampleOutputs.createdAt,
                mode: OrderingMode.desc)
          ])
          ..limit(limit))
        .get();
    return rows
        .map((r) => (
              r.readTable(promptExampleOutputs),
              r.readTableOrNull(promptExamples)?.promptId,
            ))
        .toList();
  }
}

@DriftAccessor(tables: [Projects])
class ProjectDao extends DatabaseAccessor<AppDatabase> with _$ProjectDaoMixin {
  ProjectDao(super.db);

  Future<void> createProject(ProjectsCompanion entry) =>
      into(projects).insert(entry);
  Future<bool> updateProject(ProjectsCompanion entry) =>
      update(projects).replace(entry);
  Future<int> archiveProject(String id) =>
      (update(projects)..where((t) => t.id.equals(id)))
          .write(const ProjectsCompanion(isArchived: Value(true)));
  Stream<List<Project>> watchActiveProjects() => (select(projects)
        ..where((t) => t.isArchived.not())
        ..orderBy([
          (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)
        ]))
      .watch();
  Future<List<Project>> getActiveProjects() => (select(projects)
        ..where((t) => t.isArchived.not())
        ..orderBy([
          (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)
        ]))
      .get();
  Future<Project> getProjectById(String id) =>
      (select(projects)..where((t) => t.id.equals(id))).getSingle();
}

@DriftAccessor(tables: [LLMProviders])
class LLMProviderDao extends DatabaseAccessor<AppDatabase>
    with _$LLMProviderDaoMixin {
  LLMProviderDao(super.db);

  Future<void> createProvider(LLMProvidersCompanion entry) =>
      into(lLMProviders).insert(entry);
  Future<List<LLMProvider>> getAllProviders() => select(lLMProviders).get();
}

@DriftAccessor(tables: [LLMModels])
class LLMModelDao extends DatabaseAccessor<AppDatabase>
    with _$LLMModelDaoMixin {
  LLMModelDao(super.db);

  Future<void> createModel(LLMModelsCompanion entry) =>
      into(lLMModels).insert(entry);
  Future<List<LLMModel>> getModelsForProvider(String providerId) =>
      (select(lLMModels)..where((t) => t.providerId.equals(providerId))).get();
}

@DriftAccessor(tables: [LLMOutputAttachments])
class LLMOutputAttachmentDao extends DatabaseAccessor<AppDatabase>
    with _$LLMOutputAttachmentDaoMixin {
  LLMOutputAttachmentDao(super.db);

  Future<void> createAttachment(LLMOutputAttachmentsCompanion entry) =>
      into(lLMOutputAttachments).insert(entry);
  Future<List<LLMOutputAttachment>> getAttachmentsForOutput(String outputId) =>
      (select(lLMOutputAttachments)..where((t) => t.outputId.equals(outputId)))
          .get();
  Future<int> deleteAttachment(String id) =>
      (delete(lLMOutputAttachments)..where((t) => t.id.equals(id))).go();
}
