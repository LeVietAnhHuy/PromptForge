// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daos.dart';

// ignore_for_file: type=lint
mixin _$PromptDaoMixin on DatabaseAccessor<AppDatabase> {
  $PromptsTable get prompts => attachedDatabase.prompts;
  $PromptVersionsTable get promptVersions => attachedDatabase.promptVersions;
  PromptDaoManager get managers => PromptDaoManager(this);
}

class PromptDaoManager {
  final _$PromptDaoMixin _db;
  PromptDaoManager(this._db);
  $$PromptsTableTableManager get prompts =>
      $$PromptsTableTableManager(_db.attachedDatabase, _db.prompts);
  $$PromptVersionsTableTableManager get promptVersions =>
      $$PromptVersionsTableTableManager(
          _db.attachedDatabase, _db.promptVersions);
}

mixin _$ContextPackDaoMixin on DatabaseAccessor<AppDatabase> {
  $ContextPacksTable get contextPacks => attachedDatabase.contextPacks;
  $ContextPackVersionsTable get contextPackVersions =>
      attachedDatabase.contextPackVersions;
  ContextPackDaoManager get managers => ContextPackDaoManager(this);
}

class ContextPackDaoManager {
  final _$ContextPackDaoMixin _db;
  ContextPackDaoManager(this._db);
  $$ContextPacksTableTableManager get contextPacks =>
      $$ContextPacksTableTableManager(_db.attachedDatabase, _db.contextPacks);
  $$ContextPackVersionsTableTableManager get contextPackVersions =>
      $$ContextPackVersionsTableTableManager(
          _db.attachedDatabase, _db.contextPackVersions);
}

mixin _$InboxItemDaoMixin on DatabaseAccessor<AppDatabase> {
  $InboxItemsTable get inboxItems => attachedDatabase.inboxItems;
  InboxItemDaoManager get managers => InboxItemDaoManager(this);
}

class InboxItemDaoManager {
  final _$InboxItemDaoMixin _db;
  InboxItemDaoManager(this._db);
  $$InboxItemsTableTableManager get inboxItems =>
      $$InboxItemsTableTableManager(_db.attachedDatabase, _db.inboxItems);
}

mixin _$TagDaoMixin on DatabaseAccessor<AppDatabase> {
  $TagsTable get tags => attachedDatabase.tags;
  $PromptTagsTable get promptTags => attachedDatabase.promptTags;
  TagDaoManager get managers => TagDaoManager(this);
}

class TagDaoManager {
  final _$TagDaoMixin _db;
  TagDaoManager(this._db);
  $$TagsTableTableManager get tags =>
      $$TagsTableTableManager(_db.attachedDatabase, _db.tags);
  $$PromptTagsTableTableManager get promptTags =>
      $$PromptTagsTableTableManager(_db.attachedDatabase, _db.promptTags);
}

mixin _$CollectionDaoMixin on DatabaseAccessor<AppDatabase> {
  $CollectionsTable get collections => attachedDatabase.collections;
  $PromptCollectionLinksTable get promptCollectionLinks =>
      attachedDatabase.promptCollectionLinks;
  CollectionDaoManager get managers => CollectionDaoManager(this);
}

class CollectionDaoManager {
  final _$CollectionDaoMixin _db;
  CollectionDaoManager(this._db);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db.attachedDatabase, _db.collections);
  $$PromptCollectionLinksTableTableManager get promptCollectionLinks =>
      $$PromptCollectionLinksTableTableManager(
          _db.attachedDatabase, _db.promptCollectionLinks);
}

mixin _$UserSettingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserSettingsTable get userSettings => attachedDatabase.userSettings;
  UserSettingsDaoManager get managers => UserSettingsDaoManager(this);
}

class UserSettingsDaoManager {
  final _$UserSettingsDaoMixin _db;
  UserSettingsDaoManager(this._db);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db.attachedDatabase, _db.userSettings);
}

mixin _$PromptVariableDaoMixin on DatabaseAccessor<AppDatabase> {
  $PromptVariablesTable get promptVariables => attachedDatabase.promptVariables;
  PromptVariableDaoManager get managers => PromptVariableDaoManager(this);
}

class PromptVariableDaoManager {
  final _$PromptVariableDaoMixin _db;
  PromptVariableDaoManager(this._db);
  $$PromptVariablesTableTableManager get promptVariables =>
      $$PromptVariablesTableTableManager(
          _db.attachedDatabase, _db.promptVariables);
}

mixin _$PromptExampleDaoMixin on DatabaseAccessor<AppDatabase> {
  $PromptExamplesTable get promptExamples => attachedDatabase.promptExamples;
  PromptExampleDaoManager get managers => PromptExampleDaoManager(this);
}

class PromptExampleDaoManager {
  final _$PromptExampleDaoMixin _db;
  PromptExampleDaoManager(this._db);
  $$PromptExamplesTableTableManager get promptExamples =>
      $$PromptExamplesTableTableManager(
          _db.attachedDatabase, _db.promptExamples);
}

mixin _$PromptExampleOutputDaoMixin on DatabaseAccessor<AppDatabase> {
  $PromptExampleOutputsTable get promptExampleOutputs =>
      attachedDatabase.promptExampleOutputs;
  PromptExampleOutputDaoManager get managers =>
      PromptExampleOutputDaoManager(this);
}

class PromptExampleOutputDaoManager {
  final _$PromptExampleOutputDaoMixin _db;
  PromptExampleOutputDaoManager(this._db);
  $$PromptExampleOutputsTableTableManager get promptExampleOutputs =>
      $$PromptExampleOutputsTableTableManager(
          _db.attachedDatabase, _db.promptExampleOutputs);
}
