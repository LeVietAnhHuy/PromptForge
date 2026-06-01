import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/tables.dart';

part 'daos.g.dart';

@DriftAccessor(tables: [Prompts, PromptVersions])
class PromptDao extends DatabaseAccessor<AppDatabase> with _$PromptDaoMixin {
  PromptDao(super.db);

  Future<void> createPrompt(PromptsCompanion entry) => into(prompts).insert(entry);
  Future<Prompt> getPromptById(String id) => (select(prompts)..where((t) => t.id.equals(id))).getSingle();
  Stream<List<Prompt>> watchAllPrompts() => (select(prompts)..where((t) => t.isArchived.not())).watch();
  Future<bool> updatePrompt(PromptsCompanion entry) => update(prompts).replace(entry);
  Future<int> archivePrompt(String id) => (update(prompts)..where((t) => t.id.equals(id))).write(const PromptsCompanion(isArchived: Value(true)));
  Future<int> deletePromptSoft(String id) => (update(prompts)..where((t) => t.id.equals(id))).write(PromptsCompanion(deletedAt: Value(DateTime.now())));
  Future<int> hardDeletePrompt(String id) => (delete(prompts)..where((t) => t.id.equals(id))).go();
  
  // Versions
  Future<void> createPromptVersion(PromptVersionsCompanion entry) => into(promptVersions).insert(entry);
}

@DriftAccessor(tables: [ContextPacks])
class ContextPackDao extends DatabaseAccessor<AppDatabase> with _$ContextPackDaoMixin {
  ContextPackDao(super.db);

  Future<void> createContextPack(ContextPacksCompanion entry) => into(contextPacks).insert(entry);
  Stream<List<ContextPack>> watchAllContextPacks() => (select(contextPacks)..where((t) => t.isArchived.not())).watch();
  Future<bool> updateContextPack(ContextPacksCompanion entry) => update(contextPacks).replace(entry);
  Future<int> archiveContextPack(String id) => (update(contextPacks)..where((t) => t.id.equals(id))).write(const ContextPacksCompanion(isArchived: Value(true)));
}

@DriftAccessor(tables: [InboxItems])
class InboxItemDao extends DatabaseAccessor<AppDatabase> with _$InboxItemDaoMixin {
  InboxItemDao(super.db);

  Future<void> createInboxItem(InboxItemsCompanion entry) => into(inboxItems).insert(entry);
  Stream<List<InboxItem>> watchOpenInboxItems() => (select(inboxItems)..where((t) => t.status.equals('open'))).watch();
  Future<int> markInboxItemConverted(String id, String promptId) => (update(inboxItems)..where((t) => t.id.equals(id))).write(InboxItemsCompanion(status: const Value('converted'), convertedPromptId: Value(promptId)));
  Future<int> archiveInboxItem(String id) => (update(inboxItems)..where((t) => t.id.equals(id))).write(const InboxItemsCompanion(status: Value('archived')));
  Future<int> deleteInboxItem(String id) => (delete(inboxItems)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [Tags, PromptTags])
class TagDao extends DatabaseAccessor<AppDatabase> with _$TagDaoMixin {
  TagDao(super.db);

  Future<void> createTag(TagsCompanion entry) => into(tags).insert(entry);
  Stream<List<Tag>> watchAllTags() => select(tags).watch();
  Future<void> linkTagToPrompt(PromptTagsCompanion entry) => into(promptTags).insert(entry);
  Future<int> unlinkTagFromPrompt(String promptId, String tagId) => (delete(promptTags)..where((t) => t.promptId.equals(promptId) & t.tagId.equals(tagId))).go();
}

@DriftAccessor(tables: [Collections, PromptCollectionLinks])
class CollectionDao extends DatabaseAccessor<AppDatabase> with _$CollectionDaoMixin {
  CollectionDao(super.db);

  Future<void> createCollection(CollectionsCompanion entry) => into(collections).insert(entry);
  Stream<List<Collection>> watchAllCollections() => select(collections).watch();
  Future<void> linkPromptToCollection(PromptCollectionLinksCompanion entry) => into(promptCollectionLinks).insert(entry);
  Future<int> unlinkPromptFromCollection(String promptId, String collectionId) => (delete(promptCollectionLinks)..where((t) => t.promptId.equals(promptId) & t.collectionId.equals(collectionId))).go();
}

@DriftAccessor(tables: [UserSettings])
class UserSettingsDao extends DatabaseAccessor<AppDatabase> with _$UserSettingsDaoMixin {
  UserSettingsDao(super.db);

  Future<UserSetting?> getSetting(String key) => (select(userSettings)..where((t) => t.key.equals(key))).getSingleOrNull();
  Future<void> setSetting(UserSettingsCompanion entry) => into(userSettings).insert(entry, mode: InsertMode.insertOrReplace);
}
