import 'package:drift/drift.dart';

class Prompts extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get title => text()();
  TextColumn get purpose => text().nullable()();
  TextColumn get body => text()();
  TextColumn get promptType => text().nullable()();
  TextColumn get outputFormat => text().nullable()();
  TextColumn get targetNotes => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastUsedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class PromptVersions extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get promptId => text()(); // FK
  TextColumn get titleSnapshot => text()();
  TextColumn get bodySnapshot => text()();
  TextColumn get purposeSnapshot => text().nullable()();
  TextColumn get changeNote => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PromptVariables extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get promptId => text()(); // FK
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get defaultValue => text().nullable()();
  TextColumn get exampleValue => text().nullable()();
  BoolColumn get isRequired => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ContextPacks extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get content => text()();
  TextColumn get packType => text().nullable()();
  BoolColumn get isBuiltin => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class PromptContextPackLinks extends Table {
  TextColumn get promptId => text()();
  TextColumn get contextPackId => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {promptId, contextPackId};
}

class Tags extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get colorHex => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PromptTags extends Table {
  TextColumn get promptId => text()();
  TextColumn get tagId => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {promptId, tagId};
}

class Collections extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class PromptCollectionLinks extends Table {
  TextColumn get promptId => text()();
  TextColumn get collectionId => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {promptId, collectionId};
}

class InboxItems extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get title => text().nullable()();
  TextColumn get rawText => text()();
  TextColumn get source => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('open'))();
  TextColumn get convertedPromptId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class UserSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}
